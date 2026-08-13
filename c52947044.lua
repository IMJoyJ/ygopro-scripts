--フュージョン・デステニー
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：自己的手卡·卡组的怪兽作为融合素材，把以「命运英雄」怪兽为融合素材的1只融合怪兽融合召唤。这个效果特殊召唤的怪兽在下个回合的结束阶段破坏。这张卡的发动后，直到回合结束时自己不是暗属性「英雄」怪兽不能特殊召唤。
local s,id,o=GetID()
-- 创建并注册「融合命运」的魔法卡发动效果，设置其为速攻魔法，可在自由时点发动，1回合只能发动1张，并指定目标选择与效果处理函数。
function s.initial_effect(c)
	-- 这个卡名的卡在1回合只能发动1张。①：自己的手卡·卡组的怪兽作为融合素材，把以「命运英雄」怪兽为融合素材的1只融合怪兽融合召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON+CATEGORY_DECKDES)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
-- 筛选可作为融合素材且能被送去墓地的怪兽，用于从卡组选出融合素材。
function s.filter0(c)
	return c:IsType(TYPE_MONSTER) and c:IsCanBeFusionMaterial() and c:IsAbleToGrave()
end
-- 筛选手牌中不免疫此效果且位于手卡的怪兽，使其可作为融合素材。
function s.filter1(c,e)
	return not c:IsImmuneToEffect(e) and c:IsLocation(LOCATION_HAND)
end
-- 筛选可作为融合召唤对象的额外卡组怪兽：必须是融合怪兽，其融合素材包含「命运英雄」字段，能被玩家融合召唤，且能用当前素材组进行融合。
function s.filter2(c,e,tp,m,f,chkf)
	-- 判断融合怪兽的融合素材是否包含「命运英雄」字段，并满足额外的素材条件（如有）。
	return c:IsType(TYPE_FUSION) and aux.IsMaterialListSetCard(c,0xc008) and (not f or f(c))
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_FUSION,tp,false,false) and c:CheckFusionMaterial(m,nil,chkf)
end
-- 额外素材检查：确认所选融合素材组中至少存在1只「命运英雄」怪兽，以满足融合素材要求。
function s.fcheck(tp,sg,fc)
	return sg:IsExists(Card.IsFusionSetCard,1,nil,0xc008)
