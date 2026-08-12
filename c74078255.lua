--ティアラメンツ・メイルゥ
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡召唤·特殊召唤成功的场合才能发动。从自己卡组上面把3张卡送去墓地。
-- ②：这张卡被效果送去墓地的场合才能发动。融合怪兽卡决定的包含墓地的这张卡的融合素材怪兽从自己的手卡·场上·墓地用喜欢的顺序回到持有者卡组下面，把那1只融合怪兽从额外卡组融合召唤。
function c74078255.initial_effect(c)
	-- ①：这张卡召唤·特殊召唤成功的场合才能发动。从自己卡组上面把3张卡送去墓地。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(74078255,0))
	e1:SetCategory(CATEGORY_DECKDES)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetCountLimit(1,74078255)
	e1:SetTarget(c74078255.ddtg)
	e1:SetOperation(c74078255.ddop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
	-- ②：这张卡被效果送去墓地的场合才能发动。融合怪兽卡决定的包含墓地的这张卡的融合素材怪兽从自己的手卡·场上·墓地用喜欢的顺序回到持有者卡组下面，把那1只融合怪兽从额外卡组融合召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(74078255,1))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON+CATEGORY_GRAVE_ACTION)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_TO_GRAVE)
	e3:SetCountLimit(1,74078256)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCondition(c74078255.condition)
	e3:SetTarget(c74078255.target)
	e3:SetOperation(c74078255.activate)
	c:RegisterEffect(e3)
end
-- ①效果的发动准备，检查是否能将卡组顶端的卡送去墓地并设置操作信息
function c74078255.ddtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动准备阶段，检查玩家是否能将卡组顶端的3张卡送去墓地
	if chk==0 then return Duel.IsPlayerCanDiscardDeck(tp,3) end
	-- 设置当前连锁的操作信息为将玩家卡组顶端的3张卡送去墓地
	Duel.SetOperationInfo(0,CATEGORY_DECKDES,nil,0,tp,3)
end
-- ①效果的效果处理，将自己卡组顶端的3张卡送去墓地
function c74078255.ddop(e,tp,eg,ep,ev,re,r,rp)
	-- 因效果将玩家卡组顶端的3张卡送去墓地
	Duel.DiscardDeck(tp,3,REASON_EFFECT)
end
-- 过滤满足融合素材条件的卡片（手卡、场上、墓地的怪兽，且可以回到卡组）
function c74078255.filter0(c,e)
	return c:IsType(TYPE_MONSTER) and c:IsCanBeFusionMaterial() and c:IsAbleToDeck() and not c:IsImmuneToEffect(e)
end
-- 过滤额外卡组中可以进行融合召唤的融合怪兽
function c74078255.filter1(c,e,tp,m,f,chkf)
	if not (c:IsType(TYPE_FUSION) and (not f or f(c))
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_FUSION,tp,false,false)) then return false end
	local res=c:CheckFusionMaterial(m,e:GetHandler(),chkf)
	return res
end
-- ②效果的发动条件：不在伤害步骤，且这张卡因效果被送去墓地
function c74078255.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前的阶段
	local ph=Duel.GetCurrentPhase()
	return ph~=PHASE_DAMAGE and ph~=PHASE_DAMAGE_CAL and e:GetHandler():IsReason(REASON_EFFECT)
end
-- ②效果的发动准备，检查是否存在可融合召唤的怪兽并设置特殊召唤的操作信息
function c74078255.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local chkf=tp
		-- 获取玩家手卡、场上、墓地中满足融合素材条件的卡片组
		local mg=Duel.GetMatchingGroup(c74078255.filter0,tp,LOCATION_HAND+LOCATION_MZONE+LOCATION_GRAVE,0,nil,e)
		-- 检查额外卡组中是否存在可以使用上述素材进行融合召唤的怪兽
		local res=Duel.IsExistingMatchingCard(c74078255.filter1,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg,nil,chkf)
		if not res then
			-- 获取玩家受到的连锁素材效果（如「连锁物质」）
			local ce=Duel.GetChainMaterial(tp)
			if ce~=nil then
				local fgroup=ce:GetTarget()
				local mg2=fgroup(ce,e,tp)
				local mf=ce:GetValue()
				-- 检查在连锁素材效果影响下，额外卡组中是否存在可融合召唤的怪兽
				res=Duel.IsExistingMatchingCard(c74078255.filter1,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg2,mf,chkf)
			end
		end
		return res
	end
	-- 设置当前连锁的操作信息为从额外卡组特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- ②效果的效果处理，选择融合怪兽，将素材回到卡组下面，并进行融合召唤
