--ティアラメンツ・ハゥフニス
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：对方把场上的怪兽的效果发动时才能发动。这张卡从手卡特殊召唤，从自己卡组上面把3张卡送去墓地。
-- ②：这张卡被效果送去墓地的场合才能发动。融合怪兽卡决定的包含墓地的这张卡的融合素材怪兽从自己的手卡·场上·墓地用喜欢的顺序回到持有者卡组下面，把那1只融合怪兽从额外卡组融合召唤。
function c37961969.initial_effect(c)
	-- ①：对方把场上的怪兽的效果发动时才能发动。这张卡从手卡特殊召唤，从自己卡组上面把3张卡送去墓地。
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
	-- ②：这张卡被效果送去墓地的场合才能发动。融合怪兽卡决定的包含墓地的这张卡的融合素材怪兽从自己的手卡·场上·墓地用喜欢的顺序回到持有者卡组下面，把那1只融合怪兽从额外卡组融合召唤。
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
-- 效果①的发动条件：仅当对方发动了场上怪兽区域发动的怪兽效果时，本卡才能从手卡发动。
function c37961969.tgcon(e,tp,eg,ep,ev,re,r,rp)
	return rp==1-tp and re:IsActiveType(TYPE_MONSTER) and re:GetActivateLocation()==LOCATION_MZONE
end
-- 效果①发动前检查：自己场上是否有可用的怪兽区、本卡能否被特殊召唤、卡组顶端是否有至少3张卡可送去墓地。
function c37961969.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否存在可用的怪兽区域空位，用于后续特殊召唤本卡。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false)
		-- 检查自己是否可以把卡组顶端的3张卡送去墓地，即卡组是否有足够的卡。
		and Duel.IsPlayerCanDiscardDeck(tp,3) end
	-- 设置本次连锁的操作信息：预期将卡组顶端的3张卡送去墓地（用于触发相关卡片检测）。
	Duel.SetOperationInfo(0,CATEGORY_DECKDES,nil,0,tp,3)
	-- 设置本次连锁的操作信息：预期将本卡特殊召唤。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 效果①处理时：先尝试将本卡从手卡特殊召唤，若特殊召唤成功，则从自己卡组顶端把3张卡送去墓地。
function c37961969.tgop(e,tp,eg,ep,ev,re,r,rp)
	-- 判断本卡是否仍与发动效果关联，并尝试以表侧攻击/守备表示特殊召唤，若实际特殊召唤成功则继续后续堆墓处理。
	if e:GetHandler():IsRelateToEffect(e) and Duel.SpecialSummon(e:GetHandler(),0,tp,tp,false,false,POS_FACEUP)>0 then
		-- 以效果原因从自己卡组顶端将3张卡送去墓地。
		Duel.DiscardDeck(tp,3,REASON_EFFECT)
	end
end
-- 定义②的融合素材候选条件：必须是怪兽卡、可用作融合素材、可以返回卡组、且不受当前效果影响。
function c37961969.filter0(c,e)
	return c:IsType(TYPE_MONSTER) and c:IsCanBeFusionMaterial() and c:IsAbleToDeck() and not c:IsImmuneToEffect(e)
end
-- 定义可选的融合怪兽条件：该卡必须是融合怪兽、满足额外限制（如素材指定）、并能够通过融合召唤特殊召唤，且当前素材组能够满足其融合素材要求。
function c37961969.filter1(c,e,tp,m,f,chkf)
	if not (c:IsType(TYPE_FUSION) and (not f or f(c))
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_FUSION,tp,false,false)) then return false end
	local res=c:CheckFusionMaterial(m,e:GetHandler(),chkf)
	return res
end
-- 效果②的发动条件：当前不在伤害阶段或伤害计算时，并且本卡是因为效果而送去墓地。
function c37961969.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前游戏阶段，用于排除伤害阶段和伤害计算时。
	local ph=Duel.GetCurrentPhase()
	return ph~=PHASE_DAMAGE and ph~=PHASE_DAMAGE_CAL and e:GetHandler():IsReason(REASON_EFFECT)
end
-- 效果②发动前的合法性检查：从手卡·场上·墓地搜集素材，确认额外卡组是否有可融合召唤的怪兽；若存在连锁素材则也检查其替代素材；合法后设置预期特殊召唤1只额外怪兽。
function c37961969.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local chkf=tp
		-- 获取自己手卡·场上·墓地中满足filter0条件的可作为融合素材的怪兽集合。
		local mg=Duel.GetMatchingGroup(c37961969.filter0,tp,LOCATION_HAND+LOCATION_MZONE+LOCATION_GRAVE,0,nil,e)
		-- 检查额外卡组是否存在至少1只满足filter1条件的融合怪兽（使用当前素材mg可以进行融合召唤）。
		local res=Duel.IsExistingMatchingCard(c37961969.filter1,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg,nil,chkf)
		if not res then
			-- 获取当前玩家适用的连锁素材效果（如《连锁素材》等），用于提供额外的融合素材来源。
			local ce=Duel.GetChainMaterial(tp)
			if ce~=nil then
				local fgroup=ce:GetTarget()
				local mg2=fgroup(ce,e,tp)
				local mf=ce:GetValue()
				-- 使用连锁素材提供的素材组mg2和限制f，再次检查额外卡组是否存在可融合召唤的怪兽。
				res=Duel.IsExistingMatchingCard(c37961969.filter1,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg2,mf,chkf)
			end
		end
		return res
	end
	-- 设置操作信息：本次效果预期从额外卡组特殊召唤1只怪兽（用于连锁检测）。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- 效果②实际处理：选择要融合召唤的怪兽和素材，将素材按玩家喜好顺序放回持有者卡组底，然后进行融合召唤；若选择了连锁素材则按连锁素材的方式处理。
