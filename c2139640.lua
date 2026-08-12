--あまびえさん
-- 效果：
-- ①：自己主要阶段1开始时，把手卡的这张卡给对方观看才能发动。双方玩家回复300基本分。
function c2139640.initial_effect(c)
	-- 创建效果并设置效果描述、分类、类型、适用区域、发动条件、费用、目标和效果处理
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(2139640,0))
	e1:SetCategory(CATEGORY_RECOVER)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(c2139640.condition)
	e1:SetCost(c2139640.cost)
	e1:SetTarget(c2139640.target)
	e1:SetOperation(c2139640.operation)
	c:RegisterEffect(e1)
end
-- 效果发动的条件判断
function c2139640.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 当前阶段为自己的主要阶段1且未进行过阶段动作
	return Duel.GetCurrentPhase()==PHASE_MAIN1 and not Duel.CheckPhaseActivity()
end
-- 效果发动的费用处理
function c2139640.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return not e:GetHandler():IsPublic() end
end
-- 设置效果的目标为双方各回复300基本分
function c2139640.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置连锁操作信息为双方各回复300基本分
	Duel.SetOperationInfo(0,CATEGORY_RECOVER,nil,0,PLAYER_ALL,300)
end
-- 效果处理时执行双方各回复300基本分
function c2139640.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 使自己回复300基本分
	Duel.Recover(tp,300,REASON_EFFECT)
	-- 使对方回复300基本分
	Duel.Recover(1-tp,300,REASON_EFFECT)
end
