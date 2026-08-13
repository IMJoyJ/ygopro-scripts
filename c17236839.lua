--瞬間融合
-- 效果：
-- ①：从自己场上把融合怪兽卡决定的融合素材怪兽送去墓地，把那1只融合怪兽从额外卡组融合召唤。这个效果融合召唤的怪兽在结束阶段破坏。
function c17236839.initial_effect(c)
	-- ①：从自己场上把融合怪兽卡决定的融合素材怪兽送去墓地，把那1只融合怪兽从额外卡组融合召唤。这个效果融合召唤的怪兽在结束阶段破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e1:SetTarget(c17236839.target)
	e1:SetOperation(c17236839.activate)
	c:RegisterEffect(e1)
end
-- 筛选可作为融合素材的场上怪兽：位于场上且不免疫此效果。
function c17236839.filter1(c,e)
	return c:IsOnField() and not c:IsImmuneToEffect(e)
end
-- 筛选额外卡组中可进行融合召唤的融合怪兽：必须是融合怪兽、满足额外素材条件、能以融合召唤方式特殊召唤，且能用当前素材满足其融合素材要求。
function c17236839.filter2(c,e,tp,m,f,chkf)
	return c:IsType(TYPE_FUSION) and (not f or f(c))
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_FUSION,tp,false,false) and c:CheckFusionMaterial(m,nil,chkf)
end
-- 发动时检测：确认能否从自己场上选择素材融合召唤额外卡组的融合怪兽（若通常素材不行，再检查连锁素材），并设置操作信息。
function c17236839.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local chkf=tp
		-- 获取玩家可用的融合素材组，并仅保留场上的怪兽（瞬间融合要求素材必须从自己场上选择）。
		local mg1=Duel.GetFusionMaterial(tp):Filter(Card.IsOnField,nil)
		-- 检查额外卡组中是否存在至少1只可用当前场上素材融合召唤的融合怪兽。
		local res=Duel.IsExistingMatchingCard(c17236839.filter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg1,nil,chkf)
		if not res then
			-- 获取当前玩家适用的连锁素材效果（若有），用于代替通常融合素材。
			local ce=Duel.GetChainMaterial(tp)
			if ce~=nil then
				local fgroup=ce:GetTarget()
				local mg2=fgroup(ce,e,tp)
				local mf=ce:GetValue()
				-- 在通常素材不可用的情况下，使用连锁素材提供的素材组再次检查额外卡组是否存在可融合召唤的融合怪兽。
				res=Duel.IsExistingMatchingCard(c17236839.filter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg2,mf,chkf)
			end
		end
		return res
	end
	-- 设置操作信息：本效果将进行1只怪兽的特殊召唤（融合召唤），目标位置为额外卡组，供其他卡/效果进行响应检测。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- 效果处理阶段：从候选融合怪兽中选择1只，选择对应融合素材并送去墓地，进行融合召唤；随后为该怪兽注册结束阶段破坏的效果。
function c17236839.activate(e,tp,eg,ep,ev,re,r,rp)
	local chkf=tp
	-- 获取场上可用的融合素材怪兽，排除免疫此效果的怪兽。
	local mg1=Duel.GetFusionMaterial(tp):Filter(c17236839.filter1,nil,e)
	-- 用场上素材筛选额外卡组中所有可融合召唤的融合怪兽，构成候选集合。
	local sg1=Duel.GetMatchingGroup(c17236839.filter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg1,nil,chkf)
	local mg2=nil
	local sg2=nil
	-- 获取连锁素材效果，以便考虑使用连锁素材进行融合。
	local ce=Duel.GetChainMaterial(tp)
	if ce~=nil then
		local fgroup=ce:GetTarget()
		mg2=fgroup(ce,e,tp)
		local mf=ce:GetValue()
		-- 使用连锁素材提供的素材组，筛选额外卡组中可融合召唤的融合怪兽，构成备选集合。
		sg2=Duel.GetMatchingGroup(c17236839.filter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg2,mf,chkf)
	end
	if sg1:GetCount()>0 or (sg2~=nil and sg2:GetCount()>0) then
		local sg=sg1:Clone()
		if sg2 then sg:Merge(sg2) end
		-- 给玩家显示提示，从候选融合怪兽中选择1只特殊召唤的怪兽。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		local tg=sg:Select(tp,1,1,nil)
		local tc=tg:GetFirst()
		-- 判断选中的融合怪兽是否可用通常场上素材融合召唤，且不使用连锁素材；若是则进入普通融合流程，否则进入连锁素材融合流程。
		if sg1:IsContains(tc) and (sg2==nil or not sg2:IsContains(tc) or not Duel.SelectYesNo(tp,ce:GetDescription())) then
			-- 让玩家从场上素材组中为该融合怪兽选择融合素材。
			local mat1=Duel.SelectFusionMaterial(tp,tc,mg1,nil,chkf)
			tc:SetMaterial(mat1)
			-- 将选择的融合素材从场上送去墓地，送墓原因包含效果、融合素材和融合召唤。
			Duel.SendtoGrave(mat1,REASON_EFFECT+REASON_MATERIAL+REASON_FUSION)
			-- 中断当前效果处理，使此后的融合召唤被视为另行处理，以提供正确的时点。
			Duel.BreakEffect()
			-- 将选中的融合怪兽以融合召唤方式表侧特殊召唤到己方场上。
			Duel.SpecialSummon(tc,SUMMON_TYPE_FUSION,tp,tp,false,false,POS_FACEUP)
		else
			-- 若使用连锁素材，则从连锁素材效果提供的素材组中为该融合怪兽选择融合素材。
			local mat2=Duel.SelectFusionMaterial(tp,tc,mg2,nil,chkf)
			local fop=ce:GetOperation()
			fop(ce,e,tp,tc,mat2)
		end
		tc:CompleteProcedure()
		local fid=e:GetHandler():GetFieldID()
		tc:RegisterFlagEffect(17236839,RESET_EVENT+RESETS_STANDARD,0,1,fid)
		-- 这个效果融合召唤的怪兽在结束阶段破坏。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_PHASE+PHASE_END)
		e1:SetCountLimit(1)
		e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
		e1:SetLabel(fid)
		e1:SetLabelObject(tc)
		e1:SetCondition(c17236839.descon)
		e1:SetOperation(c17236839.desop)
		-- 将结束阶段破坏那只融合怪兽的持续效果注册到当前玩家。
		Duel.RegisterEffect(e1,tp)
	end
end
-- 该持续效果的发动条件：通过核对标志确认场上怪兽仍是本效果融合召唤的那只怪兽；若标志不一致则重置效果，不执行破坏。
function c17236839.descon(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	if tc:GetFlagEffectLabel(17236839)~=e:GetLabel() then
		e:Reset()
		return false
	else return true end
end
-- 结束阶段时执行的操作：破坏对应怪兽。
function c17236839.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 以效果原因破坏该怪兽。
	Duel.Destroy(e:GetLabelObject(),REASON_EFFECT)
end
