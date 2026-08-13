--あまびえさん
-- 效果：
-- ①：自己主要阶段1开始时，把手卡的这张卡给对方观看才能发动。双方玩家回复300基本分。
function c2139640.initial_effect(c)
	-- ①：自己主要阶段1开始时，把手卡的这张卡给对方观看才能发动。双方玩家回复300基本分。
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
-- 定义效果发动条件：必须是自己的主要阶段1，并且该阶段尚未进行过任何操作（即处于阶段开始时），才可发动。
function c2139640.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前阶段是否为主要阶段1且本阶段尚无操作（阶段开始时点）。
	return Duel.GetCurrentPhase()==PHASE_MAIN1 and not Duel.CheckPhaseActivity()
end
-- 定义发动代价判定：效果发动时确认手牌中的这张卡当前为非公开状态，满足“给对方观看”的代价要求。
function c2139640.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return not e:GetHandler():IsPublic() end
end
-- 定义效果发动时的目标处理：本效果无需选择对象，必定可以发动，并登记操作信息为回复分类，回复双方玩家300基本分。
function c2139640.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置本次操作信息：效果为回复，涉及双方玩家，每个玩家回复300基本分。
	Duel.SetOperationInfo(0,CATEGORY_RECOVER,nil,0,PLAYER_ALL,300)
end
-- 定义效果处理时的操作：实际让双方玩家各回复300基本分。
function c2139640.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 以效果原因让当前玩家回复300基本分。
	Duel.Recover(tp,300,REASON_EFFECT)
	-- 以效果原因让对方玩家回复300基本分。
	Duel.Recover(1-tp,300,REASON_EFFECT)
end
