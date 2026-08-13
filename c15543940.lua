--タイラント・ダイナ・フュージョン
-- 效果：
-- ①：「恐龙摔跤手」融合怪兽卡决定的融合素材怪兽从自己场上送去墓地，把那1只融合怪兽从额外卡组融合召唤。这个效果特殊召唤的怪兽只在场上表侧表示存在才有1次不会被战斗·效果破坏。
function c15543940.initial_effect(c)
	-- ①：「恐龙摔跤手」融合怪兽卡决定的融合素材怪兽从自己场上送去墓地，把那1只融合怪兽从额外卡组融合召唤。这个效果特殊召唤的怪兽只在场上表侧表示存在才有1次不会被战斗·效果破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(15543940,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c15543940.target)
	e1:SetOperation(c15543940.activate)
	c:RegisterEffect(e1)
end
-- 检查怪兽是否在场上且不免疫当前效果，用于筛选可作为融合素材的场上怪兽。
function c15543940.filter1(c,e)
	return c:IsOnField() and not c:IsImmuneToEffect(e)
end
-- 检查额外卡组的融合怪兽是否为「恐龙摔跤手」字段的融合怪兽、满足追加素材条件、能够以融合召唤方式特殊召唤，并且能用给定素材进行融合召唤，用于筛选可融合召唤的融合怪兽候选。
function c15543940.filter2(c,e,tp,m,f,chkf)
	return c:IsSetCard(0x11a) and c:IsType(TYPE_FUSION) and (not f or f(c))
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_FUSION,tp,false,false) and c:CheckFusionMaterial(m,nil,chkf)
end
-- 发动时的合法性检查：先检查能否用场上素材进行融合召唤；若不能且存在连锁素材，则再检查能否用连锁素材进行融合召唤；判定合法后设置本次效果将进行特殊召唤的操作信息。
function c15543940.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local chkf=tp
		-- 获取自己可用的全部融合素材，并仅保留场上的怪兽，作为本效果的普通融合素材候选。
		local mg1=Duel.GetFusionMaterial(tp):Filter(Card.IsOnField,nil)
		-- 检查额外卡组是否存在至少1只符合条件的融合怪兽，且能用当前场上素材作为融合素材进行融合召唤。
		local res=Duel.IsExistingMatchingCard(c15543940.filter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg1,nil,chkf)
		if not res then
			-- 获取当前玩家适用的连锁素材效果（例如可用对方场上的怪兽作为素材等的类似效果）。
			local ce=Duel.GetChainMaterial(tp)
			if ce~=nil then
				local fgroup=ce:GetTarget()
				local mg2=fgroup(ce,e,tp)
				local mf=ce:GetValue()
				-- 当普通素材无法进行融合时，改用连锁素材提供的素材组和素材条件，再次检查额外卡组是否存在可融合召唤的怪兽。
				res=Duel.IsExistingMatchingCard(c15543940.filter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg2,mf,chkf)
			end
		end
		return res
	end
	-- 设置本次效果的操作信息：将从额外卡组特殊召唤1只怪兽，供其他卡的效果进行发动检测。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- 效果处理流程：取得普通素材与连锁素材下的所有可融合召唤候选，由玩家选择1只融合怪兽；若使用普通素材则选择素材送入墓地并融合召唤，若使用连锁素材则调用其处理；融合成功后给该怪兽赋予只限表侧表示在场时1次的战斗·效果破坏抗性。
function c15543940.activate(e,tp,eg,ep,ev,re,r,rp)
	local chkf=tp
	-- 获取可用的普通融合素材，并排除不受当前效果影响的卡，确保实际送墓的素材符合效果要求。
	local mg1=Duel.GetFusionMaterial(tp):Filter(c15543940.filter1,nil,e)
	-- 获取额外卡组中能够使用普通素材mg1进行融合召唤的融合怪兽集合。
	local sg1=Duel.GetMatchingGroup(c15543940.filter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg1,nil,chkf)
	local mg2=nil
	local sg2=nil
	-- 获取当前玩家适用的连锁素材效果（如果存在）。
	local ce=Duel.GetChainMaterial(tp)
	if ce~=nil then
		local fgroup=ce:GetTarget()
		mg2=fgroup(ce,e,tp)
		local mf=ce:GetValue()
		-- 获取额外卡组中能够使用连锁素材提供的素材组mg2及其条件mf进行融合召唤的融合怪兽集合。
		sg2=Duel.GetMatchingGroup(c15543940.filter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg2,mf,chkf)
	end
	if sg1:GetCount()>0 or (sg2~=nil and sg2:GetCount()>0) then
		local sg=sg1:Clone()
		if sg2 then sg:Merge(sg2) end
		-- 显示“请选择要特殊召唤的卡”的提示，让玩家从候选融合怪兽中选择1只。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		local tg=sg:Select(tp,1,1,nil)
		local tc=tg:GetFirst()
		-- 判断所选的融合怪兽是否可以通过普通素材融合，且（当连锁素材也包含该怪兽时）玩家是否选择不使用连锁素材；若满足则走普通融合流程，否则走连锁素材融合流程。
		if sg1:IsContains(tc) and (sg2==nil or not sg2:IsContains(tc) or not Duel.SelectYesNo(tp,ce:GetDescription())) then
			-- 从普通素材组中选择融合怪兽tc所需的融合素材。
			local mat1=Duel.SelectFusionMaterial(tp,tc,mg1,nil,chkf)
			tc:SetMaterial(mat1)
			-- 将选中的融合素材从场上送去墓地，原因记为效果、融合素材和融合召唤。
			Duel.SendtoGrave(mat1,REASON_EFFECT+REASON_MATERIAL+REASON_FUSION)
			-- 中断当前效果处理，使素材送墓与融合召唤不在同一时点被处理，以正确触发召唤成功时点。
			Duel.BreakEffect()
			-- 将融合怪兽tc以融合召唤方式特殊召唤到自己的场上，正面表示，不检查召唤条件、不限制苏生限制。
			Duel.SpecialSummon(tc,SUMMON_TYPE_FUSION,tp,tp,false,false,POS_FACEUP)
		else
			-- 从连锁素材提供的素材组中选择融合怪兽tc所需的融合素材。
			local mat2=Duel.SelectFusionMaterial(tp,tc,mg2,nil,chkf)
			local fop=ce:GetOperation()
			fop(ce,e,tp,tc,mat2)
		end
		tc:CompleteProcedure()
		-- 这个效果特殊召唤的怪兽只在场上表侧表示存在才有1次不会被战斗·效果破坏。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetDescription(aux.Stringid(15543940,1))  --"「暴君恐龙融合」特殊召唤"
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE+EFFECT_FLAG_CLIENT_HINT+EFFECT_FLAG_NO_TURN_RESET)
		e1:SetRange(LOCATION_ONFIELD)
		e1:SetCode(EFFECT_INDESTRUCTABLE_COUNT)
		e1:SetCountLimit(1)
		e1:SetValue(c15543940.indct)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
	end
end
-- 判断破坏原因是否为战斗或效果；若是则返回1表示提供1次不破坏，否则返回0。
function c15543940.indct(e,re,r,rp)
	if bit.band(r,REASON_BATTLE+REASON_EFFECT)~=0 then
		return 1
	else return 0 end
end
