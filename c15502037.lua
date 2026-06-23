--電磁石の戦士γ
-- 效果：
-- 「电磁石战士γ」的①的效果1回合只能使用1次。
-- ①：这张卡召唤·特殊召唤成功的场合才能发动。从手卡把「电磁石战士γ」以外的1只4星以下的「磁石战士」怪兽特殊召唤。
-- ②：对方回合把这张卡解放才能发动。从卡组把1只4星「磁石战士」怪兽特殊召唤。
function c15502037.initial_effect(c)
	-- ①：这张卡召唤·特殊召唤成功的场合才能发动。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(15502037,0))  --"加入手卡"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_TRIGGER_O+EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetCountLimit(1,15502037)
	e1:SetTarget(c15502037.target)
	e1:SetOperation(c15502037.operation)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
	-- ②：对方回合把这张卡解放才能发动。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(15502037,1))  --"特殊召唤"
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetRange(LOCATION_MZONE)
	e3:SetHintTiming(0,TIMING_END_PHASE)
	e3:SetCondition(c15502037.spcon)
	e3:SetCost(c15502037.spcost)
	e3:SetTarget(c15502037.sptg)
	e3:SetOperation(c15502037.spop)
	c:RegisterEffect(e3)
end
-- 过滤手卡中除电磁石战士γ外的4星以下磁石战士怪兽
function c15502037.filter(c,e,tp)
	return c:IsSetCard(0x2066) and not c:IsCode(15502037) and c:IsLevelBelow(4) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果发动时的检查条件：手卡有满足条件的怪兽且场上存在召唤区域
function c15502037.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查场上是否存在召唤区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查手卡是否存在满足条件的怪兽
		and Duel.IsExistingMatchingCard(c15502037.filter,tp,LOCATION_HAND,0,1,nil,e,tp) end
	-- 设置效果处理时将要特殊召唤的卡的信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
-- 效果处理函数：选择并特殊召唤手卡中的怪兽
function c15502037.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 检查场上是否存在召唤区域
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从手卡中选择满足条件的怪兽
	local g=Duel.SelectMatchingCard(tp,c15502037.filter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的怪兽特殊召唤到场上
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 效果发动条件：当前回合不是自己
function c15502037.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前回合玩家是否为对方
	return Duel.GetTurnPlayer()~=tp
end
-- 效果发动时的费用支付：解放自身
function c15502037.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsReleasable() end
	-- 将自身解放作为效果的费用
	Duel.Release(e:GetHandler(),REASON_COST)
end
-- 过滤卡组中4星的磁石战士怪兽
function c15502037.spfilter(c,e,tp)
	return c:IsSetCard(0x2066) and c:IsLevel(4) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果发动时的检查条件：卡组有满足条件的怪兽且场上存在召唤区域
function c15502037.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查场上是否存在召唤区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>-1
		-- 检查卡组是否存在满足条件的怪兽
		and Duel.IsExistingMatchingCard(c15502037.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置效果处理时将要特殊召唤的卡的信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 效果处理函数：选择并特殊召唤卡组中的怪兽
function c15502037.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查场上是否存在召唤区域
	if Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then
		-- 提示玩家选择要特殊召唤的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 从卡组中选择满足条件的怪兽
		local g=Duel.SelectMatchingCard(tp,c15502037.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
		if g:GetCount()>0 then
			-- 将选中的怪兽特殊召唤到场上
			Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
		end
	end
end
