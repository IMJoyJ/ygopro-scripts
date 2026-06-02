--VIP Whale
-- 效果：
-- 这张卡表侧表示上级召唤的场合，可以额外解放任意数量怪兽。
-- 这张卡上级召唤的场合：可以给这张卡放置为这张卡的上级召唤而解放的怪兽数量的贵宾指示物。
-- 对方把效果发动时（诱发即时效果）：可以把这张卡1个贵宾指示物取除；进行1次投掷硬币，对里表作猜测。猜中的场合，那个效果无效。猜错的场合，这张卡的原本攻击力直到回合结束时变成一半。
local s,id,o=GetID()
-- 注册卡片效果并允许放置贵宾指示物（0x75）
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
	-- 这张卡上级召唤的场合：可以给这张卡放置为这张卡的上级召唤而解放的怪兽数量的贵宾指示物。
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
	-- 对方把效果发动时（诱发即时效果）：可以把这张卡1个贵宾指示物取除；进行1次投掷硬币，对里表作猜测。猜中的场合，那个效果无效。猜错的场合，这张卡的原本攻击力直到回合结束时变成一半。
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
-- 定义上级召唤效果的Condition：检查是否为上级召唤，且场上是否存在可用于解放的怪兽
function s.sumcon(e,c,minc)
	if c==nil then return true end
	local min=1
	if minc>=1 then min=minc end
	local tp=c:GetControler()
	-- 获取场上所有可以作为上级召唤解放素材的怪兽组
	local mg=Duel.GetMatchingGroup(aux.TRUE,tp,LOCATION_MZONE,LOCATION_MZONE,nil,tp)
	-- 检查这张卡的等级是否在5以上，并且场上是否存在满足解放数量要求的素材怪兽
	return c:IsLevelAbove(5) and Duel.CheckTribute(c,min,12,mg)
end
-- 定义上级召唤效果的Operation：执行解放操作以进行上级召唤
function s.sumop(e,tp,eg,ep,ev,re,r,rp,c,minc)
	local min=1
	if minc>=1 then min=minc end
	-- 获取场上所有可以作为通常召唤解放素材的怪兽组
	local mg=Duel.GetMatchingGroup(aux.TRUE,tp,LOCATION_MZONE,LOCATION_MZONE,nil,tp)
	-- 让玩家选择作为通常召唤解放素材的怪兽组
	local sg=Duel.SelectTribute(tp,c,min,12,mg)
	c:SetMaterial(sg)
	-- 将被选中的素材怪兽解放以进行召唤
	Duel.Release(sg,REASON_SUMMON+REASON_MATERIAL)
end
-- 定义素材检查：获取用于上级召唤解放的怪兽数量，并记录在Label中
function s.valcheck(e,c)
	local g=c:GetMaterial()
	e:SetLabel(g:GetCount())
end
-- 定义效果②的Condition：检查此卡是否成功进行上级召唤
function s.addcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_ADVANCE)
end
-- 定义效果②的Target：确认解放的素材数量大于0，并设置放置指示物的操作信息
function s.addtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetLabelObject():GetLabel()>0 end
	-- 设置操作信息：在此卡上放置指示物
	Duel.SetOperationInfo(0,CATEGORY_COUNTER,nil,0,tp,1)
end
-- 定义效果②的Operation：为这张卡放置与其上级召唤而解放的怪兽相同数量的贵宾指示物
function s.addc(e,tp,eg,ep,ev,re,r,rp)
	if e:GetHandler():IsRelateToChain() and e:GetHandler():IsFaceup() then
		e:GetHandler():AddCounter(0x75,e:GetLabelObject():GetLabel())
	end
end
-- 定义效果③的Condition：确认发动效果的是对方，且该效果可以被无效
function s.discon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查发动连锁效果的玩家是否为对方，并确认该效果是否可被无效
	return ep~=tp and Duel.IsChainDisablable(ev)
end
-- 定义效果③的Cost：取除此卡的1个贵宾指示物
function s.discost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsCanRemoveCounter(tp,0x75,1,REASON_COST) end
	e:GetHandler():RemoveCounter(tp,0x75,1,REASON_COST)
end
-- 定义效果③的Target：设置硬币投掷的操作信息
function s.distg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置操作信息：进行1次投掷硬币
	Duel.SetOperationInfo(0,CATEGORY_COIN,nil,0,ep,1)
end
-- 定义效果③的Operation：进行硬币投掷并根据猜测结果决定无效效果或使此卡攻击力减半
function s.disop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 向玩家发送选择硬币正反面的提示信息
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_COIN)  --"请选择硬币的正反面"
	-- 让玩家宣言硬币的正反面（进行猜测）
	local coin=Duel.AnnounceCoin(tp)
	-- 进行1次硬币投掷
	-- 注意：YGOPro 引擎中，AnnounceCoin 猜硬币时正面是 0 反面是 1；而 TossCoin 投硬币时正面是 1 反面是 0。
	-- 因此两者定义刚好相反，这里使用 coin ~= res 恰好代表的是“猜中（两者物理状态一致）”的场合。
	if coin~=res then
		-- 将该项发动的效果无效
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
