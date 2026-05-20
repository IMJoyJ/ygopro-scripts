--究極融合
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：自己·对方的主要阶段才能发动。自己的手卡·场上·墓地的怪兽作为融合素材回到卡组，把以「青眼白龙」或「青眼究极龙」为融合素材的1只融合怪兽融合召唤。那之后，可以把最多有那些作为融合素材的场上的「青眼白龙」「青眼究极龙」数量的对方场上的表侧表示卡破坏。
function c71143015.initial_effect(c)
	-- 注册卡片记有「青眼白龙」和「青眼究极龙」的卡名信息。
	aux.AddCodeList(c,89631139,23995346)
	-- ①：自己·对方的主要阶段才能发动。自己的手卡·场上·墓地的怪兽作为融合素材回到卡组，把以「青眼白龙」或「青眼究极龙」为融合素材的1只融合怪兽融合召唤。那之后，可以把最多有那些作为融合素材的场上的「青眼白龙」「青眼究极龙」数量的对方场上的表侧表示卡破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON+CATEGORY_GRAVE_ACTION)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_MAIN_END)
	e1:SetCountLimit(1,71143015+EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(c71143015.condition)
	e1:SetTarget(c71143015.target)
	e1:SetOperation(c71143015.activate)
	c:RegisterEffect(e1)
end
-- 检查发动条件是否为自己或对方的主要阶段。
function c71143015.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前的阶段。
	local ph=Duel.GetCurrentPhase()
	return ph==PHASE_MAIN1 or ph==PHASE_MAIN2
end
-- 过滤可作为融合素材回到卡组的手卡、场上、墓地的怪兽。
function c71143015.filter0(c,e)
	return c:IsType(TYPE_MONSTER) and c:IsCanBeFusionMaterial() and c:IsAbleToDeck() and not c:IsImmuneToEffect(e)
end
-- 过滤额外卡组中可以进行融合召唤的、以「青眼白龙」或「青眼究极龙」为素材的融合怪兽。
function c71143015.filter1(c,e,tp,m,f,chkf)
	-- 检查怪兽是否为融合怪兽，且其素材列表中是否记有「青眼白龙」或「青眼究极龙」。
	if not (c:IsType(TYPE_FUSION) and (aux.IsMaterialListCode(c,89631139) or aux.IsMaterialListCode(c,23995346)) and (not f or f(c))
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_FUSION,tp,false,false)) then return false end
	-- 设置用于融合素材检查的额外过滤函数，确保素材中包含「青眼白龙」或「青眼究极龙」。
	aux.FCheckAdditional=c.ultimate_fusion_check or c71143015.fcheck
	local res=c:CheckFusionMaterial(m,nil,chkf)
	-- 清空额外融合素材检查函数。
	aux.FCheckAdditional=nil
	return res
end
-- 融合素材合法性检查函数：若融合怪兽要求「青眼白龙」/「青眼究极龙」，则选用的素材中必须包含对应的卡。
function c71143015.fcheck(tp,sg,fc)
	-- 检查选用的素材中是否包含「青眼白龙」，且融合怪兽的素材列表中记有「青眼白龙」。
	return sg:IsExists(Card.IsFusionCode,1,nil,89631139) and aux.IsMaterialListCode(fc,89631139)
		-- 或者检查选用的素材中是否包含「青眼究极龙」，且融合怪兽的素材列表中记有「青眼究极龙」。
		or sg:IsExists(Card.IsFusionCode,1,nil,23995346) and aux.IsMaterialListCode(fc,23995346)
end
-- 效果发动的合法性检测与操作信息设置。
function c71143015.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local chkf=tp
		-- 获取自己手卡、场上、墓地中可用作融合素材的怪兽组。
		local mg=Duel.GetMatchingGroup(c71143015.filter0,tp,LOCATION_HAND+LOCATION_ONFIELD+LOCATION_GRAVE,0,nil,e)
		-- 检查额外卡组是否存在可以使用上述素材进行融合召唤的合法融合怪兽。
		local res=Duel.IsExistingMatchingCard(c71143015.filter1,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg,nil,chkf)
		if not res then
			-- 检查是否存在适用的连锁素材效果（如「连锁素材」）。
			local ce=Duel.GetChainMaterial(tp)
			if ce~=nil then
				local fgroup=ce:GetTarget()
				local mg3=fgroup(ce,e,tp)
				local mf=ce:GetValue()
				-- 检查在使用连锁素材效果提供的素材时，是否存在可融合召唤的合法融合怪兽。
				res=Duel.IsExistingMatchingCard(c71143015.filter1,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg3,mf,chkf)
			end
		end
		return res
	end
	-- 设置当前效果处理的操作信息为：从额外卡组特殊召唤1只怪兽。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- 过滤作为融合素材且原本在场上的「青眼白龙」或「青眼究极龙」。
function c71143015.desfilter(c)
	return c:IsFusionCode(89631139,23995346) and c:IsOnField()
