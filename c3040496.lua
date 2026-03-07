--混沌魔龍 カオス・ルーラー
-- 效果：
-- 调整＋调整以外的怪兽1只以上
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡同调召唤成功的场合才能发动。从自己卡组上面把5张卡翻开。可以从那之中选1只光·暗属性怪兽加入手卡。剩下的卡送去墓地。
-- ②：把这张卡以外的光·暗属性怪兽各1只从自己的手卡·墓地除外才能发动。这张卡从墓地特殊召唤。这个效果特殊召唤的这张卡从场上离开的场合除外。
function c3040496.initial_effect(c)
	-- 为卡片添加同调召唤手续，要求必须是1只调整，以及1只调整以外的怪兽。
	aux.AddSynchroProcedure(c,nil,aux.NonTuner(nil),1)
	c:EnableReviveLimit()
	-- ①：这张卡同调召唤成功的场合才能发动。从自己卡组上面把5张卡翻开。可以从那之中选1只光·暗属性怪兽加入手卡。剩下的卡送去墓地。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(3040496,0))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_DECKDES)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCountLimit(1,3040496)
	e1:SetCondition(c3040496.thcon)
	e1:SetTarget(c3040496.thtg)
	e1:SetOperation(c3040496.thop)
	c:RegisterEffect(e1)
	-- ②：把这张卡以外的光·暗属性怪兽各1只从自己的手卡·墓地除外才能发动。这张卡从墓地特殊召唤。这个效果特殊召唤的这张卡从场上离开的场合除外。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,3040497)
	e2:SetCost(c3040496.spcost)
	e2:SetTarget(c3040496.sptg)
	e2:SetOperation(c3040496.spop)
	c:RegisterEffect(e2)
end
-- 效果发动的条件：此卡必须是同调召唤成功。
function c3040496.thcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_SYNCHRO)
end
-- 过滤满足条件的光·暗属性怪兽，用于加入手卡。
function c3040496.thfilter(c)
	return c:IsAttribute(ATTRIBUTE_LIGHT+ATTRIBUTE_DARK) and c:IsAbleToHand()
end
-- 效果发动的条件检查：玩家是否可以将卡组最上方5张卡送去墓地。
function c3040496.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家是否可以将卡组最上方5张卡送去墓地。
	if chk==0 then return Duel.IsPlayerCanDiscardDeck(tp,5) end
end
-- 处理效果：翻开卡组最上方5张卡，选择是否将其中一张光·暗属性怪兽加入手牌，其余卡送去墓地。
function c3040496.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查玩家是否可以将卡组最上方5张卡送去墓地。
	if Duel.IsPlayerCanDiscardDeck(tp,5) then
		-- 确认玩家卡组最上方5张卡。
		Duel.ConfirmDecktop(tp,5)
		-- 获取玩家卡组最上方5张卡组成的卡片组。
		local g=Duel.GetDecktopGroup(tp,5)
		if g:GetCount()>0 then
			-- 禁用洗牌检测，防止后续操作自动洗牌。
			Duel.DisableShuffleCheck()
			-- 检查翻开的卡中是否存在光·暗属性怪兽，并询问玩家是否选择加入手牌。
			if g:IsExists(c3040496.thfilter,1,nil) and Duel.SelectYesNo(tp,aux.Stringid(3040496,1)) then  --"是否选卡加入手卡？"
				-- 提示玩家选择要加入手牌的卡。
				Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
				local sg=g:FilterSelect(tp,c3040496.thfilter,1,1,nil)
				-- 将选中的卡加入手牌。
				Duel.SendtoHand(sg,nil,REASON_EFFECT)
				-- 向对方确认加入手牌的卡。
				Duel.ConfirmCards(1-tp,sg)
				-- 洗切玩家的手牌。
				Duel.ShuffleHand(tp)
				g:Sub(sg)
			end
			-- 将剩余的卡送去墓地。
			Duel.SendtoGrave(g,REASON_EFFECT+REASON_REVEAL)
		end
	end
end
-- 过滤满足条件的光·暗属性怪兽，用于除外作为特殊召唤的代价。
function c3040496.costfilter(c)
	return c:IsAbleToRemoveAsCost() and c:IsAttribute(ATTRIBUTE_LIGHT+ATTRIBUTE_DARK)
end
-- 处理效果：从手卡或墓地除外2只光·暗属性怪兽作为特殊召唤的代价。
function c3040496.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取玩家手卡和墓地中的光·暗属性怪兽组成的卡片组。
	local g=Duel.GetMatchingGroup(c3040496.costfilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,e:GetHandler())
	-- 检查是否满足除外2只光·暗属性怪兽的条件。
	if chk==0 then return g:CheckSubGroup(aux.gfcheck,2,2,Card.IsAttribute,ATTRIBUTE_LIGHT,ATTRIBUTE_DARK) end
	-- 提示玩家选择要除外的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 从符合条件的卡中选择2只光·暗属性怪兽除外。
	local sg=g:SelectSubGroup(tp,aux.gfcheck,false,2,2,Card.IsAttribute,ATTRIBUTE_LIGHT,ATTRIBUTE_DARK)
	-- 将选中的卡除外。
	Duel.Remove(sg,POS_FACEUP,REASON_COST)
end
-- 处理效果：检查是否可以特殊召唤此卡。
function c3040496.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 检查玩家是否可以特殊召唤此卡。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置特殊召唤的操作信息。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
-- 处理效果：将此卡从墓地特殊召唤。
function c3040496.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 检查此卡是否与效果相关且可以特殊召唤。
	if c:IsRelateToEffect(e) and Duel.SpecialSummonStep(c,0,tp,tp,false,false,POS_FACEUP) then
		-- 设置特殊召唤后，此卡离开场上的处理：除外。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_REDIRECT)
		e1:SetValue(LOCATION_REMOVED)
		c:RegisterEffect(e1,true)
	end
	-- 完成特殊召唤流程。
	Duel.SpecialSummonComplete()
end
