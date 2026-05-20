--煌々たる逆転の女神
-- 效果：
-- ①：自己场上没有卡存在，自己手卡只有这1张卡的场合，对方怪兽的攻击宣言时把这张卡从手卡丢弃才能发动。对方场上的卡全部破坏。那之后，自己可以从卡组把1只怪兽特殊召唤。
function c72589042.initial_effect(c)
	-- ①：自己场上没有卡存在，自己手卡只有这1张卡的场合，对方怪兽的攻击宣言时把这张卡从手卡丢弃才能发动。对方场上的卡全部破坏。那之后，自己可以从卡组把1只怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(72589042,0))
	e1:SetCategory(CATEGORY_DESTROY+CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetRange(LOCATION_HAND)
	e1:SetCode(EVENT_ATTACK_ANNOUNCE)
	e1:SetCondition(c72589042.condition)
	e1:SetCost(c72589042.cost)
	e1:SetTarget(c72589042.target)
	e1:SetOperation(c72589042.operation)
	c:RegisterEffect(e1)
end
-- 设置效果的发动条件判定函数
function c72589042.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前是否为对方回合，且自己场上没有卡存在、手卡中除这张卡以外没有其他卡
	return tp~=Duel.GetTurnPlayer() and Duel.GetMatchingGroupCount(aux.TRUE,tp,LOCATION_ONFIELD+LOCATION_HAND,0,e:GetHandler())==0
end
-- 设置效果的发动代价（Cost）处理函数
function c72589042.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsDiscardable() end
	-- 将这张卡作为发动代价从手卡丢弃送去墓地
	Duel.SendtoGrave(c,REASON_COST+REASON_DISCARD)
end
-- 设置效果的发动准备与目标（Target）处理函数
function c72589042.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动检查阶段，确认对方场上是否存在至少1张卡
	if chk==0 then return Duel.IsExistingMatchingCard(aux.TRUE,tp,0,LOCATION_ONFIELD,1,nil) end
	-- 获取对方场上的所有卡
	local sg=Duel.GetMatchingGroup(aux.TRUE,tp,0,LOCATION_ONFIELD,nil)
	-- 设置连锁操作信息：破坏对方场上的所有卡
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,sg,sg:GetCount(),0,0)
	if sg:FilterCount(Card.IsDestructable,nil,e)>0 then
		-- 设置连锁操作信息：从卡组特殊召唤1只怪兽
		Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
	end
end
-- 过滤函数：筛选卡组中可以进行特殊召唤的怪兽
function c72589042.filter(c,e,tp)
	return c:IsType(TYPE_MONSTER) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 设置效果的运行（Operation）处理函数
function c72589042.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前对方场上的所有卡
	local sg=Duel.GetMatchingGroup(aux.TRUE,tp,0,LOCATION_ONFIELD,nil)
	-- 破坏对方场上的卡，并确认是否成功破坏、自己场上是否有空余怪兽区域以及卡组中是否存在可特殊召唤的怪兽
	if Duel.Destroy(sg,REASON_EFFECT)~=0 and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.IsExistingMatchingCard(c72589042.filter,tp,LOCATION_DECK,0,1,nil,e,tp)
		-- 询问玩家是否选择进行特殊召唤
		and Duel.SelectYesNo(tp,aux.Stringid(72589042,1)) then  --"是否特殊召唤？"
		-- 中断效果处理，使破坏与之后的特殊召唤不视为同时处理
		Duel.BreakEffect()
		-- 让玩家从卡组中选择1只满足特殊召唤条件的怪兽
		local tc=Duel.SelectMatchingCard(tp,c72589042.filter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
		-- 将选中的怪兽以表侧表示特殊召唤到自己场上
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
