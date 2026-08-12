--豪回遊鯨 VIPホエール
-- 效果：
-- ①：这张卡可以把怪兽任意数量解放表侧表示上级召唤。
-- ②：这张卡上级召唤的场合才能发动。为这张卡的上级召唤而解放的怪兽数量的VIP指示物给这张卡放置。
-- ③：对方把魔法·陷阱·怪兽的效果发动时，把这张卡1个VIP指示物取除才能发动。进行1次投掷硬币，对里表作猜测。猜中的场合，那个效果无效。猜错的场合，这张卡的原本攻击力直到回合结束时变成一半。
local s,id,o=GetID()
-- 初始化卡片效果：允许放置0x75（VIP）指示物，并注册4个效果——e1召唤规则效果（可把怪兽任意数量解放上级召唤）、e2素材检查效果（记录解放数量）、e3上级召唤成功时放置VIP指示物的诱发效果、e4取除指示物投掷硬币使效果无效的诱发即时效果
function s.initial_effect(c)
	c:EnableCounterPermit(0x75)
	-- ①：这张卡可以把怪兽任意数量解放表侧表示上级召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"解放任意数量怪兽召唤"
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SUMMON_PROC)
	e1:SetCondition(s.sumcon)
	e1:SetOperation(s.sumop)
	e1:SetValue(SUMMON_TYPE_ADVANCE)
	c:RegisterEffect(e1)
	-- 为这张卡的上级召唤而解放的怪兽数量的
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_MATERIAL_CHECK)
	e2:SetValue(s.valcheck)
	c:RegisterEffect(e2)
	-- ②：这张卡上级召唤的场合才能发动。为这张卡的上级召唤而解放的怪兽数量的VIP指示物给这张卡放置。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))  --"放置指示物"
	e3:SetCategory(CATEGORY_COUNTER)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_SUMMON_SUCCESS)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCondition(s.addcon)
	e3:SetTarget(s.addtg)
	e3:SetOperation(s.addc)
	e3:SetLabelObject(e2)
	c:RegisterEffect(e3)
	-- ③：对方把魔法·陷阱·怪兽的效果发动时，把这张卡1个VIP指示物取除才能发动。进行1次投掷硬币，对里表作猜测。猜中的场合，那个效果无效。猜错的场合，这张卡的原本攻击力直到回合结束时变成一半。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,2))  --"投掷硬币"
	e4:SetCategory(CATEGORY_COIN+CATEGORY_DISABLE+CATEGORY_ATKCHANGE)
	e4:SetType(EFFECT_TYPE_QUICK_O)
	e4:SetCode(EVENT_CHAINING)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCondition(s.discon)
	e4:SetCost(s.discost)
	e4:SetTarget(s.distg)
	e4:SetOperation(s.disop)
	c:RegisterEffect(e4)
end
s.mentioned_counter={
	[0x75]=true,
}
-- 召唤条件：计算最小祭品数量（至少1只），并检查这张卡为5星以上且双方场上怪兽区中存在足够数量（1至12只）可作为祭品的怪兽
function s.sumcon(e,c,minc)
	if c==nil then return true end
	local min=1
	if minc>=1 then min=minc end
	local tp=c:GetControler()
	-- 取得双方场上怪兽区的全部怪兽，作为可作为祭品的怪兽组
	local mg=Duel.GetMatchingGroup(aux.TRUE,tp,LOCATION_MZONE,LOCATION_MZONE,nil,tp)
	-- 检查这张卡为5星以上，且存在1至12只可用于这张卡通常召唤的祭品
	return c:IsLevelAbove(5) and Duel.CheckTribute(c,min,12,mg)
end
-- 召唤操作：让玩家选择1至12只祭品，将其设为召唤素材并以召唤·素材原因解放，完成上级召唤
function s.sumop(e,tp,eg,ep,ev,re,r,rp,c,minc)
	local min=1
	if minc>=1 then min=minc end
	-- 取得双方场上怪兽区的全部怪兽，作为可选择的祭品范围
	local mg=Duel.GetMatchingGroup(aux.TRUE,tp,LOCATION_MZONE,LOCATION_MZONE,nil,tp)
	-- 让玩家从其中选择1至12只用于这张卡通常召唤的祭品
	local sg=Duel.SelectTribute(tp,c,min,12,mg)
	c:SetMaterial(sg)
	-- 以召唤及作为素材的原因解放选择的祭品怪兽
	Duel.Release(sg,REASON_SUMMON+REASON_MATERIAL)
end
-- 素材检查：取得这张卡的召唤素材，将素材数量（解放的怪兽数量）记录到标签中供后续效果使用
function s.valcheck(e,c)
	local g=c:GetMaterial()
	e:SetLabel(g:GetCount())
end
-- 发动条件：这张卡是上级召唤的场合
function s.addcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_ADVANCE)
end
-- 对象确认：检查记录的解放怪兽数量大于0，并设置放置指示物的操作信息
function s.addtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetLabelObject():GetLabel()>0 end
	-- 设置本连锁的操作信息为指示物效果，预计给放置1个指示物
	Duel.SetOperationInfo(0,CATEGORY_COUNTER,nil,0,tp,1)
end
-- 效果处理：这张卡与连锁关联且表侧表示存在的场合，给这张卡放置与记录的解放怪兽数量相同数量的0x75（VIP）指示物
function s.addc(e,tp,eg,ep,ev,re,r,rp)
	if e:GetHandler():IsRelateToChain() and e:GetHandler():IsFaceup() then
		e:GetHandler():AddCounter(0x75,e:GetLabelObject():GetLabel())
	end
end
-- 发动条件：发动效果的玩家是对方，且该连锁的效果可以被无效
function s.discon(e,tp,eg,ep,ev,re,r,rp)
	-- 确认是对方发动的效果且该连锁的效果可以被无效
	return ep~=tp and Duel.IsChainDisablable(ev)
end
-- 代价：检查并把这张卡的1个0x75（VIP）指示物取除作为发动代价
function s.discost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsCanRemoveCounter(tp,0x75,1,REASON_COST) end
	e:GetHandler():RemoveCounter(tp,0x75,1,REASON_COST)
end
-- 对象确认：设置投掷硬币的操作信息
function s.distg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置本连锁的操作信息为硬币效果，预计进行1次投掷硬币
	Duel.SetOperationInfo(0,CATEGORY_COIN,nil,0,ep,1)
end
-- 效果处理：让对方猜硬币的正反面后进行1次投掷硬币，猜中的场合使那个发动的效果无效；猜错的场合，这张卡的原本攻击力直到回合结束时变成一半（向上取整）
function s.disop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 提示玩家选择硬币的正反面
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_COIN)  --"请选择硬币的正反面"
	-- 让玩家宣言硬币的正面或反面
	local coin=Duel.AnnounceCoin(tp)
	-- 进行1次投掷硬币并取得结果
	local res=Duel.TossCoin(tp,1)
	if coin~=res then
		-- 使该连锁的效果无效
		Duel.NegateEffect(ev)
	elseif c:IsRelateToChain() and c:IsFaceupEx() then
		local batk=c:GetBaseAttack()
		-- 猜错的场合，这张卡的原本攻击力直到回合结束时变成一半。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_BASE_ATTACK_FINAL)
		e1:SetValue(math.ceil(batk/2))
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END+RESET_DISABLE)
		c:RegisterEffect(e1)
	end
end
