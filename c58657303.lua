--墓守の霊術師
-- 效果：
-- 这个卡名的效果1回合只能使用1次。
-- ①：场上有「王家长眠之谷」存在的场合才能发动。魔法师族融合怪兽卡决定的包含场上的这张卡的融合素材怪兽从自己的手卡·场上送去墓地，把那1只融合怪兽从额外卡组融合召唤。
function c58657303.initial_effect(c)
	-- 这个卡名的效果1回合只能使用1次。①：场上有「王家长眠之谷」存在的场合才能发动。魔法师族融合怪兽卡决定的包含场上的这张卡的融合素材怪兽从自己的手卡·场上送去墓地，把那1只融合怪兽从额外卡组融合召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,58657303)
	e1:SetCondition(c58657303.condition)
	e1:SetTarget(c58657303.target)
	e1:SetOperation(c58657303.operation)
	c:RegisterEffect(e1)
end
-- 效果发动条件：场上有「王家长眠之谷」存在。
function c58657303.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检查场上是否存在「王家长眠之谷」（卡号：47355498）。
	return Duel.IsEnvironment(47355498)
end
-- 过滤函数：过滤不受效果影响的卡。
function c58657303.filter1(c,e)
	return not c:IsImmuneToEffect(e)
end
-- 过滤函数：过滤额外卡组中可以进行融合召唤的魔法师族融合怪兽（必须包含场上的这张卡作为素材）。
function c58657303.filter2(c,e,tp,m,f,gc,chkf)
	return c:IsType(TYPE_FUSION) and c:IsRace(RACE_SPELLCASTER) and (not f or f(c))
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_FUSION,tp,false,false) and c:CheckFusionMaterial(m,gc,chkf)
end
-- 效果发动准备（Target）：检查是否存在可融合召唤的怪兽，并设置特殊召唤的操作信息。
function c58657303.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then
		local chkf=tp
		-- 获取玩家可用的融合素材。
		local mg1=Duel.GetFusionMaterial(tp)
		-- 检查额外卡组是否存在可以使用包含自身在内的素材进行融合召唤的魔法师族融合怪兽。
		local res=Duel.IsExistingMatchingCard(c58657303.filter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg1,nil,c,chkf)
		if not res then
			-- 获取玩家受到的连锁素材效果。
			local ce=Duel.GetChainMaterial(tp)
			if ce~=nil then
				local fgroup=ce:GetTarget()
				local mg2=fgroup(ce,e,tp)
				local mf=ce:GetValue()
				-- 检查在连锁素材效果适用下，额外卡组是否存在可融合召唤的魔法师族融合怪兽。
				res=Duel.IsExistingMatchingCard(c58657303.filter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg2,mf,c,chkf)
			end
		end
		return res
	end
	-- 设置操作信息：从额外卡组特殊召唤1只怪兽。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- 效果处理（Operation）：将融合素材送去墓地，从额外卡组融合召唤1只魔法师族融合怪兽。
function c58657303.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local chkf=tp
	if not c:IsRelateToEffect(e) or c:IsImmuneToEffect(e) then return end
	-- 获取不受此效果影响的可用融合素材。
	local mg1=Duel.GetFusionMaterial(tp):Filter(c58657303.filter1,nil,e)
	-- 获取额外卡组中可以使用当前素材融合召唤的魔法师族融合怪兽组。
	local sg1=Duel.GetMatchingGroup(c58657303.filter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg1,nil,c,chkf)
	local mg2=nil
	local sg2=nil
	-- 获取玩家受到的连锁素材效果。
	local ce=Duel.GetChainMaterial(tp)
	if ce~=nil then
		local fgroup=ce:GetTarget()
		mg2=fgroup(ce,e,tp)
		local mf=ce:GetValue()
		-- 获取在连锁素材效果适用下，额外卡组中可以融合召唤的魔法师族融合怪兽组。
		sg2=Duel.GetMatchingGroup(c58657303.filter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg2,mf,c,chkf)
	end
	if sg1:GetCount()>0 or (sg2~=nil and sg2:GetCount()>0) then
		local sg=sg1:Clone()
		if sg2 then sg:Merge(sg2) end
		-- 提示玩家选择要特殊召唤的卡。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		local tg=sg:Select(tp,1,1,nil)
		local tc=tg:GetFirst()
		-- 判断是否使用常规融合素材进行融合召唤（若不使用连锁素材效果，或玩家选择不使用连锁素材效果）。
		if sg1:IsContains(tc) and (sg2==nil or not sg2:IsContains(tc) or not Duel.SelectYesNo(tp,ce:GetDescription())) then
			-- 玩家选择包含自身在内的常规融合素材。
			local mat1=Duel.SelectFusionMaterial(tp,tc,mg1,c,chkf)
			tc:SetMaterial(mat1)
			-- 将选定的融合素材送去墓地。
			Duel.SendtoGrave(mat1,REASON_EFFECT+REASON_MATERIAL+REASON_FUSION)
			-- 中断当前效果，使后续的特殊召唤处理不与送去墓地同时处理。
			Duel.BreakEffect()
			-- 将融合怪兽以融合召唤的方式表侧表示特殊召唤。
			Duel.SpecialSummon(tc,SUMMON_TYPE_FUSION,tp,tp,false,false,POS_FACEUP)
		else
			-- 玩家选择包含自身在内的、受连锁素材效果影响的融合素材。
			local mat2=Duel.SelectFusionMaterial(tp,tc,mg2,c,chkf)
			local fop=ce:GetOperation()
			fop(ce,e,tp,tc,mat2)
		end
		tc:CompleteProcedure()
	end
end
