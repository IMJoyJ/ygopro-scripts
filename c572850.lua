--ティアラメンツ・シェイレーン
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：自己主要阶段才能发动。这张卡从手卡特殊召唤，从自己手卡选1只怪兽送去墓地。那之后，从自己卡组上面把3张卡送去墓地。
-- ②：这张卡被效果送去墓地的场合才能发动。融合怪兽卡决定的包含墓地的这张卡的融合素材怪兽从自己的手卡·场上·墓地用喜欢的顺序回到持有者卡组下面，把那1只融合怪兽从额外卡组融合召唤。
function c572850.initial_effect(c)
	-- ①：自己主要阶段才能发动。这张卡从手卡特殊召唤，从自己手卡选1只怪兽送去墓地。那之后，从自己卡组上面把3张卡送去墓地。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(572850,0))
	e1:SetCategory(CATEGORY_DECKDES+CATEGORY_SPECIAL_SUMMON+CATEGORY_TOGRAVE)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,572850)
	e1:SetTarget(c572850.tgtg)
	e1:SetOperation(c572850.tgop)
	c:RegisterEffect(e1)
	-- ②：这张卡被效果送去墓地的场合才能发动。融合怪兽卡决定的包含墓地的这张卡的融合素材怪兽从自己的手卡·场上·墓地用喜欢的顺序回到持有者卡组下面，把那1只融合怪兽从额外卡组融合召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(572850,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON+CATEGORY_GRAVE_ACTION)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetCountLimit(1,572851)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCondition(c572850.condition)
	e2:SetTarget(c572850.target)
	e2:SetOperation(c572850.activate)
	c:RegisterEffect(e2)
end
-- 过滤条件：手卡中可以送去墓地的怪兽
function c572850.tgfilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsAbleToGrave()
end
-- ①号效果的发动准备与可行性检测
function c572850.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 检查自己场上是否有空余的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		-- 检查玩家是否能将卡组顶端的3张卡送去墓地
		and Duel.IsPlayerCanDiscardDeck(tp,3)
		-- 检查手卡中是否存在除这张卡以外的可以送去墓地的怪兽
		and Duel.IsExistingMatchingCard(c572850.tgfilter,tp,LOCATION_HAND,0,1,c) end
	-- 设置连锁信息：从卡组送去墓地3张卡
	Duel.SetOperationInfo(0,CATEGORY_DECKDES,nil,0,tp,3)
	-- 设置连锁信息：从手卡将1张卡送去墓地
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_HAND)
	-- 设置连锁信息：特殊召唤自身
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
-- ①号效果的处理过程
function c572850.tgop(e,tp,eg,ep,ev,re,r,rp)
	-- 若此卡仍存在于手卡，则将其特殊召唤
	if e:GetHandler():IsRelateToEffect(e) and Duel.SpecialSummon(e:GetHandler(),0,tp,tp,false,false,POS_FACEUP)>0 then
		-- 提示玩家选择要送去墓地的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
		-- 玩家从手卡选择1只怪兽
		local g=Duel.SelectMatchingCard(tp,c572850.tgfilter,tp,LOCATION_HAND,0,1,1,nil)
		-- 若成功将选中的怪兽送去墓地
		if #g>0 and Duel.SendtoGrave(g,REASON_EFFECT)>0 and g:GetFirst():IsLocation(LOCATION_GRAVE)
			-- 且此时玩家仍能将卡组顶端的卡送去墓地
			and Duel.IsPlayerCanDiscardDeck(tp,1) then
			-- 中断当前效果，使后续的送墓处理不与特殊召唤、手卡送墓同时处理
			Duel.BreakEffect()
			-- 将自己卡组顶端的3张卡送去墓地
			Duel.DiscardDeck(tp,3,REASON_EFFECT)
		end
	end
end
-- 过滤条件：可以作为融合素材且能回到卡组的怪兽
function c572850.filter0(c,e)
	return c:IsType(TYPE_MONSTER) and c:IsCanBeFusionMaterial() and c:IsAbleToDeck() and not c:IsImmuneToEffect(e)
end
-- 过滤条件：额外卡组中可以使用指定素材进行融合召唤的融合怪兽
function c572850.filter1(c,e,tp,m,f,chkf)
	if not (c:IsType(TYPE_FUSION) and (not f or f(c))
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_FUSION,tp,false,false)) then return false end
	local res=c:CheckFusionMaterial(m,e:GetHandler(),chkf)
	return res
end
-- ②号效果的发动条件：非伤害步骤且被效果送去墓地
function c572850.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前的阶段
	local ph=Duel.GetCurrentPhase()
	return ph~=PHASE_DAMAGE and ph~=PHASE_DAMAGE_CAL and e:GetHandler():IsReason(REASON_EFFECT)
