--スキャッター・フュージョン
-- 效果：
-- 这个卡名的①的效果1回合只能使用1次。
-- ①：对方场上有怪兽存在的场合才能发动。岩石族以外的「宝石骑士」融合怪兽卡决定的融合素材怪兽从自己卡组送去墓地，把那1只融合怪兽从额外卡组融合召唤。这张卡从场上离开时那只怪兽破坏。这个效果的发动后，直到回合结束时自己不是「宝石骑士」怪兽不能从额外卡组特殊召唤。
function c40597694.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- 这个卡名的①的效果1回合只能使用1次。①：对方场上有怪兽存在的场合才能发动。岩石族以外的「宝石骑士」融合怪兽卡决定的融合素材怪兽从自己卡组送去墓地，把那1只融合怪兽从额外卡组融合召唤。这个效果的发动后，直到回合结束时自己不是「宝石骑士」怪兽不能从额外卡组特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON+CATEGORY_DECKDES)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1,40597694)
	e2:SetCondition(c40597694.condition)
	e2:SetTarget(c40597694.target)
	e2:SetOperation(c40597694.operation)
	c:RegisterEffect(e2)
	-- 这张卡从场上离开时那只怪兽破坏。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_SINGLE)
	e3:SetCode(EVENT_LEAVE_FIELD)
	e3:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e3:SetOperation(c40597694.desop)
	c:RegisterEffect(e3)
end
-- 效果发动条件：确认对方场上有怪兽存在，否则不能发动。
function c40597694.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 统计对方场上的主要怪兽区怪兽数量大于0，即对方场上有怪兽存在。
	return Duel.GetFieldGroupCount(tp,0,LOCATION_MZONE)>0
end
-- 筛选卡组中满足条件是怪兽、可作为融合素材且可送去墓地的卡，作为融合素材候选。
function c40597694.filter0(c)
	return c:IsType(TYPE_MONSTER) and c:IsCanBeFusionMaterial() and c:IsAbleToGrave()
end
-- 筛选卡组中可作为融合素材、可送去墓地且不受本效果影响的怪兽，作为实际处理时的素材候选。
function c40597694.filter1(c,e)
	return c:IsType(TYPE_MONSTER) and c:IsCanBeFusionMaterial() and c:IsAbleToGrave() and not c:IsImmuneToEffect(e)
end
-- 筛选额外卡组中岩石族以外的「宝石骑士」融合怪兽，且能用指定素材融合召唤、能够被特殊召唤。
function c40597694.filter2(c,e,tp,m,f,chkf)
	return c:IsType(TYPE_FUSION) and c:IsSetCard(0x1047) and not c:IsRace(RACE_ROCK) and (not f or f(c))
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_FUSION,tp,false,false) and c:CheckFusionMaterial(m,nil,chkf)
end
-- 效果发动时的处理：验证是否存在可融合召唤的符合条件的「宝石骑士」融合怪兽，并登记特殊召唤的操作信息。
function c40597694.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local chkf=tp
		-- 获取卡组中所有可作为融合素材且能送去墓地的怪兽，组成候选素材组。
		local mg1=Duel.GetMatchingGroup(c40597694.filter0,tp,LOCATION_DECK,0,nil)
		-- 检查额外卡组是否存在1只可用卡组素材融合召唤的符合条件的「宝石骑士」融合怪兽。
		local res=Duel.IsExistingMatchingCard(c40597694.filter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg1,nil,chkf)
		if not res then
			-- 获取当前玩家适用的连锁素材效果，以便后续使用其提供的融合素材。
			local ce=Duel.GetChainMaterial(tp)
			if ce~=nil then
				local fgroup=ce:GetTarget()
				local mg2=fgroup(ce,e,tp)
				local mf=ce:GetValue()
				-- 若普通卡组素材不可行，则检查使用连锁素材提供的素材后是否存在可融合召唤的候选。
				res=Duel.IsExistingMatchingCard(c40597694.filter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg2,mf,chkf)
			end
		end
		return res
	end
	-- 登记效果处理时将从额外卡组特殊召唤1只怪兽的操作信息。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- 效果处理：从卡组选择融合素材，将1只符合条件的「宝石骑士」融合怪兽融合召唤；并给自身附加特殊召唤自肃。
