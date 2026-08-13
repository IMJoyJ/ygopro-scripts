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
-- 定义效果发动前需要支付的代价：检测并支付500基本分，作为发动卡片的COST。
function c38834303.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在代价检测阶段（chk==0）确认玩家能否支付500基本分，用于判断该效果是否满足发动条件。
	if chk==0 then return Duel.CheckLPCost(tp,500) end
	-- 实际扣除玩家500基本分作为发动代价。
	Duel.PayLPCost(tp,500)
end
-- 定义筛选条件：卡上存在任意指示物（总指示物数量不为0）。
function c38834303.filter(c)
	return c:GetCounter(0)~=0
end
-- 定义效果的发动条件：场上必须存在至少1张带有指示物的卡，否则不能发动。
function c38834303.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动时检测场上是否至少存在1张带有指示物的卡，作为效果能否发动的判定。
	if chk==0 then return Duel.IsExistingMatchingCard(c38834303.filter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
end
-- 效果处理：检索场上所有带有指示物的卡，逐一取除其全部指示物，并在存在取除时触发指示物取除的时点。
function c38834303.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取场上（双方怪兽区域和魔陷区域）所有带有指示物的卡，组成待处理集合。
	local sg=Duel.GetMatchingGroup(c38834303.filter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
	local tc=sg:GetFirst()
	local count=0
	while tc do
		count=count+tc:GetCounter(0x100e)
		tc:RemoveCounter(tp,0,0,0)
		tc=sg:GetNext()
	end
	if count>0 then
		-- 若本次合计取除的指示物数量大于0，则以本卡为来源触发“指示物被取除”的事件（EVENT_REMOVE_COUNTER），并将数量作为事件参数，以便其他卡进行联动。
		Duel.RaiseEvent(e:GetHandler(),EVENT_REMOVE_COUNTER+0x100e,e,REASON_EFFECT,tp,tp,count)
	end
end
