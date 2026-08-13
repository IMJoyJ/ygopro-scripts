--羅睺星辰
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：自己的手卡·卡组·场上的怪兽作为融合素材，把1只「星辰」融合怪兽融合召唤。这张卡的发动后，直到回合结束时自己不是融合怪兽不能从额外卡组特殊召唤。
local s,id,o=GetID()
-- 定义初始效果函数：创建并注册本卡效果e1，该效果为魔法卡发动（自由时点），1回合1次（誓约计数），类别涵盖特殊召唤、融合召唤及卡组送墓。
function s.initial_effect(c)
	-- 对应效果原文：这个卡名的卡在1回合只能发动1张。①：自己的手卡·卡组·场上的怪兽作为融合素材，把1只「星辰」融合怪兽融合召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON+CATEGORY_DECKDES)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
-- 定义卡组素材的过滤条件：该卡必须是怪兽、能够作为融合素材且能被送去墓地。
function s.filter0(c)
	return c:IsType(TYPE_MONSTER) and c:IsCanBeFusionMaterial() and c:IsAbleToGrave()
end
-- 定义普通素材的过滤条件：该卡不能免疫当前效果（不能是免疫此效果的卡）。
function s.filter1(c,e)
	return not c:IsImmuneToEffect(e)
end
-- 定义融合怪兽候选的过滤条件：必须是融合怪兽且具有「星辰」字段，符合融合素材条件（包括连锁素材），并能够被当前玩家以融合召唤方式特殊召唤。
function s.filter2(c,e,tp,m,f,chkf)
	if not (c:IsType(TYPE_FUSION) and c:IsSetCard(0x1c9) and (not f or f(c))
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_FUSION,tp,false,false)) then return false end
	return c:CheckFusionMaterial(m,nil,chkf)
end
-- 发动时的合法性检查：确认能否从额外卡组选出1只「星辰」融合怪兽，并能用手卡·场上的可用怪兽以及卡组中符合条件的怪兽作为融合素材；若存在连锁素材效果也纳入检查；满足后登记特殊召唤操作信息。
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local chkf=tp
		-- 取得当前玩家可用的融合素材组（手卡·场上及受额外融合素材效果影响的卡），并过滤掉对此效果免疫的卡。
		local mg1=Duel.GetFusionMaterial(tp):Filter(s.filter1,nil,e)
		-- 从卡组中筛选可作为融合素材且能送去墓地的怪兽，补充到融合素材候选组。
		local mg2=Duel.GetMatchingGroup(s.filter0,tp,LOCATION_DECK,0,nil)
		mg1:Merge(mg2)
		-- 检查额外卡组是否存在至少1只「星辰」融合怪兽，能够用上述手卡/场上/卡组素材作为融合素材进行融合召唤。
		local res=Duel.IsExistingMatchingCard(s.filter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg1,nil,chkf)
		if not res then
			-- 获取当前玩家适用的“连锁素材”类效果（若存在），以便后续使用连锁素材来融合召唤。
			local ce=Duel.GetChainMaterial(tp)
			if ce~=nil then
				local fgroup=ce:GetTarget()
				local mg3=fgroup(ce,e,tp)
				local mf=ce:GetValue()
				-- 使用连锁素材效果提供的素材组再次检查是否存在可融合召唤的「星辰」融合怪兽。
				res=Duel.IsExistingMatchingCard(s.filter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg3,mf,chkf)
			end
		end
		return res
	end
	-- 登记本次效果处理将进行特殊召唤：从额外卡组特殊召唤1只怪兽。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- 效果处理函数：实际执行融合召唤，从可选融合怪兽中选择1只「星辰」融合怪兽，再选择素材；普通素材（含卡组素材）送墓后融合召唤，若使用连锁素材则按连锁素材效果处理；然后适用自肃效果，直到回合结束时自己不能从额外卡组特殊召唤非融合怪兽。
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local chkf=tp
	-- 取得当前玩家可用的融合素材组（手卡·场上），并过滤掉对此效果免疫的卡。
	local mg1=Duel.GetFusionMaterial(tp):Filter(s.filter1,nil,e)
	-- 从卡组中筛选可作为融合素材且能送去墓地的怪兽，作为素材候选。
	local mg2=Duel.GetMatchingGroup(s.filter0,tp,LOCATION_DECK,0,nil)
	mg1:Merge(mg2)
	-- 获取所有能使用mg1作为素材进行融合召唤的「星辰」融合怪兽候选。
	local sg1=Duel.GetMatchingGroup(s.filter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg1,nil,chkf)
	local mg3=nil
	local sg2=nil
	-- 获取当前玩家适用的“连锁素材”类效果（若存在）。
	local ce=Duel.GetChainMaterial(tp)
	if ce~=nil then
		local fgroup=ce:GetTarget()
		mg3=fgroup(ce,e,tp)
		local mf=ce:GetValue()
		-- 获取所有能使用连锁素材效果提供的素材进行融合召唤的「星辰」融合怪兽候选。
		sg2=Duel.GetMatchingGroup(s.filter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg3,mf,chkf)
	end
	if sg1:GetCount()>0 or (sg2~=nil and sg2:GetCount()>0) then
		local sg=sg1:Clone()
		if sg2 then sg:Merge(sg2) end
		-- 提示玩家从可选融合怪兽中选择1只要特殊召唤的怪兽。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		local tg=sg:Select(tp,1,1,nil)
		local tc=tg:GetFirst()
		-- 判断所选的融合怪兽是否属于普通素材候选且不属于连锁素材候选，或玩家选择不使用连锁素材；若是则走普通融合召唤流程，否则走连锁素材流程。
		if sg1:IsContains(tc) and (sg2==nil or not sg2:IsContains(tc) or ce and not Duel.SelectYesNo(tp,ce:GetDescription())) then
			-- 让玩家从普通素材组中选择该融合怪兽实际使用的融合素材（可包含手卡·场上及卡组中的素材）。
			local mat1=Duel.SelectFusionMaterial(tp,tc,mg1,nil,chkf)
			tc:SetMaterial(mat1)
			-- 将选择的融合素材送去墓地，作为融合召唤的素材消耗。
			Duel.SendtoGrave(mat1,REASON_EFFECT+REASON_MATERIAL+REASON_FUSION)
			-- 中断当前效果处理，使此后的融合召唤特殊召唤视为不同时处理，避免错过时点。
			Duel.BreakEffect()
			-- 将选择的「星辰」融合怪兽以融合召唤方式表侧表示特殊召唤到己方场上。
			Duel.SpecialSummon(tc,SUMMON_TYPE_FUSION,tp,tp,false,false,POS_FACEUP)
		elseif ce then
			-- 若使用连锁素材，则让玩家从连锁素材组中选择融合召唤所需的融合素材。
			local mat2=Duel.SelectFusionMaterial(tp,tc,mg3,nil,chkf)
			local fop=ce:GetOperation()
			fop(ce,e,tp,tc,mat2)
		end
		tc:CompleteProcedure()
	end
	if not e:IsHasType(EFFECT_TYPE_ACTIVATE) then return end
	-- 对应效果原文：这张卡的发动后，直到回合结束时自己不是融合怪兽不能从额外卡组特殊召唤。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetTarget(s.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将自肃效果注册给当前玩家，持续到结束阶段。
	Duel.RegisterEffect(e1,tp)
end
-- 自肃判定条件：从额外卡组不能特殊召唤非融合怪兽（仅限制额外卡组来源）。
function s.splimit(e,c)
	return not c:IsType(TYPE_FUSION) and c:IsLocation(LOCATION_EXTRA)
end