end
-- ②号效果的发动准备与可行性检测
function c572850.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local chkf=tp
		-- 获取自己手卡、场上、墓地中可作为融合素材的卡片组
		local mg=Duel.GetMatchingGroup(c572850.filter0,tp,LOCATION_HAND+LOCATION_MZONE+LOCATION_GRAVE,0,nil,e)
		-- 检查额外卡组是否存在可以使用上述素材（包含墓地的这张卡）进行融合召唤的怪兽
		local res=Duel.IsExistingMatchingCard(c572850.filter1,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg,nil,chkf)
		if not res then
			-- 获取玩家受到的连锁素材效果
			local ce=Duel.GetChainMaterial(tp)
			if ce~=nil then
				local fgroup=ce:GetTarget()
				local mg2=fgroup(ce,e,tp)
				local mf=ce:GetValue()
				-- 检查在连锁素材效果影响下是否存在可融合召唤的怪兽
				res=Duel.IsExistingMatchingCard(c572850.filter1,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg2,mf,chkf)
			end
		end
		return res
	end
	-- 设置连锁信息：从额外卡组特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- ②号效果的处理过程（融合召唤）
function c572850.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local chkf=tp
	if not c:IsRelateToChain() or c:IsImmuneToEffect(e) then return end
	-- 获取不受王家长眠之谷影响的、自己手卡·场上·墓地的融合素材卡片组
	local mg=Duel.GetMatchingGroup(aux.NecroValleyFilter(c572850.filter0),tp,LOCATION_HAND+LOCATION_MZONE+LOCATION_GRAVE,0,nil,e)
	-- 获取额外卡组中可以使用上述素材进行融合召唤的怪兽组
	local sg1=Duel.GetMatchingGroup(c572850.filter1,tp,LOCATION_EXTRA,0,nil,e,tp,mg,nil,chkf)
	local mg2=nil
	local sg2=nil
	-- 获取玩家受到的连锁素材效果
	local ce=Duel.GetChainMaterial(tp)
	if ce~=nil then
		local fgroup=ce:GetTarget()
		mg2=fgroup(ce,e,tp)
		local mf=ce:GetValue()
		-- 获取在连锁素材效果影响下可以融合召唤的怪兽组
		sg2=Duel.GetMatchingGroup(c572850.filter1,tp,LOCATION_EXTRA,0,nil,e,tp,mg2,mf,chkf)
	end
	if sg1:GetCount()>0 or (sg2~=nil and sg2:GetCount()>0) then
		local sg=sg1:Clone()
		if sg2 then sg:Merge(sg2) end
		-- 提示玩家选择要特殊召唤的融合怪兽
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		local tg=sg:Select(tp,1,1,nil)
		local tc=tg:GetFirst()
		-- 判断是否使用常规的融合素材回到卡组的方式进行融合召唤
		if sg1:IsContains(tc) and (sg2==nil or not sg2:IsContains(tc) or not Duel.SelectYesNo(tp,ce:GetDescription())) then
			-- 玩家选择包含墓地的这张卡在内的融合素材
			local mat1=Duel.SelectFusionMaterial(tp,tc,mg,e:GetHandler(),chkf)
			tc:SetMaterial(mat1)
			if mat1:IsExists(c572850.fdfilter,1,nil) then
				local cg=mat1:Filter(c572850.fdfilter,nil)
				-- 向对方玩家确认选中的手卡或里侧表示的素材卡
				Duel.ConfirmCards(1-tp,cg)
			end
			if mat1:IsExists(c572850.fdfilter2,1,nil) then
				local cg=mat1:Filter(c572850.fdfilter2,nil)
				-- 在场上或墓地中显式选中作为素材的卡片
				Duel.HintSelection(cg)
			end
			-- 将选中的融合素材以喜欢的顺序回到持有者卡组最下方
			aux.PlaceCardsOnDeckBottom(tp,mat1,REASON_EFFECT+REASON_MATERIAL+REASON_FUSION)
			-- 中断当前效果，使后续的特殊召唤不与素材回卡组同时处理
			Duel.BreakEffect()
			-- 将该融合怪兽从额外卡组进行融合召唤
			Duel.SpecialSummon(tc,SUMMON_TYPE_FUSION,tp,tp,false,false,POS_FACEUP)
		else
			-- 在连锁素材效果下选择融合素材
			local mat2=Duel.SelectFusionMaterial(tp,tc,mg2,e:GetHandler(),chkf)
			local fop=ce:GetOperation()
			fop(ce,e,tp,tc,mat2)
		end
		tc:CompleteProcedure()
	end
end
-- 过滤条件：处于场上里侧表示或在手卡中的卡（需要向对方确认）
function c572850.fdfilter(c)
	return c:IsLocation(LOCATION_MZONE) and c:IsFacedown() or c:IsLocation(LOCATION_HAND)
end
-- 过滤条件：处于场上表侧表示或在墓地中的卡（需要显示选中动画）
function c572850.fdfilter2(c)
	return c:IsLocation(LOCATION_MZONE) and c:IsFaceup() or c:IsLocation(LOCATION_GRAVE)
end
