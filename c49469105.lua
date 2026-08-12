--融合破棄
-- 效果：
-- 把1张「融合」从手卡丢弃去墓地发动。把融合卡组存在的1只融合怪兽送去墓地，那只融合怪兽记述的1只融合素材怪兽从手卡特殊召唤。这个效果特殊召唤的怪兽在这个回合的结束阶段时送去墓地。
function c49469105.initial_effect(c)
	-- 把1张「融合」从手卡丢弃去墓地发动。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCost(c49469105.cost)
	e1:SetTarget(c49469105.target)
	e1:SetOperation(c49469105.operation)
	c:RegisterEffect(e1)
end
-- 过滤函数，检查以玩家来看的自己的手牌位置是否存在至少1张满足条件的「融合」卡。
function c49469105.cfilter(c)
	return c:IsCode(24094653) and c:IsDiscardable() and c:IsAbleToGraveAsCost()
end
-- 检索满足条件的「融合」卡并将其丢弃作为代价。
function c49469105.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查以玩家来看的自己的手牌位置是否存在至少1张满足条件的「融合」卡。
	if chk==0 then return Duel.IsExistingMatchingCard(c49469105.cfilter,tp,LOCATION_HAND,0,1,nil) end
	-- 让玩家选择并以代价原因丢弃满足筛选条件的1张手卡。
	Duel.DiscardHand(tp,c49469105.cfilter,1,1,REASON_COST+REASON_DISCARD)
end
-- 过滤函数，检查以玩家来看的自己的额外卡组位置是否存在至少1只融合怪兽且该怪兽的素材列表中存在手牌中的怪兽。
function c49469105.filter1(c,g)
	return c:IsType(TYPE_FUSION) and g:IsExists(c49469105.filter2,1,nil,c)
end
-- 过滤函数，检测指定融合怪兽是否包含指定卡号作为其融合素材之一。
function c49469105.filter2(c,fc)
	-- 检测指定融合怪兽是否包含指定卡号作为其融合素材之一。
	return aux.IsMaterialListCode(fc,c:GetCode())
end
-- 过滤函数，检查以玩家来看的自己的手牌位置是否存在至少1张可以特殊召唤的怪兽。
function c49469105.spfilter(c,e,tp)
	return c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 设置连锁处理时的目标信息，确定效果发动后将要特殊召唤的怪兽数量为1。
function c49469105.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取满足条件的可特殊召唤怪兽组。
	local g=Duel.GetMatchingGroup(c49469105.spfilter,tp,LOCATION_HAND,0,nil,e,tp)
	-- 检查玩家场上是否有足够的空位来特殊召唤怪兽。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查以玩家来看的自己的额外卡组位置是否存在至少1只融合怪兽且该怪兽的素材列表中存在手牌中的怪兽。
		and Duel.IsExistingMatchingCard(c49469105.filter1,tp,LOCATION_EXTRA,0,1,nil,g) end
	-- 设置当前处理的连锁的操作信息，确定效果处理后将要特殊召唤的怪兽数量为1。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
-- 执行效果处理流程，包括选择并送入墓地的融合怪兽、从手牌中特殊召唤其素材怪兽，并在结束阶段将其送回墓地。
function c49469105.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 检查玩家场上是否有足够的空位来特殊召唤怪兽。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 获取满足条件的可特殊召唤怪兽组。
	local g=Duel.GetMatchingGroup(c49469105.spfilter,tp,LOCATION_HAND,0,nil,e,tp)
	-- 提示玩家选择要送去墓地的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 从额外卡组中选择满足条件的融合怪兽。
	local exg=Duel.SelectMatchingCard(tp,c49469105.filter1,tp,LOCATION_EXTRA,0,1,1,nil,g)
	if exg:GetCount()>0 then
		-- 将选中的融合怪兽送入墓地。
		Duel.SendtoGrave(exg,REASON_EFFECT)
		-- 提示玩家选择要特殊召唤的卡。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		local sg=g:FilterSelect(tp,c49469105.filter2,1,1,nil,exg:GetFirst())
		-- 将符合条件的融合素材怪兽从手牌特殊召唤到场上。
		Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)
		-- 创建一个在结束阶段触发的效果，用于将特殊召唤的怪兽送回墓地。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
		e1:SetRange(LOCATION_MZONE)
		e1:SetCode(EVENT_PHASE+PHASE_END)
		e1:SetOperation(c49469105.tgop)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		e1:SetCountLimit(1)
		sg:GetFirst():RegisterEffect(e1,true)
	end
end
-- 效果处理函数，将自身送入墓地。
function c49469105.tgop(e,tp,eg,ep,ev,re,r,rp)
	-- 将自身送入墓地。
	Duel.SendtoGrave(e:GetHandler(),REASON_EFFECT)
end