function c40597694.operation(e,tp,eg,ep,ev,re,r,rp)
	local chkf=tp
	-- 获取效果实际处理时卡组中可作为融合素材且可送去墓地、不受本效果影响的怪兽。
	local mg1=Duel.GetMatchingGroup(c40597694.filter1,tp,LOCATION_DECK,0,nil,e)
	-- 获取可用卡组素材融合召唤的额外卡组候选怪兽。
	local sg1=Duel.GetMatchingGroup(c40597694.filter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg1,nil,chkf)
	local mg2=nil
	local sg2=nil
	-- 获取连锁素材效果，用于决定是否使用替代素材。
	local ce=Duel.GetChainMaterial(tp)
	if ce~=nil then
		local fgroup=ce:GetTarget()
		mg2=fgroup(ce,e,tp)
		local mf=ce:GetValue()
		-- 获取使用连锁素材时可供融合召唤的额外卡组候选怪兽。
		sg2=Duel.GetMatchingGroup(c40597694.filter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg2,mf,chkf)
	end
	if sg1:GetCount()>0 or (sg2~=nil and sg2:GetCount()>0) then
		local sg=sg1:Clone()
		if sg2 then sg:Merge(sg2) end
		-- 提示玩家选择要特殊召唤的融合怪兽。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		local tg=sg:Select(tp,1,1,nil)
		local tc=tg:GetFirst()
		-- 判断所选怪兽是否由卡组素材融合召唤，并确认是否使用连锁素材，从而选择素材来源。
		if sg1:IsContains(tc) and (sg2==nil or not sg2:IsContains(tc) or not Duel.SelectYesNo(tp,ce:GetDescription())) then
			-- 让玩家从卡组素材中选择该融合怪兽所需的融合素材。
			local mat1=Duel.SelectFusionMaterial(tp,tc,mg1,nil,chkf)
			tc:SetMaterial(mat1)
			-- 将选择的融合素材从卡组送去墓地（作为融合素材）。
			Duel.SendtoGrave(mat1,REASON_EFFECT+REASON_MATERIAL+REASON_FUSION)
			-- 中断当前效果处理，使随后的融合召唤视为新的处理，避免时点问题。
			Duel.BreakEffect()
			-- 以融合召唤方式将那1只融合怪兽特殊召唤到自己的主要怪兽区。
			Duel.SpecialSummon(tc,SUMMON_TYPE_FUSION,tp,tp,false,false,POS_FACEUP)
		else
			-- 当使用连锁素材时，从中选择该融合怪兽所需的融合素材。
			local mat2=Duel.SelectFusionMaterial(tp,tc,mg2,nil,chkf)
			local fop=ce:GetOperation()
			fop(ce,e,tp,tc,mat2)
		end
		tc:CompleteProcedure()
		e:GetHandler():SetCardTarget(tc)
	end
	-- 这张卡从场上离开时那只怪兽破坏。这个效果的发动后，直到回合结束时自己不是「宝石骑士」怪兽不能从额外卡组特殊召唤。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetTarget(c40597694.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 把自肃效果注册给当前玩家，持续到回合结束。
	Duel.RegisterEffect(e1,tp)
end
-- 自肃条件：不能从额外卡组特殊召唤「宝石骑士」怪兽以外的怪兽。
function c40597694.splimit(e,c)
	return not c:IsSetCard(0x1047) and c:IsLocation(LOCATION_EXTRA)
end
-- 这张卡从场上离开时，取得与其关联的融合怪兽，并将其破坏。
function c40597694.desop(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetHandler():GetFirstCardTarget()
	if tc and tc:IsLocation(LOCATION_MZONE) then
		-- 以效果破坏那只与这张卡关联的融合怪兽。
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