end
-- 发动时的合法性判定：收集手牌与卡组中可作为素材的怪兽，检查额外卡组是否存在能够通过这些素材融合召唤的「命运英雄」融合怪兽；若存在则允许发动并设置特殊召唤的操作信息。
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local chkf=tp
		-- 从玩家可用的融合素材（含手卡·场上）中筛选出位于手卡的怪兽，作为潜在素材。
		local mg1=Duel.GetFusionMaterial(tp):Filter(Card.IsLocation,nil,LOCATION_HAND)
		-- 从卡组中筛选可作为融合素材且能送去墓地的怪兽，因为「融合命运」可以从卡组使用素材。
		local mg2=Duel.GetMatchingGroup(s.filter0,tp,LOCATION_DECK,0,nil)
		mg1:Merge(mg2)
		-- 设置当前融合操作的追加素材检查函数，强制要求素材组包含「命运英雄」怪兽。
		aux.FCheckAdditional=s.fcheck
		-- 检查额外卡组是否有符合条件的「命运英雄」融合怪兽能够在当前素材组下融合召唤。
		local res=Duel.IsExistingMatchingCard(s.filter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg1,nil,chkf)
		if not res then
			-- 获取连锁素材等替代融合素材效果，用于扩展可选择的融合素材。
			local ce=Duel.GetChainMaterial(tp)
			if ce~=nil then
				local fgroup=ce:GetTarget()
				local mg2=fgroup(ce,e,tp)
				local mf=ce:GetValue()
				-- 若存在替代融合素材效果，则使用该效果提供的素材组再次检查能否融合召唤目标怪兽。
				res=Duel.IsExistingMatchingCard(s.filter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg2,mf,chkf)
			end
		end
		-- 清除追加素材检查函数，避免残留影响后续其它效果。
		aux.FCheckAdditional=nil
		return res
	end
	-- 登记本次处理为特殊召唤操作，并声明从额外卡组特殊召唤1只怪兽，供后续效果检测使用。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- 效果处理：选择要融合召唤的「命运英雄」融合怪兽，从手卡·卡组选择融合素材送入墓地，以融合召唤方式特殊召唤；随后给该怪兽设置下个回合结束阶段破坏的效果，并赋予本回合只能特殊召唤暗属性「英雄」怪兽的限制。
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local chkf=tp
	-- 取玩家可用的融合素材中位于手卡且不免疫此效果的怪兽，作为通常素材候选。
	local mg1=Duel.GetFusionMaterial(tp):Filter(s.filter1,nil,e)
	-- 从卡组中选出可作融合素材且可送墓的怪兽，补入素材候选。
	local mg2=Duel.GetMatchingGroup(s.filter0,tp,LOCATION_DECK,0,nil)
	mg1:Merge(mg2)
	-- 再次设置追加素材检查，要求素材组必须包含「命运英雄」怪兽。
	aux.FCheckAdditional=s.fcheck
	-- 使用通常融合素材组，检索额外卡组中所有可被融合召唤的「命运英雄」融合怪兽。
	local sg1=Duel.GetMatchingGroup(s.filter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg1,nil,chkf)
	local mg3=nil
	local sg2=nil
	-- 获取连锁素材等替代素材效果，以支持使用其它区域的卡作为融合素材。
	local ce=Duel.GetChainMaterial(tp)
	if ce~=nil then
		local fgroup=ce:GetTarget()
		mg3=fgroup(ce,e,tp)
		local mf=ce:GetValue()
		-- 使用替代素材效果提供的素材组，检索额外卡组中可融合召唤的融合怪兽候选。
		sg2=Duel.GetMatchingGroup(s.filter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg3,mf,chkf)
	end
	if sg1:GetCount()>0 or (sg2~=nil and sg2:GetCount()>0) then
		local sg=sg1:Clone()
		if sg2 then sg:Merge(sg2) end
		-- 提示玩家从候选融合怪兽中选择要特殊召唤的1只。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		local tg=sg:Select(tp,1,1,nil)
		local tc=tg:GetFirst()
		-- 判断所选融合怪兽属于通常素材还是替代素材：若属于通常素材，或未被替代素材包含，或玩家选择不使用替代素材，则采用通常素材融合；否则使用替代素材流程。
		if sg1:IsContains(tc) and (sg2==nil or not sg2:IsContains(tc) or not Duel.SelectYesNo(tp,ce:GetDescription())) then
			-- 玩家从通常素材组中挑选实际送入墓地的融合素材。
			local mat1=Duel.SelectFusionMaterial(tp,tc,mg1,nil,chkf)
			tc:SetMaterial(mat1)
			-- 将融合素材卡送去墓地，作为融合召唤的素材消耗。
			Duel.SendtoGrave(mat1,REASON_EFFECT+REASON_MATERIAL+REASON_FUSION)
			-- 中断当前效果处理，使后续的融合召唤不视为与素材送墓同时处理，以正确触发时点。
			Duel.BreakEffect()
			-- 以融合召唤方式，将被选择的融合怪兽特殊召唤到己方场上。
			Duel.SpecialSummon(tc,SUMMON_TYPE_FUSION,tp,tp,false,false,POS_FACEUP)
		else
			-- 玩家从替代素材组中选择融合素材，交给替代融合效果处理。
			local mat2=Duel.SelectFusionMaterial(tp,tc,mg3,nil,chkf)
			local fop=ce:GetOperation()
			fop(ce,e,tp,tc,mat2)
		end
		tc:CompleteProcedure()
		tc:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,2)
		-- 这个效果特殊召唤的怪兽在下个回合的结束阶段破坏。这张卡的发动后，直到回合结束时自己不是暗属性「英雄」怪兽不能特殊召唤。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_PHASE+PHASE_END)
		e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
		e1:SetCondition(s.descon)
		e1:SetOperation(s.desop)
		e1:SetReset(RESET_PHASE+PHASE_END,2)
		e1:SetCountLimit(1)
		-- 记录当前回合数，用于确定破坏应在下一个回合的结束阶段执行。
		e1:SetLabel(Duel.GetTurnCount())
		e1:SetLabelObject(tc)
		-- 将下个回合结束阶段破坏怪兽的持续效果注册到场上，由己方控制。
		Duel.RegisterEffect(e1,tp)
	end
	-- 清除追加素材检查函数，避免残留影响后续其它效果。
	aux.FCheckAdditional=nil
	if not e:IsHasType(EFFECT_TYPE_ACTIVATE) then return end
	-- 这个效果特殊召唤的怪兽在下个回合的结束阶段破坏。这张卡的发动后，直到回合结束时自己不是暗属性「英雄」怪兽不能特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetTargetRange(1,0)
	e2:SetTarget(s.splimit)
	e2:SetReset(RESET_PHASE+PHASE_END)
	-- 将特殊召唤限制效果注册到场上，使己方在本回合结束前只能特殊召唤符合条件的怪兽。
	Duel.RegisterEffect(e2,tp)
end
-- 破坏的条件：当前回合数已变更（进入下个回合），且该怪兽仍带有「融合命运」的flag标记，即仍在下个回合的结束阶段。
function s.descon(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	-- 确认已到下个回合且怪兽未被其它效果重置或离场，此时才满足破坏条件。
	return Duel.GetTurnCount()~=e:GetLabel() and tc:GetFlagEffect(id)~=0
end
-- 破坏处理：在满足条件时，把融合命运特殊召唤的怪兽破坏。
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 向双方展示「融合命运」的卡片动画，提示其破坏效果正在处理。
	Duel.Hint(HINT_CARD,0,id)
	local tc=e:GetLabelObject()
	-- 以效果原因破坏该怪兽。
	Duel.Destroy(tc,REASON_EFFECT)
end
-- 限制条件：只有暗属性且字段为「英雄」的怪兽才能被特殊召唤，其它怪兽不能特殊召唤。
function s.splimit(e,c)
	return not (c:IsAttribute(ATTRIBUTE_DARK) and c:IsSetCard(0x8))
end
