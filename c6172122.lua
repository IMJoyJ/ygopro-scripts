--真紅眼融合
-- 效果：
-- 这个卡名的卡在1回合只能发动1张，这张卡发动的回合，自己不能用这张卡的效果以外把怪兽召唤·特殊召唤。
-- ①：自己的手卡·卡组·场上的怪兽作为融合素材，把以「真红眼」怪兽为融合素材的1只融合怪兽融合召唤。这个效果特殊召唤的怪兽的卡名当作「真红眼黑龙」使用。
function c6172122.initial_effect(c)
	-- 这个卡名的卡在1回合只能发动1张，这张卡发动的回合，自己不能用这张卡的效果以外把怪兽召唤·特殊召唤。①：自己的手卡·卡组·场上的怪兽作为融合素材，把以「真红眼」怪兽为融合素材的1只融合怪兽融合召唤。这个效果特殊召唤的怪兽的卡名当作「真红眼黑龙」使用。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON+CATEGORY_DECKDES)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,6172122+EFFECT_COUNT_CODE_OATH)
	e1:SetCost(c6172122.cost)
	e1:SetTarget(c6172122.target)
	e1:SetOperation(c6172122.activate)
	c:RegisterEffect(e1)
end
-- 检查发动回合内是否进行过召唤·特殊召唤，并注册本回合不能用此卡效果以外召唤·特殊召唤的限制效果。
function c6172122.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查本回合在此卡发动前自己是否进行过通常召唤或特殊召唤。
	if chk==0 then return Duel.GetActivityCount(tp,ACTIVITY_SUMMON)==0 and Duel.GetActivityCount(tp,ACTIVITY_SPSUMMON)==0 end
	-- 这张卡发动的回合，自己不能用这张卡的效果以外把怪兽召唤·特殊召唤。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e1:SetTargetRange(1,0)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 注册不能通常召唤的玩家效果。
	Duel.RegisterEffect(e1,tp)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e2:SetLabelObject(e)
	e2:SetTarget(c6172122.splimit)
	-- 注册不能特殊召唤的玩家效果。
	Duel.RegisterEffect(e2,tp)
end
-- 限制只能通过此卡的效果进行特殊召唤。
function c6172122.splimit(e,c,sump,sumtype,sumpos,targetp,se)
	return se~=e:GetLabelObject()
end
-- 过滤可以作为融合素材送去墓地的怪兽（用于从卡组选择素材）。
function c6172122.filter0(c)
	return c:IsType(TYPE_MONSTER) and c:IsCanBeFusionMaterial() and c:IsAbleToGrave()
end
-- 过滤不受此卡效果影响的怪兽。
function c6172122.filter1(c,e)
	return not c:IsImmuneToEffect(e)
end
-- 过滤额外卡组中可以融合召唤的、且以「真红眼」怪兽为融合素材的融合怪兽。
function c6172122.filter2(c,e,tp,m,f,chkf)
	-- 检查怪兽是否为融合怪兽，且其融合素材列表中是否包含「真红眼」字段的怪兽。
	if not (c:IsType(TYPE_FUSION) and aux.IsMaterialListSetCard(c,0x3b) and (not f or f(c))
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_FUSION,tp,false,false)) then return false end
	-- 临时设置融合素材的额外检查函数，确保融合素材中包含「真红眼」怪兽。
	aux.FCheckAdditional=c.red_eyes_fusion_check or c6172122.fcheck
	local res=c:CheckFusionMaterial(m,nil,chkf)
	-- 重置融合素材额外检查函数。
	aux.FCheckAdditional=nil
	return res
end
-- 额外检查函数：检查选定的融合素材中是否至少包含一张「真红眼」字段的卡。
function c6172122.fcheck(tp,sg,fc)
	return sg:IsExists(Card.IsFusionSetCard,1,nil,0x3b)
