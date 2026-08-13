--D－フュージョン
-- 效果：
-- 这张卡的效果融合召唤的场合，不是「命运英雄」怪兽不能作为融合素材。
-- ①：从自己场上把融合怪兽卡决定的融合素材怪兽送去墓地，把那1只融合怪兽从额外卡组融合召唤。这个效果特殊召唤的怪兽在这个回合不会被战斗·效果破坏。
function c26841274.initial_effect(c)
	-- 这张卡的效果融合召唤的场合，不是「命运英雄」怪兽不能作为融合素材。①：从自己场上把融合怪兽卡决定的融合素材怪兽送去墓地，把那1只融合怪兽从额外卡组融合召唤。这个效果特殊召唤的怪兽在这个回合不会被战斗·效果破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c26841274.target)
	e1:SetOperation(c26841274.activate)
	c:RegisterEffect(e1)
end
-- 过滤可作为融合素材的怪兽：要求怪兽在场上、是「命运英雄」（0xc008），并且不免疫本效果（若传入e则检查），以确保能被本卡效果作为融合素材送去墓地。
function c26841274.filter1(c,e)
	return c:IsOnField() and c:IsSetCard(0xc008) and (not e or not c:IsImmuneToEffect(e))
end
-- 过滤额外卡组中可进行融合召唤的怪兽：必须是融合怪兽，满足额外的素材指定条件f，能被当前玩家以融合召唤方式特殊召唤，并且能用给定的素材组m选出符合融合素材要求的组合。
function c26841274.filter2(c,e,tp,m,f,chkf)
	return c:IsType(TYPE_FUSION) and (not f or f(c))
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_FUSION,tp,false,false) and c:CheckFusionMaterial(m,nil,chkf)
end
-- 过滤通过连锁素材效果产生的额外融合素材：要求该卡可作为融合素材且是「命运英雄」（0xc008），以符合本卡对融合素材的限制。
function c26841274.filter3(c)
	return c:IsCanBeFusionMaterial() and c:IsSetCard(0xc008)
end
-- 发动时的合法性检查和操作信息登记：在chk==0时，先检查能否用常规素材融合召唤出额外怪兽，若不行则再检查是否有连锁素材效果可提供额外素材；通过后设置本连锁将进行特殊召唤（从额外卡组选1只）。
function c26841274.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local chkf=tp
		-- 获取当前玩家可用的融合素材组，并过滤出场上存在的「命运英雄」怪兽，作为判断能否融合召唤的候选素材。
		local mg1=Duel.GetFusionMaterial(tp):Filter(c26841274.filter1,nil)
		-- 检查额外卡组是否存在至少1只融合怪兽，能用上述常规素材mg1满足融合素材要求并可以被融合召唤。
		local res=Duel.IsExistingMatchingCard(c26841274.filter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg1,nil,chkf)
		if not res then
			-- 获取连锁素材效果（如其他卡提供的代替融合素材），用于在常规素材不足时追加融合素材来源。
			local ce=Duel.GetChainMaterial(tp)
			if ce~=nil then
				local fgroup=ce:GetTarget()
				local mg2=fgroup(ce,e,tp):Filter(c26841274.filter3,nil)
				local mf=ce:GetValue()
				-- 使用连锁素材效果提供的素材组mg2及其附加检查函数mf，再次检查额外卡组是否存在可进行融合召唤的怪兽。
				res=Duel.IsExistingMatchingCard(c26841274.filter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg2,mf,chkf)
			end
		end
		return res
	end
	-- 设置操作信息：本次连锁将执行特殊召唤，对象为从额外卡组选择1只怪兽，供相关卡的效果检测用。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- 效果处理：获取常规素材候选和连锁素材候选，若有可融合召唤的怪兽，则选择1只；根据选择区分使用常规素材还是连锁素材来完成融合召唤；最后给特殊召唤的怪兽附加本回合不会被战斗·效果破坏的效果，并完成融合召唤手续。
function c26841274.activate(e,tp,eg,ep,ev,re,r,rp)
	local chkf=tp
	-- 效果处理时获取常规融合素材组，并筛选出场上、是「命运英雄」且不免疫本效果的怪兽作为可选素材。
	local mg1=Duel.GetFusionMaterial(tp):Filter(c26841274.filter1,nil,e)
	-- 根据常规素材组mg1，筛选出额外卡组中所有可以被融合召唤的融合怪兽，作为本卡处理时的可选融合目标。
	local sg1=Duel.GetMatchingGroup(c26841274.filter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg1,nil,chkf)
	local mg2=nil
	local sg2=nil
	-- 效果处理时获取连锁素材效果，以确定是否可以使用额外的融合素材来源。
	local ce=Duel.GetChainMaterial(tp)
	if ce~=nil then
		local fgroup=ce:GetTarget()
		mg2=fgroup(ce,e,tp):Filter(c26841274.filter3,nil)
		local mf=ce:GetValue()
		-- 根据连锁素材效果提供的素材组mg2及检查函数mf，筛选出额外卡组中所有可融合召唤的融合怪兽，作为另一组可选目标。
		sg2=Duel.GetMatchingGroup(c26841274.filter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg2,mf,chkf)
	end
	if sg1:GetCount()>0 or (sg2~=nil and sg2:GetCount()>0) then
		local sg=sg1:Clone()
		if sg2 then sg:Merge(sg2) end
		-- 向当前玩家发出选择提示，要求从可选的融合怪兽中选择1只进行特殊召唤。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		local tg=sg:Select(tp,1,1,nil)
		local tc=tg:GetFirst()
		-- 判断所选怪兽是否可以通过常规素材融合召唤，且（若也属于连锁素材候选）玩家选择不使用连锁素材效果；若成立则执行常规融合，否则执行连锁素材融合。
		if sg1:IsContains(tc) and (sg2==nil or not sg2:IsContains(tc) or not Duel.SelectYesNo(tp,ce:GetDescription())) then
			-- 常规融合流程：让玩家从常规素材组mg1中选择一组满足该融合怪兽融合条件的素材。
			local mat1=Duel.SelectFusionMaterial(tp,tc,mg1,nil,chkf)
			tc:SetMaterial(mat1)
			-- 将选择的融合素材以效果、融合素材和融合召唤的原因送去墓地，完成融合素材的送墓处理。
			Duel.SendtoGrave(mat1,REASON_EFFECT+REASON_MATERIAL+REASON_FUSION)
			-- 中断当前效果链，使接下来的特殊召唤处理与送墓处理视为不同时处理，以避免错失正确的时点。
			Duel.BreakEffect()
			-- 将选择的融合怪兽以融合召唤方式（SUMMON_TYPE_FUSION）特殊召唤到当前玩家的场上。
			Duel.SpecialSummon(tc,SUMMON_TYPE_FUSION,tp,tp,false,false,POS_FACEUP)
		else
			-- 连锁素材融合流程：让玩家从连锁素材组mg2中选择一组满足该融合怪兽融合条件的素材。
			local mat2=Duel.SelectFusionMaterial(tp,tc,mg2,nil,chkf)
			local fop=ce:GetOperation()
			fop(ce,e,tp,tc,mat2)
		end
		-- 对应原文“这个效果特殊召唤的怪兽在这个回合不会被战斗·效果破坏”中的“不会被战斗破坏”部分。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
		e1:SetValue(1)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
		tc:RegisterEffect(e2)
		tc:CompleteProcedure()
	end
end
