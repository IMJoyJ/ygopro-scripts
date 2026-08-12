--スプライト・スマッシャーズ
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：可以从自己的手卡·墓地把「护宝炮妖」卡、「兽带斗神」卡、「卫星闪灵」卡的其中1张除外，从以下效果选择1个发动。
-- ●从卡组把1只「护宝炮妖」怪兽特殊召唤。
-- ●从自己墓地把1只「兽带斗神」怪兽特殊召唤。
-- ●自己场上1只2星·2阶·连接2的怪兽和对方场上1张卡除外。
function c88836438.initial_effect(c)
	-- 这个卡名的卡在1回合只能发动1张。①：可以从自己的手卡·墓地把「护宝炮妖」卡、「兽带斗神」卡、「卫星闪灵」卡的其中1张除外，从以下效果选择1个发动。●从卡组把1只「护宝炮妖」怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(88836438,0))  --"从卡组把1只「护宝炮妖」怪兽特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,88836438+EFFECT_COUNT_CODE_OATH)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e1:SetCost(c88836438.cost)
	e1:SetTarget(c88836438.sptg1)
	e1:SetOperation(c88836438.spop1)
	c:RegisterEffect(e1)
	-- 这个卡名的卡在1回合只能发动1张。①：可以从自己的手卡·墓地把「护宝炮妖」卡、「兽带斗神」卡、「卫星闪灵」卡的其中1张除外，从以下效果选择1个发动。●从自己墓地把1只「兽带斗神」怪兽特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(88836438,1))  --"从自己墓地选1只「兽带斗神」怪兽特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_ACTIVATE)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetCountLimit(1,88836438+EFFECT_COUNT_CODE_OATH)
	e2:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e2:SetCost(c88836438.cost)
	e2:SetTarget(c88836438.sptg2)
	e2:SetOperation(c88836438.spop2)
	c:RegisterEffect(e2)
	-- 这个卡名的卡在1回合只能发动1张。①：可以从自己的手卡·墓地把「护宝炮妖」卡、「兽带斗神」卡、「卫星闪灵」卡的其中1张除外，从以下效果选择1个发动。●自己场上1只2星·2阶·连接2的怪兽和对方场上1张卡除外。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(88836438,2))  --"选自己和对方场上各1张卡除外"
	e3:SetCategory(CATEGORY_REMOVE)
	e3:SetType(EFFECT_TYPE_ACTIVATE)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetCountLimit(1,88836438+EFFECT_COUNT_CODE_OATH)
	e3:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e3:SetCost(c88836438.cost)
	e3:SetTarget(c88836438.rmtg)
	e3:SetOperation(c88836438.rmop)
	c:RegisterEffect(e3)
end
-- 过滤条件：手卡·墓地的「护宝炮妖」卡、「兽带斗神」卡、「卫星闪灵」卡，且可以因代价值除外
function c88836438.cfilter(c)
	return c:IsSetCard(0x155,0x179,0x180) and c:IsAbleToRemoveAsCost()
end
-- 发动代价：从自己的手卡·墓地把1张「护宝炮妖」卡、「兽带斗神」卡或「卫星闪灵」卡除外
function c88836438.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己手卡·墓地是否存在至少1张满足过滤条件的卡
	if chk==0 then return Duel.IsExistingMatchingCard(c88836438.cfilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,e:GetHandler()) end
	-- 提示玩家选择要除外的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 玩家选择1张满足过滤条件的手卡或墓地的卡
	local g=Duel.SelectMatchingCard(tp,c88836438.cfilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,1,nil)
	-- 将选中的卡作为发动代价表侧表示除外
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
-- 过滤条件：卡组中可以特殊召唤的「护宝炮妖」怪兽
function c88836438.spfilter1(c,e,tp)
	return c:IsSetCard(0x155) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果1（从卡组特召「护宝炮妖」）的发动准备与合法性检查
function c88836438.sptg1(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有可用的怪兽区域空格
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 并且检查卡组中是否存在至少1只满足过滤条件的「护宝炮妖」怪兽
		and Duel.IsExistingMatchingCard(c88836438.spfilter1,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 向对方玩家提示自己选择发动了该效果
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
	-- 设置效果处理信息：从卡组特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 效果1（从卡组特召「护宝炮妖」）的效果处理
function c88836438.spop1(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否仍有可用的怪兽区域空格，若无则不处理
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 玩家从卡组选择1只满足过滤条件的「护宝炮妖」怪兽
	local g=Duel.SelectMatchingCard(tp,c88836438.spfilter1,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的怪兽表侧表示特殊召唤到自己场上
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 过滤条件：墓地中可以特殊召唤的「兽带斗神」怪兽
function c88836438.spfilter2(c,e,tp)
	return c:IsSetCard(0x179) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果2（从墓地特召「兽带斗神」）的发动准备与合法性检查
function c88836438.sptg2(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有可用的怪兽区域空格
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 并且检查自己墓地中是否存在至少1只满足过滤条件的「兽带斗神」怪兽
		and Duel.IsExistingMatchingCard(c88836438.spfilter2,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 向对方玩家提示自己选择发动了该效果
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
	-- 设置效果处理信息：从墓地特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE)
end
-- 效果2（从墓地特召「兽带斗神」）的效果处理
function c88836438.spop2(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否仍有可用的怪兽区域空格，若无则不处理
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 玩家从墓地选择1只满足过滤条件且不受王家长眠之谷影响的「兽带斗神」怪兽
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c88836438.spfilter2),tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的怪兽表侧表示特殊召唤到自己场上
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 过滤条件：自己场上表侧表示的2星、2阶或连接2的怪兽，且可以被除外
function c88836438.rmfilter(c)
	return (c:IsLevel(2) or c:IsRank(2) or c:IsLink(2)) and c:IsFaceup() and c:IsAbleToRemove()
end
-- 效果3（除外双方场上卡片）的发动准备与合法性检查
function c88836438.rmtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否存在至少1只满足过滤条件的2星·2阶·连接2的怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c88836438.rmfilter,tp,LOCATION_MZONE,0,1,nil)
		-- 并且检查对方场上是否存在至少1张可以被除外的卡
		and Duel.IsExistingMatchingCard(Card.IsAbleToRemove,tp,0,LOCATION_ONFIELD,1,nil,tp) end
	-- 向对方玩家提示自己选择发动了该效果
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
	-- 设置效果处理信息：将双方场上的共2张卡除外
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,2,PLAYER_ALL,LOCATION_ONFIELD)
end
-- 效果3（除外双方场上卡片）的效果处理
function c88836438.rmop(e,tp,eg,ep,ev,re,r,rp)
	if not c88836438.rmtg(e,tp,eg,ep,ev,re,r,rp,0) then return end
	-- 提示玩家选择要除外的卡（自己场上的怪兽）
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 玩家选择自己场上1只满足过滤条件的2星·2阶·连接2的怪兽
	local g1=Duel.SelectMatchingCard(tp,c88836438.rmfilter,tp,LOCATION_MZONE,0,1,1,nil)
	-- 提示玩家选择要除外的卡（对方场上的卡）
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 玩家选择对方场上1张可以被除外的卡
	local g2=Duel.SelectMatchingCard(tp,Card.IsAbleToRemove,tp,0,LOCATION_ONFIELD,1,1,nil,tp)
	g1:Merge(g2)
	-- 选中卡片的视觉提示效果
	Duel.HintSelection(g1)
	-- 将选中的双方场上的卡表侧表示除外
	Duel.Remove(g1,POS_FACEUP,REASON_EFFECT)
end
