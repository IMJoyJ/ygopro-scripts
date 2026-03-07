--ティアラメンツ・ハゥフニス
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：对方把场上的怪兽的效果发动时才能发动。这张卡从手卡特殊召唤，从自己卡组上面把3张卡送去墓地。
-- ②：这张卡被效果送去墓地的场合才能发动。融合怪兽卡决定的包含墓地的这张卡的融合素材怪兽从自己的手卡·场上·墓地用喜欢的顺序回到持有者卡组下面，把那1只融合怪兽从额外卡组融合召唤。
function c37961969.initial_effect(c)
	-- 效果原文：这个卡名的①②的效果1回合各能使用1次。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(37961969,0))
	e1:SetCategory(CATEGORY_DECKDES+CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_CHAINING)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,37961969)
	e1:SetCondition(c37961969.tgcon)
	e1:SetTarget(c37961969.tgtg)
	e1:SetOperation(c37961969.tgop)
	c:RegisterEffect(e1)
	-- 效果原文：②：这张卡被效果送去墓地的场合才能发动。融合怪兽卡决定的包含墓地的这张卡的融合素材怪兽从自己的手卡·场上·墓地用喜欢的顺序回到持有者卡组下面，把那1只融合怪兽从额外卡组融合召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(37961969,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON+CATEGORY_GRAVE_ACTION)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetCountLimit(1,37961970)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCondition(c37961969.condition)
	e2:SetTarget(c37961969.target)
	e2:SetOperation(c37961969.activate)
	c:RegisterEffect(e2)
end
-- 效果作用：对方把场上的怪兽的效果发动时才能发动
function c37961969.tgcon(e,tp,eg,ep,ev,re,r,rp)
	return rp==1-tp and re:IsActiveType(TYPE_MONSTER) and re:GetActivateLocation()==LOCATION_MZONE
end
-- 效果作用：检查是否满足特殊召唤和丢弃3张卡的条件
function c37961969.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 效果作用：检查场上是否有足够的召唤位置
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false)
		-- 效果作用：检查是否可以丢弃3张卡
		and Duel.IsPlayerCanDiscardDeck(tp,3) end
	-- 效果作用：设置操作信息，表示将从卡组丢弃3张卡
	Duel.SetOperationInfo(0,CATEGORY_DECKDES,nil,0,tp,3)
	-- 效果作用：设置操作信息，表示将特殊召唤此卡
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 效果作用：执行特殊召唤并丢弃卡组顶部3张卡
function c37961969.tgop(e,tp,eg,ep,ev,re,r,rp)
	-- 效果作用：检查此卡是否与效果相关且成功特殊召唤
	if e:GetHandler():IsRelateToEffect(e) and Duel.SpecialSummon(e:GetHandler(),0,tp,tp,false,false,POS_FACEUP)>0 then
		-- 效果作用：从自己卡组上面把3张卡送去墓地
		Duel.DiscardDeck(tp,3,REASON_EFFECT)
	end
end
-- 效果作用：过滤满足融合素材条件的怪兽
function c37961969.filter0(c,e)
	return c:IsType(TYPE_MONSTER) and c:IsCanBeFusionMaterial() and c:IsAbleToDeck() and not c:IsImmuneToEffect(e)
end
-- 效果作用：检查融合怪兽是否可以特殊召唤
function c37961969.filter1(c,e,tp,m,f,chkf)
	if not (c:IsType(TYPE_FUSION) and (not f or f(c))
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_FUSION,tp,false,false)) then return false end
	local res=c:CheckFusionMaterial(m,e:GetHandler(),chkf)
	return res
end
-- 效果作用：检查当前阶段是否不是伤害阶段且此卡是因效果送入墓地
function c37961969.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 效果作用：获取当前阶段
	local ph=Duel.GetCurrentPhase()
	return ph~=PHASE_DAMAGE and ph~=PHASE_DAMAGE_CAL and e:GetHandler():IsReason(REASON_EFFECT)
