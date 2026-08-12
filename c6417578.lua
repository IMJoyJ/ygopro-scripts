--神の写し身との接触
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：自己的手卡·场上的怪兽作为融合素材，把1只「影依」融合怪兽融合召唤。
function c6417578.initial_effect(c)
	-- 这个卡名的卡在1回合只能发动1张。①：自己的手卡·场上的怪兽作为融合素材，把1只「影依」融合怪兽融合召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMING_END_PHASE)
	e1:SetCountLimit(1,6417578+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(c6417578.target)
	e1:SetOperation(c6417578.activate)
	c:RegisterEffect(e1)
end
-- 过滤不受效果影响的卡片（融合素材过滤条件）
function c6417578.filter1(c,e)
	return not c:IsImmuneToEffect(e)
end
-- 过滤额外卡组中可以进行融合召唤的「影依」融合怪兽
function c6417578.filter2(c,e,tp,m,f,chkf)
	return c:IsType(TYPE_FUSION) and c:IsSetCard(0x9d) and (not f or f(c))
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_FUSION,tp,false,false) and c:CheckFusionMaterial(m,nil,chkf)
end
-- 效果发动时的合法性检测与操作信息设置
function c6417578.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local chkf=tp
		-- 获取玩家可用的融合素材（手卡和场上的怪兽）
		local mg1=Duel.GetFusionMaterial(tp)
		-- 检查额外卡组是否存在可以使用当前融合素材进行融合召唤的「影依」融合怪兽
		local res=Duel.IsExistingMatchingCard(c6417578.filter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg1,nil,chkf)
		if not res then
			-- 检查玩家是否受到「连锁素材」等卡片效果的影响
			local ce=Duel.GetChainMaterial(tp)
			if ce~=nil then
				local fgroup=ce:GetTarget()
				local mg2=fgroup(ce,e,tp)
				local mf=ce:GetValue()
				-- 检查在使用「连锁素材」等效果提供的素材时，是否存在可融合召唤的「影依」融合怪兽
				res=Duel.IsExistingMatchingCard(c6417578.filter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg2,mf,chkf)
			end
		end
		return res
	end
	-- 设置当前处理的连锁操作信息为特殊召唤额外卡组的怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- 效果处理的核心逻辑，执行融合召唤
function c6417578.activate(e,tp,eg,ep,ev,re,r,rp)
	local chkf=tp
	-- 获取并过滤出不受当前效果影响的可用融合素材
	local mg1=Duel.GetFusionMaterial(tp):Filter(c6417578.filter1,nil,e)
	-- 获取当前可用素材可以融合召唤的所有「影依」融合怪兽
	local sg1=Duel.GetMatchingGroup(c6417578.filter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg1,nil,chkf)
	local mg2=nil
	local sg2=nil
	-- 获取玩家受到的「连锁素材」等效果
	local ce=Duel.GetChainMaterial(tp)
	if ce~=nil then
		local fgroup=ce:GetTarget()
		mg2=fgroup(ce,e,tp)
		local mf=ce:GetValue()
		-- 获取使用「连锁素材」等效果的素材时可以融合召唤的所有「影依」融合怪兽
		sg2=Duel.GetMatchingGroup(c6417578.filter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg2,mf,chkf)
	end
	if sg1:GetCount()>0 or (sg2~=nil and sg2:GetCount()>0) then
		local sg=sg1:Clone()
		if sg2 then sg:Merge(sg2) end
		-- 提示玩家选择要特殊召唤的怪兽
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		local tg=sg:Select(tp,1,1,nil)
		local tc=tg:GetFirst()
		-- 判断是否使用常规融合素材进行融合召唤（若不使用「连锁素材」的效果）
		if sg1:IsContains(tc) and (sg2==nil or not sg2:IsContains(tc) or not Duel.SelectYesNo(tp,ce:GetDescription())) then
			-- 让玩家选择用于融合召唤的常规融合素材
			local mat1=Duel.SelectFusionMaterial(tp,tc,mg1,nil,chkf)
			tc:SetMaterial(mat1)
			-- 将选定的融合素材送去墓地
			Duel.SendtoGrave(mat1,REASON_EFFECT+REASON_MATERIAL+REASON_FUSION)
			-- 中断当前效果，使后续的特殊召唤处理不与送去墓地同时处理
			Duel.BreakEffect()
			-- 将融合怪兽从额外卡组进行融合召唤
			Duel.SpecialSummon(tc,SUMMON_TYPE_FUSION,tp,tp,false,false,POS_FACEUP)
		else
			-- 让玩家选择受「连锁素材」等效果影响时的融合素材
			local mat2=Duel.SelectFusionMaterial(tp,tc,mg2,nil,chkf)
			local fop=ce:GetOperation()
			fop(ce,e,tp,tc,mat2)
		end
		tc:CompleteProcedure()
	end
end
