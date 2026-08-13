--超融合
-- 效果：
-- 不能对应这张卡的发动让魔法·陷阱·怪兽的效果发动。
-- ①：丢弃1张手卡才能发动。自己·对方场上的怪兽作为融合素材，把1只融合怪兽融合召唤。
function c48130397.initial_effect(c)
	-- 不能对应这张卡的发动让魔法·陷阱·怪兽的效果发动。①：丢弃1张手卡才能发动。自己·对方场上的怪兽作为融合素材，把1只融合怪兽融合召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e1:SetCost(c48130397.cost)
	e1:SetTarget(c48130397.target)
	e1:SetOperation(c48130397.activate)
	c:RegisterEffect(e1)
end
-- 筛选对方场上表侧表示且可以作为融合素材的怪兽。
function c48130397.filter0(c)
	return c:IsFaceup() and c:IsCanBeFusionMaterial()
end
-- 筛选对方场上表侧表示、可作为融合素材且不受当前效果影响的怪兽。
function c48130397.filter1(c,e)
	return c:IsFaceup() and c:IsCanBeFusionMaterial() and not c:IsImmuneToEffect(e)
end
-- 筛选可作为融合召唤对象的融合怪兽：必须是融合怪兽、满足追加素材条件、能够以融合召唤方式特殊召唤，并可用给定素材组进行融合。
function c48130397.filter2(c,e,tp,m,f,chkf)
	return c:IsType(TYPE_FUSION) and (not f or f(c))
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_FUSION,tp,false,false) and c:CheckFusionMaterial(m,nil,chkf)
end
-- 筛选场上存在且不受当前效果影响的怪兽，用于处理时排除免疫卡。
function c48130397.filter3(c,e)
	return c:IsOnField() and not c:IsImmuneToEffect(e)
end
-- 发动代价：丢弃1张手卡。
function c48130397.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 代价检查：确认手牌中存在至少1张可以丢弃的卡。
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,e:GetHandler()) end
	-- 丢弃1张手卡（作为发动代价）。
	Duel.DiscardHand(tp,Card.IsDiscardable,1,1,REASON_COST+REASON_DISCARD)
end
-- 效果发动时的处理：检查能否进行融合召唤，并设定不能对应发动的连锁限制。
function c48130397.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local chkf=tp
		-- 获取己方场上可作为融合素材的融合素材组（仅保留场上的卡）。
		local mg1=Duel.GetFusionMaterial(tp):Filter(Card.IsOnField,nil)
		-- 获取对方场上表侧表示且可作为融合素材的怪兽。
		local mg2=Duel.GetMatchingGroup(c48130397.filter0,tp,0,LOCATION_MZONE,nil)
		mg1:Merge(mg2)
		-- 检查额外卡组中是否存在能用当前素材组融合召唤的融合怪兽。
		local res=Duel.IsExistingMatchingCard(c48130397.filter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg1,nil,chkf)
		if not res then
			-- 获取当前玩家可用的代替融合素材的连锁效果（若有）。
			local ce=Duel.GetChainMaterial(tp)
			if ce~=nil then
				local fgroup=ce:GetTarget()
				local mg3=fgroup(ce,e,tp)
				local mf=ce:GetValue()
				-- 使用连锁素材效果提供的替代素材组，再次检查是否有可融合召唤的融合怪兽。
				res=Duel.IsExistingMatchingCard(c48130397.filter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg3,mf,chkf)
			end
		end
		return res
	end
	-- 设置操作信息：将从额外卡组特殊召唤1只怪兽（用于时点/效果检测）。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
	if e:IsHasType(EFFECT_TYPE_ACTIVATE) then
		-- 设置连锁限制：使任何魔法·陷阱·怪兽的效果都不能对应此卡发动。
		Duel.SetChainLimit(aux.FALSE)
	end
end
-- 效果处理：选择融合怪兽，从其素材中选出融合素材，将素材送墓并进行融合召唤。
function c48130397.activate(e,tp,eg,ep,ev,re,r,rp)
	local chkf=tp
	-- 处理时获取己方场上可作为融合素材的怪兽（排除不受当前效果影响的卡）。
	local mg1=Duel.GetFusionMaterial(tp):Filter(c48130397.filter3,nil,e)
	-- 处理时获取对方场上表侧、可作为融合素材且不受当前效果影响的怪兽。
	local mg2=Duel.GetMatchingGroup(c48130397.filter1,tp,0,LOCATION_MZONE,nil,e)
	mg1:Merge(mg2)
	-- 获取所有使用常规素材组能够融合召唤的融合怪兽候选。
	local sg1=Duel.GetMatchingGroup(c48130397.filter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg1,nil,chkf)
	local mg3=nil
	local sg2=nil
	-- 再次获取玩家可用的代替融合素材的连锁效果（用于处理时判断是否使用）。
	local ce=Duel.GetChainMaterial(tp)
	if ce~=nil then
		local fgroup=ce:GetTarget()
		mg3=fgroup(ce,e,tp)
		local mf=ce:GetValue()
		-- 获取使用连锁素材效果提供的素材组能够融合召唤的融合怪兽候选。
		sg2=Duel.GetMatchingGroup(c48130397.filter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg3,mf,chkf)
	end
	if sg1:GetCount()>0 or (sg2~=nil and sg2:GetCount()>0) then
		local sg=sg1:Clone()
		if sg2 then sg:Merge(sg2) end
		-- 弹出选择提示：请选择要特殊召唤的融合怪兽。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		local tg=sg:Select(tp,1,1,nil)
		local tc=tg:GetFirst()
		-- 若选择的融合怪兽可用常规素材融合，且玩家未选择使用连锁素材效果（或无替代素材），则执行常规融合。
		if sg1:IsContains(tc) and (sg2==nil or not sg2:IsContains(tc) or not Duel.SelectYesNo(tp,ce:GetDescription())) then
			-- 让玩家选择该融合怪兽所需的融合素材。
			local mat1=Duel.SelectFusionMaterial(tp,tc,mg1,nil,chkf)
			tc:SetMaterial(mat1)
			-- 将选择的融合素材送去墓地（作为融合召唤，原因包含效果和融合素材）。
			Duel.SendtoGrave(mat1,REASON_EFFECT+REASON_MATERIAL+REASON_FUSION)
			-- 中断当前效果处理，使后续特殊召唤作为另一次效果处理（避免与素材送墓同时处理）。
			Duel.BreakEffect()
			-- 将融合怪兽以融合召唤方式表侧表示特殊召唤到己方场上。
			Duel.SpecialSummon(tc,SUMMON_TYPE_FUSION,tp,tp,false,false,POS_FACEUP)
		else
			-- 使用连锁素材效果时，让玩家从替代素材组中选择融合素材。
			local mat2=Duel.SelectFusionMaterial(tp,tc,mg3,nil,chkf)
			local fop=ce:GetOperation()
			fop(ce,e,tp,tc,mat2)
		end
		tc:CompleteProcedure()
	end
end