function c37961969.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local chkf=tp
	if not c:IsRelateToChain() or c:IsImmuneToEffect(e) then return end
	-- 获取可用于融合的素材组，并使用NecroValleyFilter排除受《王家长眠之谷》影响的卡。
	local mg=Duel.GetMatchingGroup(aux.NecroValleyFilter(c37961969.filter0),tp,LOCATION_HAND+LOCATION_MZONE+LOCATION_GRAVE,0,nil,e)
	-- 获取使用普通素材mg时可融合召唤的额外怪兽集合。
	local sg1=Duel.GetMatchingGroup(c37961969.filter1,tp,LOCATION_EXTRA,0,nil,e,tp,mg,nil,chkf)
	local mg2=nil
	local sg2=nil
	-- 获取当前玩家的连锁素材效果（用于替代/追加素材）。
	local ce=Duel.GetChainMaterial(tp)
	if ce~=nil then
		local fgroup=ce:GetTarget()
		mg2=fgroup(ce,e,tp)
		local mf=ce:GetValue()
		-- 获取使用连锁素材mg2时可融合召唤的额外怪兽集合。
		sg2=Duel.GetMatchingGroup(c37961969.filter1,tp,LOCATION_EXTRA,0,nil,e,tp,mg2,mf,chkf)
	end
	if sg1:GetCount()>0 or (sg2~=nil and sg2:GetCount()>0) then
		local sg=sg1:Clone()
		if sg2 then sg:Merge(sg2) end
		-- 提示玩家选择要特殊召唤的融合怪兽。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		local tg=sg:Select(tp,1,1,nil)
		local tc=tg:GetFirst()
		-- 判断所选融合怪兽是否属于普通可召唤列表，且不需要使用连锁素材，或玩家选择不使用连锁素材；否则使用连锁素材路径。
		if sg1:IsContains(tc) and (sg2==nil or not sg2:IsContains(tc) or not Duel.SelectYesNo(tp,ce:GetDescription())) then
			-- 让玩家从普通素材组mg中选择融合怪兽tc所需的融合素材。
			local mat1=Duel.SelectFusionMaterial(tp,tc,mg,e:GetHandler(),chkf)
			tc:SetMaterial(mat1)
			if mat1:IsExists(c37961969.fdfilter,1,nil) then
				local cg=mat1:Filter(c37961969.fdfilter,nil)
				-- 向对方玩家确认素材中的里侧表示怪兽或手牌怪兽，以证明其作为素材的合法性。
				Duel.ConfirmCards(1-tp,cg)
			end
			if mat1:IsExists(c37961969.fdfilter2,1,nil) then
				local cg=mat1:Filter(c37961969.fdfilter2,nil)
				-- 为素材中的表侧表示怪兽和墓地怪兽显示被选为素材的动画，并记录其成为对象。
				Duel.HintSelection(cg)
			end
			-- 将选中的融合素材按玩家所选顺序放置到持有者卡组底端，原因为效果·素材·融合。
			aux.PlaceCardsOnDeckBottom(tp,mat1,REASON_EFFECT+REASON_MATERIAL+REASON_FUSION)
			-- 中断当前效果处理，使后续的融合召唤与素材回卡组视为不同时处理，以正确对应时点。
			Duel.BreakEffect()
			-- 将选择的融合怪兽以融合召唤方式特殊召唤到自己的场上。
			Duel.SpecialSummon(tc,SUMMON_TYPE_FUSION,tp,tp,false,false,POS_FACEUP)
		else
			-- 使用连锁素材提供的素材组mg2选择融合素材。
			local mat2=Duel.SelectFusionMaterial(tp,tc,mg2,e:GetHandler(),chkf)
			local fop=ce:GetOperation()
			fop(ce,e,tp,tc,mat2)
		end
		tc:CompleteProcedure()
	end
end
-- 定义需要向对方确认的素材类型：里侧表示的场上怪兽或手牌怪兽。
function c37961969.fdfilter(c)
	return c:IsLocation(LOCATION_MZONE) and c:IsFacedown() or c:IsLocation(LOCATION_HAND)
end
-- 定义需要向对方展示动画的素材类型：表侧表示的场上怪兽或墓地怪兽。
function c37961969.fdfilter2(c)
	return c:IsLocation(LOCATION_MZONE) and c:IsFaceup() or c:IsLocation(LOCATION_GRAVE)
end
