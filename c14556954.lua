--豪回遊鯨 VIPホエール
-- 效果：
-- 这张卡表侧表示上级召唤的场合，可以额外解放任意数量怪兽。
-- 这张卡上级召唤的场合：可以给这张卡放置为这张卡的上级召唤而解放的怪兽数量的贵宾指示物。
-- 对方把效果发动时（诱发即时效果）：可以把这张卡1个贵宾指示物取除；进行1次投掷硬币，对里表作猜测。猜中的场合，那个效果无效。猜错的场合，这张卡的原本攻击力直到回合结束时变成一半。
local s,id,o=GetID()
-- 初始化贵宾鲸的卡牌效果，注册4个效果：上级召唤条件与操作、素材检查、上级召唤后放置指示物、对方发动效果时的硬币判定效果
function s.initial_effect(c)
	c:EnableCounterPermit(0x75)
	-- 这张卡表侧表示上级召唤的场合，可以额外解放任意数量怪兽。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"解放任意数量怪兽召唤"
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SUMMON_PROC)
	e1:SetCondition(s.sumcon)
	e1:SetOperation(s.sumop)
	e1:SetValue(SUMMON_TYPE_ADVANCE)
	c:RegisterEffect(e1)
	-- 这张卡上级召唤的场合：可以给这张卡放置为这张卡的上级召唤而解放的怪兽数量的贵宾指示物。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_MATERIAL_CHECK)
	e2:SetValue(s.valcheck)
	c:RegisterEffect(e2)
	-- 对方把效果发动时（诱发即时效果）：可以把这张卡1个贵宾指示物取除；进行1次投掷硬币，对里表作猜测。猜中的场合，那个效果无效。猜错的场合，这张卡的原本攻击力直到回合结束时变成一半。
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
	-- 检索满足条件的卡片组
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
-- 判断上级召唤是否满足条件：等级不低于5且能支付任意数量的祭品
function s.sumcon(e,c,minc)
	if c==nil then return true end
	local min=1
	if minc>=1 then min=minc end
	local tp=c:GetControler()
	-- 获取己方场上所有怪兽作为祭品选择范围
	local mg=Duel.GetMatchingGroup(aux.TRUE,tp,LOCATION_MZONE,LOCATION_MZONE,nil,tp)
	-- 检查是否满足上级召唤所需的祭品数量
	return c:IsLevelAbove(5) and Duel.CheckTribute(c,min,12,mg)
end
-- 执行上级召唤的操作：选择并解放指定数量的祭品
function s.sumop(e,tp,eg,ep,ev,re,r,rp,c,minc)
	local min=1
	if minc>=1 then min=minc end
	-- 获取己方场上所有怪兽作为祭品选择范围
	local mg=Duel.GetMatchingGroup(aux.TRUE,tp,LOCATION_MZONE,LOCATION_MZONE,nil,tp)
	-- 从己方场上选择用于上级召唤的祭品
	local sg=Duel.SelectTribute(tp,c,min,12,mg)
	c:SetMaterial(sg)
	-- 将选中的祭品从场上解放
	Duel.Release(sg,REASON_SUMMON+REASON_MATERIAL)
end
-- 检查上级召唤所用素材数量并记录为指示物数量
function s.valcheck(e,c)
	local g=c:GetMaterial()
	e:SetLabel(g:GetCount())
end
-- 判断是否为上级召唤成功触发的效果
function s.addcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_ADVANCE)
end
-- 设置上级召唤后放置指示物效果的目标信息
function s.addtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetLabelObject():GetLabel()>0 end
	-- 设置操作信息：准备放置1个贵宾指示物
	Duel.SetOperationInfo(0,CATEGORY_COUNTER,nil,0,tp,1)
end
-- 执行上级召唤后放置指示物的操作
function s.addc(e,tp,eg,ep,ev,re,r,rp)
	if e:GetHandler():IsRelateToChain() and e:GetHandler():IsFaceup() then
		e:GetHandler():AddCounter(0x75,e:GetLabelObject():GetLabel())
	end
end
-- 判断对方发动效果时是否可以响应此效果
function s.discon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查对方发动的效果是否可被无效
	return ep~=tp and Duel.IsChainDisablable(ev)
end
-- 设置硬币判定效果的费用：移除1个贵宾指示物
function s.discost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsCanRemoveCounter(tp,0x75,1,REASON_COST) end
	e:GetHandler():RemoveCounter(tp,0x75,1,REASON_COST)
end
-- 设置硬币判定效果的目标信息
function s.distg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置操作信息：准备进行1次投掷硬币
	Duel.SetOperationInfo(0,CATEGORY_COIN,nil,0,ep,1)
end
-- 执行硬币判定效果：选择正反面并投掷硬币，根据结果决定是否无效效果或改变攻击力
function s.disop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 提示玩家选择硬币的正反面
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_COIN)  --"请选择硬币的正反面"
	-- 让玩家宣言硬币的正反面
	local coin=Duel.AnnounceCoin(tp)
	-- 进行1次投掷硬币
	local res=Duel.TossCoin(tp,1)
	if coin~=res then
		-- 使对方发动的效果无效
		Duel.NegateEffect(ev)
	elseif c:IsRelateToChain() and c:IsFaceupEx() then
		local batk=c:GetBaseAttack()
		-- 设置攻击力减半效果
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_BASE_ATTACK_FINAL)
		e1:SetValue(math.ceil(batk/2))
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END+RESET_DISABLE)
		c:RegisterEffect(e1)
	end
end