end
-- 效果作用：设置操作信息，表示将特殊召唤融合怪兽
function c37961969.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local chkf=tp
		-- 效果作用：获取手牌、场上、墓地中的融合素材
		local mg=Duel.GetMatchingGroup(c37961969.filter0,tp,LOCATION_HAND+LOCATION_MZONE+LOCATION_GRAVE,0,nil,e)
		-- 效果作用：检查是否存在满足条件的融合怪兽
		local res=Duel.IsExistingMatchingCard(c37961969.filter1,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg,nil,chkf)
		if not res then
			-- 效果作用：获取当前连锁的融合素材效果
			local ce=Duel.GetChainMaterial(tp)
			if ce~=nil then
				local fgroup=ce:GetTarget()
				local mg2=fgroup(ce,e,tp)
				local mf=ce:GetValue()
				-- 效果作用：检查是否存在满足条件的融合怪兽（通过连锁素材）
				res=Duel.IsExistingMatchingCard(c37961969.filter1,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg2,mf,chkf)
			end
		end
		return res
	end
	-- 效果作用：设置操作信息，表示将特殊召唤融合怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- 效果作用：执行融合召唤
function c37961969.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local chkf=tp
	if not c:IsRelateToChain() or c:IsImmuneToEffect(e) then return end
	-- 效果作用：获取手牌、场上、墓地中的融合素材（排除王家长眠之谷影响）
	local mg=Duel.GetMatchingGroup(aux.NecroValleyFilter(c37961969.filter0),tp,LOCATION_HAND+LOCATION_MZONE+LOCATION_GRAVE,0,nil,e)
	-- 效果作用：获取满足条件的融合怪兽
	local sg1=Duel.GetMatchingGroup(c37961969.filter1,tp,LOCATION_EXTRA,0,nil,e,tp,mg,nil,chkf)
	local mg2=nil
	local sg2=nil
	-- 效果作用：获取当前连锁的融合素材效果
	local ce=Duel.GetChainMaterial(tp)
	if ce~=nil then
		local fgroup=ce:GetTarget()
		mg2=fgroup(ce,e,tp)
		local mf=ce:GetValue()
		-- 效果作用：获取满足条件的融合怪兽（通过连锁素材）
		sg2=Duel.GetMatchingGroup(c37961969.filter1,tp,LOCATION_EXTRA,0,nil,e,tp,mg2,mf,chkf)
	end
	if sg1:GetCount()>0 or (sg2~=nil and sg2:GetCount()>0) then
		local sg=sg1:Clone()
		if sg2 then sg:Merge(sg2) end
		-- 效果作用：提示选择要特殊召唤的融合怪兽
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		local tg=sg:Select(tp,1,1,nil)
		local tc=tg:GetFirst()
		-- 效果作用：判断是否使用第一组融合怪兽
		if sg1:IsContains(tc) and (sg2==nil or not sg2:IsContains(tc) or not Duel.SelectYesNo(tp,ce:GetDescription())) then
			-- 效果作用：选择融合素材
			local mat1=Duel.SelectFusionMaterial(tp,tc,mg,e:GetHandler(),chkf)
			tc:SetMaterial(mat1)
			if mat1:IsExists(c37961969.fdfilter,1,nil) then
				local cg=mat1:Filter(c37961969.fdfilter,nil)
				-- 效果作用：确认对方看到融合素材
				Duel.ConfirmCards(1-tp,cg)
			end
			if mat1:IsExists(c37961969.fdfilter2,1,nil) then
				local cg=mat1:Filter(c37961969.fdfilter2,nil)
				-- 效果作用：显示融合素材被选中
				Duel.HintSelection(cg)
			end
			-- 效果作用：将融合素材放回卡组底部
			aux.PlaceCardsOnDeckBottom(tp,mat1,REASON_EFFECT+REASON_MATERIAL+REASON_FUSION)
			-- 效果作用：中断当前效果处理
			Duel.BreakEffect()
			-- 效果作用：特殊召唤融合怪兽
			Duel.SpecialSummon(tc,SUMMON_TYPE_FUSION,tp,tp,false,false,POS_FACEUP)
		else
			-- 效果作用：选择融合素材（通过连锁素材）
			local mat2=Duel.SelectFusionMaterial(tp,tc,mg2,e:GetHandler(),chkf)
			local fop=ce:GetOperation()
			fop(ce,e,tp,tc,mat2)
		end
		tc:CompleteProcedure()
	end
end
-- 效果作用：过滤融合素材中位于场上的里侧表示怪兽或手牌
function c37961969.fdfilter(c)
	return c:IsLocation(LOCATION_MZONE) and c:IsFacedown() or c:IsLocation(LOCATION_HAND)
end
-- 效果作用：过滤融合素材中位于场上的表侧表示怪兽或墓地的怪兽
function c37961969.fdfilter2(c)
	return c:IsLocation(LOCATION_MZONE) and c:IsFaceup() or c:IsLocation(LOCATION_GRAVE)
end
