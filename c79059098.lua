--プランキッズの大暴走
-- 效果：
-- ①：自己·对方的主要阶段才能发动。从自己的手卡·场上把「调皮宝贝」融合怪兽卡决定的融合素材怪兽送去墓地，把那1只融合怪兽从额外卡组融合召唤。这张卡的发动后，直到回合结束时自己不是「调皮宝贝」怪兽不能召唤·特殊召唤。
function c79059098.initial_effect(c)
	-- ①：自己·对方的主要阶段才能发动。从自己的手卡·场上把「调皮宝贝」融合怪兽卡决定的融合素材怪兽送去墓地，把那1只融合怪兽从额外卡组融合召唤。这张卡的发动后，直到回合结束时自己不是「调皮宝贝」怪兽不能召唤·特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_MAIN_END)
	e1:SetCondition(c79059098.condition)
	e1:SetTarget(c79059098.target)
	e1:SetOperation(c79059098.activate)
	c:RegisterEffect(e1)
end
-- 检查当前阶段是否为自己或对方的主要阶段。
function c79059098.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 返回当前阶段是否为主要阶段1或主要阶段2。
	return Duel.GetCurrentPhase()==PHASE_MAIN1 or Duel.GetCurrentPhase()==PHASE_MAIN2
end
-- 过滤不受效果影响的卡片。
function c79059098.filter1(c,e)
	return not c:IsImmuneToEffect(e)
end
-- 过滤额外卡组中可以进行融合召唤的「调皮宝贝」融合怪兽。
function c79059098.filter2(c,e,tp,m,f,chkf)
	return c:IsType(TYPE_FUSION) and c:IsSetCard(0x120) and (not f or f(c))
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_FUSION,tp,false,false) and c:CheckFusionMaterial(m,nil,chkf)
end
-- 效果发动时的目标确认与合法性检查。
function c79059098.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local chkf=tp
		-- 获取玩家手卡和场上可用的融合素材。
		local mg1=Duel.GetFusionMaterial(tp)
		-- 检查额外卡组是否存在可以使用当前素材进行融合召唤的「调皮宝贝」怪兽。
		local res=Duel.IsExistingMatchingCard(c79059098.filter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg1,nil,chkf)
		if not res then
			-- 获取玩家受到的连锁素材效果。
			local ce=Duel.GetChainMaterial(tp)
			if ce~=nil then
				local fgroup=ce:GetTarget()
				local mg2=fgroup(ce,e,tp)
				local mf=ce:GetValue()
				-- 检查在连锁素材效果影响下，是否存在可以融合召唤的「调皮宝贝」怪兽。
				res=Duel.IsExistingMatchingCard(c79059098.filter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg2,mf,chkf)
			end
		end
		return res
	end
	-- 设置操作信息为从额外卡组特殊召唤1只怪兽。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- 效果处理的执行函数。
function c79059098.activate(e,tp,eg,ep,ev,re,r,rp)
	if e:IsHasType(EFFECT_TYPE_ACTIVATE) then
		-- 从自己的手卡·场上把「调皮宝贝」融合怪兽卡决定的融合素材怪兽送去墓地，把那1只融合怪兽从额外卡组融合召唤。这张卡的发动后，直到回合结束时自己不是「调皮宝贝」怪兽不能召唤·特殊召唤。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
		e1:SetTargetRange(1,0)
		e1:SetTarget(c79059098.splimit)
		e1:SetReset(RESET_PHASE+PHASE_END)
		-- 注册不能特殊召唤「调皮宝贝」以外怪兽的限制效果。
		Duel.RegisterEffect(e1,tp)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_CANNOT_SUMMON)
		-- 注册不能召唤「调皮宝贝」以外怪兽的限制效果。
		Duel.RegisterEffect(e2,tp)
	end
	local chkf=tp
	-- 获取并过滤出不受此卡效果影响的可用融合素材。
	local mg1=Duel.GetFusionMaterial(tp):Filter(c79059098.filter1,nil,e)
	-- 获取当前素材可以融合召唤的所有「调皮宝贝」怪兽组。
	local sg1=Duel.GetMatchingGroup(c79059098.filter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg1,nil,chkf)
	local mg2=nil
	local sg2=nil
	-- 获取玩家受到的连锁素材效果。
	local ce=Duel.GetChainMaterial(tp)
	if ce~=nil then
		local fgroup=ce:GetTarget()
		mg2=fgroup(ce,e,tp)
		local mf=ce:GetValue()
		-- 获取在连锁素材效果下可以融合召唤的「调皮宝贝」怪兽组。
		sg2=Duel.GetMatchingGroup(c79059098.filter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg2,mf,chkf)
	end
	if sg1:GetCount()>0 or (sg2~=nil and sg2:GetCount()>0) then
		local sg=sg1:Clone()
		if sg2 then sg:Merge(sg2) end
		-- 提示玩家选择要特殊召唤的怪兽。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		local tg=sg:Select(tp,1,1,nil)
		local tc=tg:GetFirst()
		-- 判断是否使用常规融合素材进行融合召唤（若可以使用常规素材，且不选择使用连锁素材效果）。
		if sg1:IsContains(tc) and (sg2==nil or not sg2:IsContains(tc) or not Duel.SelectYesNo(tp,ce:GetDescription())) then
			-- 让玩家选择用于融合召唤该怪兽的常规融合素材。
			local mat1=Duel.SelectFusionMaterial(tp,tc,mg1,nil,chkf)
			tc:SetMaterial(mat1)
			-- 将选中的融合素材因效果、素材、融合原因送去墓地。
			Duel.SendtoGrave(mat1,REASON_EFFECT+REASON_MATERIAL+REASON_FUSION)
			-- 中断当前效果处理，使后续的特殊召唤不与送去墓地同时处理。
			Duel.BreakEffect()
			-- 将融合怪兽以表侧表示融合召唤到场上。
			Duel.SpecialSummon(tc,SUMMON_TYPE_FUSION,tp,tp,false,false,POS_FACEUP)
		else
			-- 让玩家选择连锁素材效果指定的融合素材。
			local mat2=Duel.SelectFusionMaterial(tp,tc,mg2,nil,chkf)
			local fop=ce:GetOperation()
			fop(ce,e,tp,tc,mat2)
		end
		tc:CompleteProcedure()
	end
end
-- 限制只能召唤·特殊召唤「调皮宝贝」怪兽的过滤函数。
function c79059098.splimit(e,c)
	return not c:IsSetCard(0x120)
end
