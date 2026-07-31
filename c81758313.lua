--一日万倍龍
local s,id,o=GetID()
-- 初始化卡片效果：注册魔力指示物允许、①结束阶段支付基本分放置指示物、②根据基本分差放置指示物、③指示物满足条件攻守上升、④去除指示物代替破坏效果
function s.initial_effect(c)
	c:EnableCounterPermit(0x78)
	-- ①：结束阶段支付100基本分才能发动。给这张卡放置1个魔力指示物。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_COUNTER)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_PHASE+PHASE_END)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCost(s.ctcost)
	e1:SetTarget(s.cttg)
	e1:SetOperation(s.ctop)
	c:RegisterEffect(e1)
	-- ②：自己的主要阶段，双方的基本分差有1000以上的场合才能发动。给这张卡放置那个数值每1000为1个的魔力指示物。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_COUNTER)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetTarget(s.cttg2)
	e2:SetOperation(s.ctop2)
	c:RegisterEffect(e2)
	-- ③：这张卡的魔力指示物有10个以上存在的场合，这张卡的攻击力·守备力上升10000。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e3:SetCode(EFFECT_UPDATE_ATTACK)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCondition(s.atkcon)
	e3:SetValue(10000)
	c:RegisterEffect(e3)
	local e4=e3:Clone()
	e4:SetCode(EFFECT_UPDATE_DEFENSE)
	c:RegisterEffect(e4)
	-- ④：这张卡被战斗·效果破坏的场合，可以作为代替把这张卡1个魔力指示物取除。
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_SINGLE)
	e5:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e5:SetCode(EFFECT_DESTROY_REPLACE)
	e5:SetRange(LOCATION_MZONE)
	e5:SetTarget(s.reptg)
	e5:SetOperation(s.repop)
	c:RegisterEffect(e5)
end
s.mentioned_counter={
	[0x78]=true,
}
-- ①效果发动Cost：支付100基本分
function s.ctcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- Cost检查：玩家基本分是否不低于100
	if chk==0 then return Duel.CheckLPCost(tp,100) end
	-- 扣除玩家100基本分
	Duel.PayLPCost(tp,100)
end
-- ①效果发动准备：检查自身是否可以放置1个魔力指示物
function s.cttg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsCanAddCounter(0x78,1) end
end
-- ①效果处理：给此卡放置1个魔力指示物
function s.ctop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToChain() and c:IsFaceup() then
		c:AddCounter(0x78,1)
	end
end
-- ②效果发动准备：计算基本分差并检查是否可以放置对应数量的魔力指示物
function s.cttg2(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 计算双方基本分差的绝对值
	local lp=math.abs(Duel.GetLP(tp)-Duel.GetLP(1-tp))
	local ct=math.floor(lp/1000)
	if chk==0 then return ct>0 and e:GetHandler():IsCanAddCounter(0x78,ct) end
end
-- ②效果处理：根据双方基本分差计算数量，给此卡放置对应数量的魔力指示物
function s.ctop2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 重新计算双方基本分差的绝对值
	local lp=math.abs(Duel.GetLP(tp)-Duel.GetLP(1-tp))
	local ct=math.floor(lp/1000)
	if c:IsRelateToChain() and c:IsFaceup() and ct>0 then
		c:AddCounter(0x78,ct)
	end
end
-- ③效果生效条件：此卡上的魔力指示物数量在10个以上
function s.atkcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetCounter(0x78)>=10
end
-- ④效果代替破坏准备：检查此卡是否因战斗·效果被破坏且能否去除1个魔力指示物
function s.reptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsReason(REASON_BATTLE+REASON_EFFECT) and not c:IsReason(REASON_REPLACE)
		and c:IsCanRemoveCounter(tp,0x78,1,REASON_EFFECT)
	end
	return true
end
-- ④效果代替破坏处理：去除此卡的1个魔力指示物代替破坏
function s.repop(e,tp,eg,ep,ev,re,r,rp)
	e:GetHandler():RemoveCounter(tp,0x78,1,REASON_EFFECT)
end
