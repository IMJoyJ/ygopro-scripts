--励輝士 ヴェルズビュート
-- 效果：
-- 4星怪兽×2
-- ①：自己主要阶段以及对方战斗阶段，对方的手卡·场上的卡数量比自己的手卡·场上的卡数量多的场合，把这张卡1个超量素材取除才能发动（同一连锁上最多1次）。场上的其他卡全部破坏。这个效果的发动后，直到回合结束时对方受到的全部伤害变成0。
function c46772449.initial_effect(c)
	-- 为这张卡添加XYZ召唤手续：用任意2只4星怪兽叠放来XYZ召唤。
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
-- 判定发动条件：对方手牌·场上合计数量多于自己，且处于自己主要阶段或对方战斗阶段。
function c46772449.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 获取自己场上和手牌的卡总数（ct1）。
	local ct1=Duel.GetFieldGroupCount(tp,LOCATION_ONFIELD+LOCATION_HAND,0)
	-- 获取对方场上和手牌的卡总数（ct2）。
	local ct2=Duel.GetFieldGroupCount(tp,0,LOCATION_ONFIELD+LOCATION_HAND)
	if ct1>=ct2 then return false end
	-- 获取当前阶段。
	local ph=Duel.GetCurrentPhase()
	-- 判断当前回合玩家是否是自己，以区分自己主要阶段与对方战斗阶段的发动时机。
	if Duel.GetTurnPlayer()==tp then
		return ph==PHASE_MAIN1 or ph==PHASE_MAIN2
	else
		return (ph>=PHASE_BATTLE_START and ph<=PHASE_BATTLE)
	end
end
-- 定义发动代价：从这张卡取除1个超量素材。
function c46772449.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:CheckRemoveOverlayCard(tp,1,REASON_COST) end
	c:RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- 定义目标：发动时无需取对象，但需保证场上存在这张卡以外的卡；将场上除自身以外的所有卡作为预定破坏对象并登记操作信息。
function c46772449.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查场上是否存在除自身以外的卡，若不存在则不能发动。
	if chk==0 then return Duel.IsExistingMatchingCard(aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,e:GetHandler()) end
	-- 取得场上除自身以外的所有卡，作为不取对象的破坏对象。
	local g=Duel.GetMatchingGroup(aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,e:GetHandler())
	-- 登记破坏操作信息，记录将破坏的卡及数量。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
end
-- 效果处理：先给对手附加直到回合结束时“受到的伤害变成0”的效果，再破坏场上其他卡。
function c46772449.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 场上的其他卡全部破坏。这个效果的发动后，直到回合结束时对方受到的全部伤害变成0。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CHANGE_DAMAGE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(0,1)
	e1:SetValue(0)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将“对方受到的全部伤害变为0”的效果注册到对方玩家，持续到回合结束。
	Duel.RegisterEffect(e1,tp)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_NO_EFFECT_DAMAGE)
	e2:SetReset(RESET_PHASE+PHASE_END)
	-- 将“对方已适用效果伤害变为0”的标记效果注册到对方玩家，持续到回合结束。
	Duel.RegisterEffect(e2,tp)
	-- 获取场上除自身以外的所有卡，作为破坏对象。
	local g=Duel.GetMatchingGroup(aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,aux.ExceptThisCard(e))
	-- 以效果原因将这些卡全部破坏。
	Duel.Destroy(g,REASON_EFFECT)
end
