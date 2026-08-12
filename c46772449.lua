--励輝士 ヴェルズビュート
-- 效果：
-- 4星怪兽×2
-- ①：自己主要阶段以及对方战斗阶段，对方的手卡·场上的卡数量比自己的手卡·场上的卡数量多的场合，把这张卡1个超量素材取除才能发动（同一连锁上最多1次）。场上的其他卡全部破坏。这个效果的发动后，直到回合结束时对方受到的全部伤害变成0。
function c46772449.initial_effect(c)
	-- 为卡片添加等级为4、需要2只怪兽进行XYZ召唤的手续
	aux.AddXyzProcedure(c,nil,4,2)
	c:EnableReviveLimit()
	-- ①：自己主要阶段以及对方战斗阶段，对方的手卡·场上的卡数量比自己的手卡·场上的卡数量多的场合，把这张卡1个超量素材取除才能发动（同一连锁上最多1次）。场上的其他卡全部破坏。这个效果的发动后，直到回合结束时对方受到的全部伤害变成0。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(46772449,0))  --"破坏"
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(TIMING_SPSUMMON,TIMING_BATTLE_START)
	e1:SetCountLimit(1,EFFECT_COUNT_CODE_CHAIN)
	e1:SetCondition(c46772449.condition)
	e1:SetCost(c46772449.cost)
	e1:SetTarget(c46772449.target)
	e1:SetOperation(c46772449.operation)
	c:RegisterEffect(e1)
end
-- 判断是否满足效果发动条件：对方手卡和场上的卡数量多于自己手卡和场上的卡数量，并且当前处于正确的阶段
function c46772449.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 统计己方手卡和场上的卡数量
	local ct1=Duel.GetFieldGroupCount(tp,LOCATION_ONFIELD+LOCATION_HAND,0)
	-- 统计对方手卡和场上的卡数量
	local ct2=Duel.GetFieldGroupCount(tp,0,LOCATION_ONFIELD+LOCATION_HAND)
	if ct1>=ct2 then return false end
	-- 获取当前游戏阶段
	local ph=Duel.GetCurrentPhase()
	-- 判断是否为己方回合并处于主要阶段1或主要阶段2
	if Duel.GetTurnPlayer()==tp then
		return ph==PHASE_MAIN1 or ph==PHASE_MAIN2
	else
		return (ph>=PHASE_BATTLE_START and ph<=PHASE_BATTLE)
	end
end
-- 支付效果发动的代价：从自身取除1个超量素材
function c46772449.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:CheckRemoveOverlayCard(tp,1,REASON_COST) end
	c:RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- 设置效果的目标：检索场上所有卡作为破坏对象
function c46772449.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否存在满足条件的场上卡片用于破坏
	if chk==0 then return Duel.IsExistingMatchingCard(aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,e:GetHandler()) end
	-- 获取场上所有满足条件的卡片组
	local g=Duel.GetMatchingGroup(aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,e:GetHandler())
	-- 设置连锁操作信息，指定将要破坏的卡片数量
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
end
-- 执行效果的处理：使对方受到的伤害归零并破坏场上其他卡
function c46772449.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 场上的其他卡全部破坏。这个效果的发动后，直到回合结束时对方受到的全部伤害变成0。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CHANGE_DAMAGE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(0,1)
	e1:SetValue(0)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 注册一个影响对方受到伤害数值的效果，使其变为0
	Duel.RegisterEffect(e1,tp)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_NO_EFFECT_DAMAGE)
	e2:SetReset(RESET_PHASE+PHASE_END)
	-- 注册一个使对方不能受到效果伤害的效果
	Duel.RegisterEffect(e2,tp)
	-- 获取场上所有满足条件的卡片组（排除自身）
	local g=Duel.GetMatchingGroup(aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,aux.ExceptThisCard(e))
	-- 将指定的卡片组全部破坏
	Duel.Destroy(g,REASON_EFFECT)
end
