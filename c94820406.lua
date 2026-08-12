--ダーク・フュージョン
-- 效果：
-- ①：自己的手卡·场上的怪兽作为融合素材，把1只恶魔族融合怪兽融合召唤。这个回合，对方不能把这个效果特殊召唤的怪兽作为效果的对象。
function c94820406.initial_effect(c)
	-- ①：自己的手卡·场上的怪兽作为融合素材，把1只恶魔族融合怪兽融合召唤。这个回合，对方不能把这个效果特殊召唤的怪兽作为效果的对象。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c94820406.target)
	e1:SetOperation(c94820406.activate)
	c:RegisterEffect(e1)
end
-- 过滤不受此卡效果影响的卡片（用于融合素材过滤）
function c94820406.filter1(c,e)
	return not c:IsImmuneToEffect(e)
end
-- 过滤额外卡组中满足融合召唤条件的恶魔族融合怪兽
function c94820406.filter2(c,e,tp,m,f,chkf)
	return c:IsType(TYPE_FUSION) and c:IsRace(RACE_FIEND) and (not f or f(c))
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_FUSION,tp,false,false) and c:CheckFusionMaterial(m,nil,chkf)
end
-- 效果发动的目标确认，检查是否存在可融合召唤的合法组合，并设置操作信息
function c94820406.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local chkf=tp
		-- 获取玩家可用于融合召唤的素材卡片组（手卡·场上）
		local mg1=Duel.GetFusionMaterial(tp)
		-- 检查额外卡组中是否存在可以使用当前素材进行融合召唤的恶魔族融合怪兽
		local res=Duel.IsExistingMatchingCard(c94820406.filter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg1,nil,chkf)
		if not res then
			-- 获取玩家受到的连锁素材效果（如连锁素材等替代融合效果）
			local ce=Duel.GetChainMaterial(tp)
			if ce~=nil then
				local fgroup=ce:GetTarget()
				local mg2=fgroup(ce,e,tp)
				local mf=ce:GetValue()
				-- 检查在使用连锁素材效果提供的素材时，额外卡组是否存在可融合召唤的恶魔族融合怪兽
				res=Duel.IsExistingMatchingCard(c94820406.filter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg2,mf,chkf)
			end
		end
		return res
	end
	-- 设置操作信息，表示该效果包含从额外卡组特殊召唤1只怪兽的操作
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- 效果处理的核心逻辑，执行融合素材的送墓与融合怪兽的特殊召唤，并赋予抗性
function c94820406.activate(e,tp,eg,ep,ev,re,r,rp)
	local chkf=tp
	-- 获取玩家可用的融合素材，并过滤掉不受此卡效果影响的卡
	local mg1=Duel.GetFusionMaterial(tp):Filter(c94820406.filter1,nil,e)
	-- 获取额外卡组中可以使用当前素材融合召唤的所有恶魔族融合怪兽
	local sg1=Duel.GetMatchingGroup(c94820406.filter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg1,nil,chkf)
	local mg2=nil
	local sg2=nil
	-- 效果处理时，再次获取玩家受到的连锁素材效果
	local ce=Duel.GetChainMaterial(tp)
	if ce~=nil then
		local fgroup=ce:GetTarget()
		mg2=fgroup(ce,e,tp)
		local mf=ce:GetValue()
		-- 获取在使用连锁素材效果时，可以融合召唤的所有恶魔族融合怪兽
		sg2=Duel.GetMatchingGroup(c94820406.filter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg2,mf,chkf)
	end
	if sg1:GetCount()>0 or (sg2~=nil and sg2:GetCount()>0) then
		local sg=sg1:Clone()
		if sg2 then sg:Merge(sg2) end
		-- 提示玩家选择要特殊召唤的怪兽
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		local tg=sg:Select(tp,1,1,nil)
		local tc=tg:GetFirst()
		-- 判断是否使用正常的融合素材进行召唤（若不使用连锁素材效果，或玩家选择不使用连锁素材效果）
		if sg1:IsContains(tc) and (sg2==nil or not sg2:IsContains(tc) or not Duel.SelectYesNo(tp,ce:GetDescription())) then
			-- 让玩家选择用于融合召唤该怪兽的融合素材
			local mat1=Duel.SelectFusionMaterial(tp,tc,mg1,nil,chkf)
			tc:SetMaterial(mat1)
			-- 将选定的融合素材作为融合素材因效果送去墓地
			Duel.SendtoGrave(mat1,REASON_EFFECT+REASON_MATERIAL+REASON_FUSION)
			-- 中断当前效果处理，使后续的特殊召唤与素材送墓不视为同时处理
			Duel.BreakEffect()
			-- 将融合怪兽以融合召唤的方式表侧表示特殊召唤到场上
			Duel.SpecialSummon(tc,SUMMON_TYPE_FUSION,tp,tp,false,false,POS_FACEUP)
		else
			-- 在使用连锁素材效果时，让玩家从连锁素材提供的卡片组中选择融合素材
			local mat2=Duel.SelectFusionMaterial(tp,tc,mg2,nil,chkf)
			local fop=ce:GetOperation()
			fop(ce,e,tp,tc,mat2,SUMMON_TYPE_FUSION)
		end
		tc:CompleteProcedure()
		-- 这个回合，对方不能把这个效果特殊召唤的怪兽作为效果的对象。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		-- 设置不能成为对方卡片效果的对象
		e1:SetValue(aux.tgoval)
		tc:RegisterEffect(e1)
	end
end
