--ダーク・コーリング
-- 效果：
-- ①：自己的手卡·墓地的怪兽作为融合素材除外，把「暗黑融合」的效果才能特殊召唤的1只融合怪兽当作「暗黑融合」的融合召唤作融合召唤。
function c12071500.initial_effect(c)
	-- 将暗黑神召卡注册为记载着卡名“暗黑融合”（卡号94820406）的卡，用于关联识别暗黑融合相关融合怪兽。
	aux.AddCodeList(c,94820406)
	-- ①：自己的手卡·墓地的怪兽作为融合素材除外，把「暗黑融合」的效果才能特殊召唤的1只融合怪兽当作「暗黑融合」的融合召唤作融合召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c12071500.target)
	e1:SetOperation(c12071500.activate)
	c:RegisterEffect(e1)
end
-- 筛选位于手卡且可以被除外的怪兽，作为可能的融合素材。
function c12071500.filter0(c)
	return c:IsLocation(LOCATION_HAND) and c:IsAbleToRemove()
end
-- 效果处理时筛选位于手卡、可以被除外且不免疫此效果的怪兽，作为可用的融合素材。
function c12071500.filter1(c,e)
	return c:IsLocation(LOCATION_HAND) and c:IsAbleToRemove() and not c:IsImmuneToEffect(e)
end
-- 筛选额外卡组中满足暗黑融合特殊召唤条件、能被正确特殊召唤且当前素材能满足其融合素材要求的融合怪兽。
function c12071500.filter2(c,e,tp,m,f,chkf)
	return c:IsType(TYPE_FUSION) and c.dark_calling and (not f or f(c))
		and c:IsCanBeSpecialSummoned(e,SUMMON_VALUE_DARK_FUSION,tp,false,false) and c:CheckFusionMaterial(m,nil,chkf)
end
-- 筛选墓地中可作为融合素材且能被除外的怪兽。
function c12071500.filter3(c)
	return c:IsType(TYPE_MONSTER) and c:IsCanBeFusionMaterial() and c:IsAbleToRemove()
end
-- 发动时进行合法性判定：检查是否能用自己手卡·墓地的怪兽作为素材，融合召唤出符合条件的暗黑融合融合怪兽；并设置后续特殊召唤和除外的操作信息。
function c12071500.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local chkf=tp
		-- 从当前可用的融合素材中，筛选出位于手卡且可被除外的卡，作为潜在素材组。
		local mg1=Duel.GetFusionMaterial(tp):Filter(c12071500.filter0,nil)
		-- 从墓地中筛选出可作为融合素材且可被除外的怪兽，并入素材候选。
		local mg2=Duel.GetMatchingGroup(c12071500.filter3,tp,LOCATION_GRAVE,0,nil)
		mg1:Merge(mg2)
		-- 检查额外卡组是否存在至少1只融合怪兽，能够用当前筛选出的素材进行暗黑融合融合召唤。
		local res=Duel.IsExistingMatchingCard(c12071500.filter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg1,nil,chkf)
		if not res then
			-- 获取连锁素材等额外融合素材效果，以扩展可用的融合素材来源。
			local ce=Duel.GetChainMaterial(tp)
			if ce~=nil then
				local fgroup=ce:GetTarget()
				local mg3=fgroup(ce,e,tp)
				local mf=ce:GetValue()
				-- 在连锁素材效果提供的素材组下，再次检查额外卡组是否存在能够被融合召唤的符合条件的融合怪兽。
				res=Duel.IsExistingMatchingCard(c12071500.filter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg3,mf,chkf)
			end
		end
		return res
	end
	-- 设置操作信息：本次效果将进行1只融合怪兽的特殊召唤（从额外卡组）。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
	-- 设置操作信息：本次效果将除外2张手卡或墓地的卡作为融合素材。
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,2,tp,LOCATION_HAND+LOCATION_GRAVE)
end
-- 效果处理时的实际执行：选择要融合召唤的怪兽，从手卡·墓地选择素材并除外，将其以暗黑融合的融合召唤方式特殊召唤；若适用连锁素材则调用对应操作。
function c12071500.activate(e,tp,eg,ep,ev,re,r,rp)
	local chkf=tp
	-- 效果处理时，重新取得可用融合素材并排除不受此效果影响的卡，得到普通素材组。
	local mg1=Duel.GetFusionMaterial(tp):Filter(c12071500.filter1,nil,e)
	-- 效果处理时，从墓地中筛选可作为融合素材且可被除外的怪兽。
	local mg2=Duel.GetMatchingGroup(c12071500.filter3,tp,LOCATION_GRAVE,0,nil)
	mg1:Merge(mg2)
	-- 选出额外卡组中所有能用普通素材组融合召唤且满足暗黑融合条件的融合怪兽候选。
	local sg1=Duel.GetMatchingGroup(c12071500.filter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg1,nil,chkf)
	local mg3=nil
	local sg2=nil
	-- 获取连锁素材效果，用于之后判断是否可使用连锁素材提供的额外素材。
	local ce=Duel.GetChainMaterial(tp)
	if ce~=nil then
		local fgroup=ce:GetTarget()
		mg3=fgroup(ce,e,tp)
		local mf=ce:GetValue()
		-- 若存在连锁素材效果，选出使用该效果提供的素材能够融合召唤的融合怪兽候选。
		sg2=Duel.GetMatchingGroup(c12071500.filter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg3,mf,chkf)
	end
	if sg1:GetCount()>0 or (sg2~=nil and sg2:GetCount()>0) then
		local sg=sg1:Clone()
		if sg2 then sg:Merge(sg2) end
		-- 提示玩家选择要特殊召唤的融合怪兽。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		local tg=sg:Select(tp,1,1,nil)
		local tc=tg:GetFirst()
		-- 如果所选怪兽属于普通素材可召唤的集合，并且（不存在连锁素材候选或不在其中，或玩家选择不使用连锁素材），则执行普通融合素材流程。
		if sg1:IsContains(tc) and (sg2==nil or not sg2:IsContains(tc) or not Duel.SelectYesNo(tp,ce:GetDescription())) then
			-- 从普通素材组中选择满足该融合怪兽融合召唤条件的一组素材。
			local mat1=Duel.SelectFusionMaterial(tp,tc,mg1,nil,chkf)
			tc:SetMaterial(mat1)
			-- 将选择的融合素材表侧表示除外，作为融合召唤的素材除外。
			Duel.Remove(mat1,POS_FACEUP,REASON_EFFECT+REASON_MATERIAL+REASON_FUSION)
			-- 中断当前效果处理，使此后的特殊召唤视为不同时处理，匹配融合召唤的时点规则。
			Duel.BreakEffect()
			-- 将融合怪兽以暗黑融合的融合召唤方式特殊召唤到己方场上。
			Duel.SpecialSummon(tc,SUMMON_VALUE_DARK_FUSION,tp,tp,false,false,POS_FACEUP)
		else
			-- 使用连锁素材效果提供的素材组，选择该融合怪兽所需的融合素材。
			local mat2=Duel.SelectFusionMaterial(tp,tc,mg3,nil,chkf)
			local fop=ce:GetOperation()
			fop(ce,e,tp,tc,mat2,SUMMON_VALUE_DARK_FUSION)
		end
		tc:CompleteProcedure()
	end
end