function c74078255.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local chkf=tp
	if not c:IsRelateToChain() or c:IsImmuneToEffect(e) then return end
	-- 获取不受「王家之谷」影响的、满足融合素材条件的卡片组
	local mg=Duel.GetMatchingGroup(aux.NecroValleyFilter(c74078255.filter0),tp,LOCATION_HAND+LOCATION_MZONE+LOCATION_GRAVE,0,nil,e)
	-- 获取额外卡组中可以使用上述素材进行融合召唤的怪兽组
	local sg1=Duel.GetMatchingGroup(c74078255.filter1,tp,LOCATION_EXTRA,0,nil,e,tp,mg,nil,chkf)
	local mg2=nil
	local sg2=nil
	-- 获取玩家受到的连锁素材效果
	local ce=Duel.GetChainMaterial(tp)
	if ce~=nil then
		local fgroup=ce:GetTarget()
		mg2=fgroup(ce,e,tp)
		local mf=ce:GetValue()
		-- 获取在连锁素材效果影响下，额外卡组中可以融合召唤的怪兽组
		sg2=Duel.GetMatchingGroup(c74078255.filter1,tp,LOCATION_EXTRA,0,nil,e,tp,mg2,mf,chkf)
	end
	if sg1:GetCount()>0 or (sg2~=nil and sg2:GetCount()>0) then
		local sg=sg1:Clone()
		if sg2 then sg:Merge(sg2) end
		-- 提示玩家选择要特殊召唤的卡片
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		local tg=sg:Select(tp,1,1,nil)
		local tc=tg:GetFirst()
		-- 判断是否使用常规融合方式（而非连锁素材效果）进行融合召唤
		if sg1:IsContains(tc) and (sg2==nil or not sg2:IsContains(tc) or not Duel.SelectYesNo(tp,ce:GetDescription())) then
			-- 让玩家选择包含这张卡在内的、用于融合召唤目标怪兽的融合素材
			local mat1=Duel.SelectFusionMaterial(tp,tc,mg,e:GetHandler(),chkf)
			tc:SetMaterial(mat1)
			if mat1:IsExists(c74078255.fdfilter,1,nil) then
				local cg=mat1:Filter(c74078255.fdfilter,nil)
				-- 向对方玩家确认选作素材的里侧表示怪兽或手卡
				Duel.ConfirmCards(1-tp,cg)
			end
			if mat1:IsExists(c74078255.fdfilter2,1,nil) then
				local cg=mat1:Filter(c74078255.fdfilter2,nil)
				-- 为选作素材的场上表侧表示怪兽或墓地怪兽显示被选择的动画效果
				Duel.HintSelection(cg)
			end
			-- 将选作素材的卡片以喜欢的顺序回到持有者卡组下面
			aux.PlaceCardsOnDeckBottom(tp,mat1,REASON_EFFECT+REASON_MATERIAL+REASON_FUSION)
			-- 中断当前效果处理，使后续的特殊召唤不与回到卡组同时处理
			Duel.BreakEffect()
			-- 将选定的融合怪兽从额外卡组表侧表示融合召唤
			Duel.SpecialSummon(tc,SUMMON_TYPE_FUSION,tp,tp,false,false,POS_FACEUP)
		else
			-- 在连锁素材效果下，让玩家选择用于融合召唤的融合素材
			local mat2=Duel.SelectFusionMaterial(tp,tc,mg2,e:GetHandler(),chkf)
			local fop=ce:GetOperation()
			fop(ce,e,tp,tc,mat2)
		end
		tc:CompleteProcedure()
	end
end
-- 过滤出场上里侧表示的怪兽或手卡（这些卡在回到卡组前需要向对方确认）
function c74078255.fdfilter(c)
	return c:IsLocation(LOCATION_MZONE) and c:IsFacedown() or c:IsLocation(LOCATION_HAND)
end
-- 过滤出场上表侧表示的怪兽或墓地的卡（这些卡在回到卡组前需要显示选择动画）
function c74078255.fdfilter2(c)
	return c:IsLocation(LOCATION_MZONE) and c:IsFaceup() or c:IsLocation(LOCATION_GRAVE)
end
