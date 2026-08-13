--ビークロイド・コネクション・ゾーン
-- 效果：
-- ①：从自己的手卡·场上把「交通机人」融合怪兽卡决定的融合素材怪兽送去墓地，把那1只融合怪兽从额外卡组融合召唤。这个效果特殊召唤的怪兽不会被效果破坏，那只怪兽的效果不会被无效化。
function c23299957.initial_effect(c)
	-- ①：从自己的手卡·场上把「交通机人」融合怪兽卡决定的融合素材怪兽送去墓地，把那1只融合怪兽从额外卡组融合召唤。这个效果特殊召唤的怪兽不会被效果破坏，那只怪兽的效果不会被无效化。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c23299957.target)
	e1:SetOperation(c23299957.activate)
	c:RegisterEffect(e1)
end
-- 过滤融合素材中不受本效果影响的卡，确保素材能被正常送去墓地。
function c23299957.filter1(c,e)
	return not c:IsImmuneToEffect(e)
end
-- 检索额外卡组中符合条件的「交通机人」融合怪兽（类型、字段、可用素材、可融合特殊召唤）。
function c23299957.filter2(c,e,tp,m,f,chkf)
	return c:IsType(TYPE_FUSION) and c:IsSetCard(0x1016) and (not f or f(c))
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_FUSION,tp,false,false) and c:CheckFusionMaterial(m,nil,chkf)
end
-- 发动条件判定：检查能否进行融合召唤，并设置操作信息。
function c23299957.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local chkf=tp
		-- 获取当前玩家可用的融合素材组（手卡·场上怪兽及额外融合素材效果）。
		local mg1=Duel.GetFusionMaterial(tp)
		-- 检查额外卡组是否存在至少1只可用通常融合素材进行融合召唤的「交通机人」融合怪兽。
		local res=Duel.IsExistingMatchingCard(c23299957.filter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg1,nil,chkf)
		if not res then
			-- 获取玩家所受到的连锁素材效果（用于代替融合素材的效果），没有则为nil。
			local ce=Duel.GetChainMaterial(tp)
			if ce~=nil then
				local fgroup=ce:GetTarget()
				local mg2=fgroup(ce,e,tp)
				local mf=ce:GetValue()
				-- 检查使用连锁素材后额外卡组是否存在可融合召唤的「交通机人」融合怪兽。
				res=Duel.IsExistingMatchingCard(c23299957.filter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg2,mf,chkf)
			end
		end
		return res
	end
	-- 设置本次效果的操作信息为特殊召唤1只额外卡组的怪兽。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- 效果处理：选择融合怪兽、选择素材、送墓、融合召唤，并给那只怪兽附加抗性效果。
function c23299957.activate(e,tp,eg,ep,ev,re,r,rp)
	local chkf=tp
	-- 获取可用融合素材后，排除免疫本效果的卡，得到实际可选素材组。
	local mg1=Duel.GetFusionMaterial(tp):Filter(c23299957.filter1,nil,e)
	-- 用通常融合素材选出额外卡组中所有可融合召唤的「交通机人」融合怪兽。
	local sg1=Duel.GetMatchingGroup(c23299957.filter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg1,nil,chkf)
	local mg2=nil
	local sg2=nil
	-- 获取连锁素材效果（用于处理阶段）。
	local ce=Duel.GetChainMaterial(tp)
	if ce~=nil then
		local fgroup=ce:GetTarget()
		mg2=fgroup(ce,e,tp)
		local mf=ce:GetValue()
		-- 用连锁素材提供的素材选出额外卡组中所有可融合召唤的「交通机人」融合怪兽。
		sg2=Duel.GetMatchingGroup(c23299957.filter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg2,mf,chkf)
	end
	if sg1:GetCount()>0 or (sg2~=nil and sg2:GetCount()>0) then
		local sg=sg1:Clone()
		if sg2 then sg:Merge(sg2) end
		-- 提示选择要特殊召唤的融合怪兽。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		local tg=sg:Select(tp,1,1,nil)
		local tc=tg:GetFirst()
		-- 判断所选怪兽是否使用通常素材融合（或虽在连锁素材中但仍选择通常素材），以分支处理融合召唤方式。
		if sg1:IsContains(tc) and (sg2==nil or not sg2:IsContains(tc) or not Duel.SelectYesNo(tp,ce:GetDescription())) then
			-- 从通常素材组中选择该融合怪兽所需的融合素材。
			local mat1=Duel.SelectFusionMaterial(tp,tc,mg1,nil,chkf)
			tc:SetMaterial(mat1)
			-- 将选择的融合素材送去墓地（作为融合素材）。
			Duel.SendtoGrave(mat1,REASON_EFFECT+REASON_MATERIAL+REASON_FUSION)
			-- 中断当前效果处理，使后续融合召唤不在同一时点处理，避免错过时点。
			Duel.BreakEffect()
			-- 将选择的融合怪兽以融合召唤方式特殊召唤到场上。
			Duel.SpecialSummon(tc,SUMMON_TYPE_FUSION,tp,tp,false,false,POS_FACEUP)
		else
			-- 若使用连锁素材分支，则从连锁素材组中选择融合素材。
			local mat2=Duel.SelectFusionMaterial(tp,tc,mg2,nil,chkf)
			local fop=ce:GetOperation()
			fop(ce,e,tp,tc,mat2)
		end
		tc:CompleteProcedure()
		local c=e:GetHandler()
		-- 这个效果特殊召唤的怪兽不会被效果破坏。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
		e1:SetValue(1)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1,true)
		-- 那只怪兽的效果不会被无效化。
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_CANNOT_DISABLE)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e2,true)
		-- 那只怪兽的效果不会被无效化。
		local e3=Effect.CreateEffect(c)
		e3:SetType(EFFECT_TYPE_FIELD)
		e3:SetCode(EFFECT_CANNOT_DISEFFECT)
		e3:SetRange(LOCATION_MZONE)
		e3:SetValue(c23299957.efilter)
		e3:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e3,true)
	end
end
-- 判断当前连锁上发动的效果是否来自该融合怪兽自身，以决定是否适用“效果发动不被无效”的保护。
function c23299957.efilter(e,ct)
	-- 获取当前连锁上触发效果的效果对象，用于与融合怪兽进行比对。
	local te=Duel.GetChainInfo(ct,CHAININFO_TRIGGERING_EFFECT)
	return te:GetHandler()==e:GetHandler()
end