end
-- 融合召唤效果的发动准备，检查是否存在合法的融合素材和可融合召唤的怪兽，并设置操作信息。
function c6172122.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local chkf=tp
		-- 获取玩家手卡和场上可用的融合素材。
		local mg1=Duel.GetFusionMaterial(tp)
		-- 获取玩家卡组中可作为融合素材的怪兽。
		local mg2=Duel.GetMatchingGroup(c6172122.filter0,tp,LOCATION_DECK,0,nil)
		mg1:Merge(mg2)
		-- 检查额外卡组是否存在可以使用手卡、卡组、场上素材进行融合召唤的「真红眼」相关融合怪兽。
		local res=Duel.IsExistingMatchingCard(c6172122.filter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg1,nil,chkf)
		if not res then
			-- 获取玩家受到的连锁素材效果。
			local ce=Duel.GetChainMaterial(tp)
			if ce~=nil then
				local fgroup=ce:GetTarget()
				local mg2=fgroup(ce,e,tp)
				local mf=ce:GetValue()
				-- 在连锁素材效果存在时，检查是否能使用其指定的素材进行融合召唤。
				res=Duel.IsExistingMatchingCard(c6172122.filter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg2,mf,chkf)
			end
		end
		return res
	end
	-- 设置连锁信息，表明此效果包含从额外卡组特殊召唤1只怪兽的操作。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- 融合召唤效果的处理，选择融合怪兽，决定素材并将其送去墓地，特殊召唤该融合怪兽并将其卡名变更为「真红眼黑龙」。
function c6172122.activate(e,tp,eg,ep,ev,re,r,rp)
	local chkf=tp
	-- 获取手卡和场上不受此卡效果影响以外的可用融合素材。
	local mg1=Duel.GetFusionMaterial(tp):Filter(c6172122.filter1,nil,e)
	-- 获取卡组中可作为融合素材的怪兽。
	local mg2=Duel.GetMatchingGroup(c6172122.filter0,tp,LOCATION_DECK,0,nil)
	mg1:Merge(mg2)
	-- 过滤出额外卡组中可以使用当前素材进行融合召唤的合法融合怪兽。
	local sg1=Duel.GetMatchingGroup(c6172122.filter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg1,nil,chkf)
	local mg3=nil
	local sg2=nil
	-- 获取玩家受到的连锁素材效果。
	local ce=Duel.GetChainMaterial(tp)
	if ce~=nil then
		local fgroup=ce:GetTarget()
		mg3=fgroup(ce,e,tp)
		local mf=ce:GetValue()
		-- 过滤出在使用连锁素材效果时可以融合召唤的合法融合怪兽。
		sg2=Duel.GetMatchingGroup(c6172122.filter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg3,mf,chkf)
	end
	if sg1:GetCount()>0 or (sg2~=nil and sg2:GetCount()>0) then
		local sg=sg1:Clone()
		if sg2 then sg:Merge(sg2) end
		-- 提示玩家选择要特殊召唤的怪兽。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		local tg=sg:Select(tp,1,1,nil)
		local tc=tg:GetFirst()
		-- 临时设置融合素材的额外检查函数，确保所选融合怪兽的素材中包含「真红眼」怪兽。
		aux.FCheckAdditional=tc.red_eyes_fusion_check or c6172122.fcheck
		-- 判断是否使用常规融合方式（而非连锁素材效果）进行融合召唤。
		if sg1:IsContains(tc) and (sg2==nil or not sg2:IsContains(tc) or not Duel.SelectYesNo(tp,ce:GetDescription())) then
			-- 让玩家从手卡、卡组、场上的素材中选择该融合怪兽所需的融合素材。
			local mat1=Duel.SelectFusionMaterial(tp,tc,mg1,nil,chkf)
			tc:SetMaterial(mat1)
			-- 将选定的融合素材因效果、素材、融合原因送去墓地。
			Duel.SendtoGrave(mat1,REASON_EFFECT+REASON_MATERIAL+REASON_FUSION)
			-- 中断当前效果处理，使后续的特殊召唤与送去墓地不视为同时处理。
			Duel.BreakEffect()
			-- 将融合怪兽以融合召唤的方式表侧表示特殊召唤到场上。
			Duel.SpecialSummon(tc,SUMMON_TYPE_FUSION,tp,tp,false,false,POS_FACEUP)
		else
			-- 在使用连锁素材效果时，让玩家选择对应的融合素材。
			local mat2=Duel.SelectFusionMaterial(tp,tc,mg3,nil,chkf)
			local fop=ce:GetOperation()
			fop(ce,e,tp,tc,mat2)
		end
		tc:CompleteProcedure()
		-- 这个效果特殊召唤的怪兽的卡名当作「真红眼黑龙」使用。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CHANGE_CODE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetValue(74677422)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
	end
	-- 重置融合素材额外检查函数。
	aux.FCheckAdditional=nil
end
