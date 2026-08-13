--融合破棄
-- 效果：
-- 把1张「融合」从手卡丢弃去墓地发动。把融合卡组存在的1只融合怪兽送去墓地，那只融合怪兽记述的1只融合素材怪兽从手卡特殊召唤。这个效果特殊召唤的怪兽在这个回合的结束阶段时送去墓地。
function c49469105.initial_effect(c)
	-- 把1张「融合」从手卡丢弃去墓地发动。把融合卡组存在的1只融合怪兽送去墓地，那只融合怪兽记述的1只融合素材怪兽从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCost(c49469105.cost)
	e1:SetTarget(c49469105.target)
	e1:SetOperation(c49469105.operation)
	c:RegisterEffect(e1)
end
-- 定义代价筛选函数：选择手卡中的卡名「融合」（24094653），且能够丢弃并能作为代价送去墓地。
function c49469105.cfilter(c)
	return c:IsCode(24094653) and c:IsDiscardable() and c:IsAbleToGraveAsCost()
end
-- 定义发动代价：在检测阶段确认手卡存在可丢弃的「融合」；实际发动时从手卡选择并丢弃1张「融合」作为代价。
function c49469105.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 代价检测阶段：检查手卡中是否存在至少1张满足cfilter条件的「融合」卡，以此决定能否发动。
	if chk==0 then return Duel.IsExistingMatchingCard(c49469105.cfilter,tp,LOCATION_HAND,0,1,nil) end
	-- 实际执行代价：从手卡选择并丢弃1张满足cfilter条件的「融合」卡，丢弃原因设为“代价丢弃”。
	Duel.DiscardHand(tp,c49469105.cfilter,1,1,REASON_COST+REASON_DISCARD)
end
-- 定义额外卡组融合怪兽的筛选条件：该卡是融合怪兽，并且其融合素材中存在手卡中可特殊召唤的怪兽（由filter2判断）。
function c49469105.filter1(c,g)
	return c:IsType(TYPE_FUSION) and g:IsExists(c49469105.filter2,1,nil,c)
end
-- 定义手卡素材匹配条件：判断手卡怪兽c是否为融合怪兽fc的融合素材之一。
function c49469105.filter2(c,fc)
	-- 具体判断：检查融合怪兽fc的素材列表是否记载了手卡怪兽c的当前卡名。
	return aux.IsMaterialListCode(fc,c:GetCode())
end
-- 定义特殊召唤条件筛选：判断手卡怪兽能否被当前效果特殊召唤（检查召唤条件与苏生限制）。
function c49469105.spfilter(c,e,tp)
	return c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 目标函数：获取手卡可特殊召唤的怪兽组，并检测主怪兽区是否有空位且额外卡组是否存在符合条件的融合怪兽，满足才可发动。
function c49469105.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取手卡中所有可供本效果特殊召唤的怪兽，存入组g，供后续选择使用。
	local g=Duel.GetMatchingGroup(c49469105.spfilter,tp,LOCATION_HAND,0,nil,e,tp)
	-- 目标检测：确认自己的主怪兽区存在空位，以保证特殊召唤有地方可放。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 目标检测：确认额外卡组中存在至少1只融合怪兽，且其融合素材中包含手卡可特殊召唤的怪兽。
		and Duel.IsExistingMatchingCard(c49469105.filter1,tp,LOCATION_EXTRA,0,1,nil,g) end
	-- 登记操作信息：声明本效果将要把1只怪兽从手卡特殊召唤，供连锁判定等系统参考。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
-- 效果处理函数：从额外卡组选择1只融合怪兽送去墓地，再从手卡选择那只融合怪兽记述的1只融合素材怪兽特殊召唤，并为该怪兽附加“结束阶段送去墓地”的效果。
function c49469105.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 效果处理前检查：主怪兽区没有空位时，终止效果处理。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 重新获取手卡中可特殊召唤的怪兽组，用于处理时选择素材。
	local g=Duel.GetMatchingGroup(c49469105.spfilter,tp,LOCATION_HAND,0,nil,e,tp)
	-- 弹出选择提示：请选择要送去墓地的卡（用于选择额外卡组的融合怪兽）。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 从额外卡组选择1只满足filter1条件的融合怪兽（其素材包含手卡可特殊召唤的怪兽）。
	local exg=Duel.SelectMatchingCard(tp,c49469105.filter1,tp,LOCATION_EXTRA,0,1,1,nil,g)
	if exg:GetCount()>0 then
		-- 将选择的融合怪兽以效果原因送去墓地。
		Duel.SendtoGrave(exg,REASON_EFFECT)
		-- 弹出选择提示：请选择要特殊召唤的卡（用于选择手卡中的融合素材怪兽）。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		local sg=g:FilterSelect(tp,c49469105.filter2,1,1,nil,exg:GetFirst())
		-- 将选择的素材怪兽以表侧表示特殊召唤到自己的场上。
		Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)
		-- 这个效果特殊召唤的怪兽在这个回合的结束阶段时送去墓地。
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
-- 定义结束阶段处理函数：将效果持有者（被特殊召唤的怪兽）在结束阶段送去墓地。
function c49469105.tgop(e,tp,eg,ep,ev,re,r,rp)
	-- 把效果持有者（那只被特殊召唤的怪兽）以效果原因送去墓地。
	Duel.SendtoGrave(e:GetHandler(),REASON_EFFECT)
end
