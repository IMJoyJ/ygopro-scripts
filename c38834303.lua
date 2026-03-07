--カウンタークリーナー
-- 效果：
-- 支付500基本分。场上存在的全部指示物取除。
function c38834303.initial_effect(c)
	-- 支付500基本分。场上存在的全部指示物取除。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCost(c38834303.cost)
	e1:SetTarget(c38834303.target)
	e1:SetOperation(c38834303.activate)
	c:RegisterEffect(e1)
end
-- 检查玩家是否能支付500基本分
function c38834303.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家是否能支付500基本分
	if chk==0 then return Duel.CheckLPCost(tp,500) end
	-- 让玩家支付500基本分
	Duel.PayLPCost(tp,500)
end
-- 过滤函数，检查场上是否存在带有指示物的卡
function c38834303.filter(c)
	return c:GetCounter(0)~=0
end
-- 检查场上是否存在至少一张带有指示物的卡
function c38834303.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查场上是否存在至少一张带有指示物的卡
	if chk==0 then return Duel.IsExistingMatchingCard(c38834303.filter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
end
-- 检索场上所有带有指示物的卡并移除其指示物
function c38834303.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 检索场上所有带有指示物的卡
	local sg=Duel.GetMatchingGroup(c38834303.filter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
	local tc=sg:GetFirst()
	local count=0
	while tc do
		count=count+tc:GetCounter(0x100e)
		tc:RemoveCounter(tp,0,0,0)
		tc=sg:GetNext()
	end
	if count>0 then
		-- 触发指示物被移除的时点事件
		Duel.RaiseEvent(e:GetHandler(),EVENT_REMOVE_COUNTER+0x100e,e,REASON_EFFECT,tp,tp,count)
	end
end
