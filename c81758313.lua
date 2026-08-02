--一日万倍龍
local s,id,o=GetID()
-- 允许该卡放置指示物，注册结束阶段触发和起动效果，注册基于指示物数量增减攻守的效果，以及代破效果。
function s.initial_effect(c)
	c:EnableCounterPermit(0x78)
	-- 双方的结束阶段：可以支付100基本分；给这张卡放置1个指示物。
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
	-- 自己的主要阶段才能发动。给这张卡放置双方基本分差值每1000数量的指示物。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_COUNTER)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetTarget(s.cttg2)
	e2:SetOperation(s.ctop2)
	c:RegisterEffect(e2)
	-- 这张卡的指示物数量是10个以上的场合，这张卡的攻击力·守备力上升10000。
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
	-- 这张卡被战斗·效果破坏的场合，可以作为代替把这张卡1个指示物取除。
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
-- 检查玩家能否支付100基本分，作为代价支付100基本分
function s.ctcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查当前玩家是否能够支付100基本分
	if chk==0 then return Duel.CheckLPCost(tp,100) end
	-- 让当前玩家支付100基本分
	Duel.PayLPCost(tp,100)
end
-- 检查这张卡是否可以放置1个0x78指示物
function s.cttg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsCanAddCounter(0x78,1) end
end
-- 如果这张卡在场上表侧表示存在且未离开连锁，则给它放置1个0x78指示物
function s.ctop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToChain() and c:IsFaceup() then
		c:AddCounter(0x78,1)
	end
end
-- 计算双方基本分差值的绝对值，千位数大于0时检查能否给该卡放置对应数量指示物
function s.cttg2(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 计算当前双方基本分差值的绝对值
	local lp=math.abs(Duel.GetLP(tp)-Duel.GetLP(1-tp))
	local ct=math.floor(lp/1000)
	if chk==0 then return ct>0 and e:GetHandler():IsCanAddCounter(0x78,ct) end
end
-- 根据双方基本分差值的绝对值计算能放置的指示物数量并实际放置在卡片上
function s.ctop2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 计算当前双方基本分差值的绝对值
	local lp=math.abs(Duel.GetLP(tp)-Duel.GetLP(1-tp))
	local ct=math.floor(lp/1000)
	if c:IsRelateToChain() and c:IsFaceup() and ct>0 then
		c:AddCounter(0x78,ct)
	end
end
-- 判断这张卡上的0x78指示物数量是否大于等于10
function s.atkcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetCounter(0x78)>=10
end
-- 检查这张卡是否将要被战斗或效果破坏且并非代替破坏，并且能否取除1个0x78指示物
function s.reptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsReason(REASON_BATTLE+REASON_EFFECT) and not c:IsReason(REASON_REPLACE)
		and c:IsCanRemoveCounter(tp,0x78,1,REASON_EFFECT)
	end
	return true
end
-- 从这张卡上取除1个0x78指示物来代替破坏
function s.repop(e,tp,eg,ep,ev,re,r,rp)
	e:GetHandler():RemoveCounter(tp,0x78,1,REASON_EFFECT)
end