end
-- 效果处理的核心逻辑：进行融合召唤，并根据场上素材数量决定是否破坏对方场上的表侧表示卡。
function c71143015.activate(e,tp,eg,ep,ev,re,r,rp)
	local chkf=tp
	-- 获取受「王家之谷」影响过滤后的、自己手卡、场上、墓地的融合素材怪兽组。
	local mg=Duel.GetMatchingGroup(aux.NecroValleyFilter(c71143015.filter0),tp,LOCATION_HAND+LOCATION_ONFIELD+LOCATION_GRAVE,0,nil,e)
	-- 获取额外卡组中可以使用当前素材进行融合召唤的融合怪兽组。
	local sg1=Duel.GetMatchingGroup(c71143015.filter1,tp,LOCATION_EXTRA,0,nil,e,tp,mg,nil,chkf)
	local mg3=nil
	local sg2=nil
	local ct=0
	local spchk=0
	-- 获取玩家受到的连锁素材效果。
	local ce=Duel.GetChainMaterial(tp)
	if ce~=nil then
		local fgroup=ce:GetTarget()
		mg3=fgroup(ce,e,tp)
		local mf=ce:GetValue()
		-- 获取在使用连锁素材效果时，额外卡组中可以融合召唤的融合怪兽组。
		sg2=Duel.GetMatchingGroup(c71143015.filter1,tp,LOCATION_EXTRA,0,nil,e,tp,mg3,mf,chkf)
	end
	if sg1:GetCount()>0 or (sg2~=nil and sg2:GetCount()>0) then
		local sg=sg1:Clone()
		if sg2 then sg:Merge(sg2) end
		-- 提示玩家选择要特殊召唤的怪兽。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		local tg=sg:Select(tp,1,1,nil)
		local tc=tg:GetFirst()
		-- 设定所选融合怪兽对应的额外素材检查函数。
		aux.FCheckAdditional=tc.ultimate_fusion_check or c71143015.fcheck
		-- 判断是否使用常规融合方式（而非连锁素材效果）进行融合召唤。
		if sg1:IsContains(tc) and (sg2==nil or not sg2:IsContains(tc) or not Duel.SelectYesNo(tp,ce:GetDescription())) then
			-- 让玩家选择用于融合召唤该怪兽的融合素材。
			local mat1=Duel.SelectFusionMaterial(tp,tc,mg,nil,chkf)
			ct=mat1:FilterCount(c71143015.desfilter,nil)
			tc:SetMaterial(mat1)
			if mat1:IsExists(Card.IsFacedown,1,nil) then
				local cg=mat1:Filter(Card.IsFacedown,nil)
				-- 向对方玩家确认被选为素材的里侧表示卡片。
				Duel.ConfirmCards(1-tp,cg)
			end
			if mat1:Filter(c71143015.cfilter,nil):GetCount()>0 then
				local cg=mat1:Filter(c71143015.cfilter,nil)
				-- 在场上或墓地中对被选为素材的卡片进行闪烁提示。
				Duel.HintSelection(cg)
			end
			-- 将选定的融合素材怪兽送回持有者卡组并洗牌。
			Duel.SendtoDeck(mat1,nil,SEQ_DECKSHUFFLE,REASON_EFFECT+REASON_MATERIAL+REASON_FUSION)
			-- 产生时点中断，使后续的特殊召唤处理与送回卡组不视为同时进行。
			Duel.BreakEffect()
			-- 将融合怪兽以融合召唤的方式表侧表示特殊召唤到场上。
			Duel.SpecialSummon(tc,SUMMON_TYPE_FUSION,tp,tp,false,false,POS_FACEUP)
			spchk=1
		else
			-- 使用连锁素材效果提供的素材组选择融合素材。
			local mat2=Duel.SelectFusionMaterial(tp,tc,mg3,nil,chkf)
			ct=mat2:FilterCount(c71143015.desfilter,nil)
			local fop=ce:GetOperation()
			fop(ce,e,tp,tc,mat2)
			spchk=1
		end
		tc:CompleteProcedure()
	end
	-- 重置额外融合素材检查函数。
	aux.FCheckAdditional=nil
	-- 检查是否有原本在场上的「青眼白龙」或「青眼究极龙」作为素材，且对方场上存在表侧表示卡片，并询问玩家是否发动破坏效果。
	if ct>0 and spchk>0 and Duel.IsExistingMatchingCard(Card.IsFaceup,tp,0,LOCATION_ONFIELD,1,nil) and Duel.SelectYesNo(tp,aux.Stringid(71143015,0)) then  --"是否选对方的卡破坏？"
		-- 产生时点中断，使后续的破坏处理与融合召唤不视为同时进行。
		Duel.BreakEffect()
		-- 提示玩家选择要破坏的卡片。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
		-- 让玩家选择最多等同于场上素材数量的对方场上的表侧表示卡片。
		local dg=Duel.SelectMatchingCard(tp,Card.IsFaceup,tp,0,LOCATION_ONFIELD,1,ct,nil)
		-- 对选定要破坏的卡片进行闪烁提示。
		Duel.HintSelection(dg)
		-- 破坏选定的卡片。
		Duel.Destroy(dg,REASON_EFFECT)
	end
end
-- 过滤原本在墓地中，或原本在场上且表侧表示的融合素材卡（用于后续的闪烁提示）。
function c71143015.cfilter(c)
	return c:IsLocation(LOCATION_GRAVE) or (c:IsLocation(LOCATION_MZONE) and c:IsFaceup())
end
