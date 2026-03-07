--ゾンビキャリア
-- 效果：
-- ①：这张卡在墓地存在的场合，让1张手卡回到卡组最上面才能发动。这张卡特殊召唤。这个效果特殊召唤的这张卡从场上离开的场合除外。
function c33420078.initial_effect(c)
	-- 效果原文：①：这张卡在墓地存在的场合，让1张手卡回到卡组最上面才能发动。这张卡特殊召唤。这个效果特殊召唤的这张卡从场上离开的场合除外。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(33420078,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_GRAVE)
	e1:SetCost(c33420078.cost)
	e1:SetTarget(c33420078.target)
	e1:SetOperation(c33420078.operation)
	c:RegisterEffect(e1)
end
-- 效果作用：检查手牌是否存在可作为代价送回卡组的卡，并选择其中一张送回卡组顶端。
function c33420078.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 效果作用：判断是否满足发动条件，即手牌中存在至少一张可送回卡组的卡。
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsAbleToDeckAsCost,tp,LOCATION_HAND,0,1,nil) end
	-- 效果作用：向玩家提示选择要送回卡组的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 效果作用：选择满足条件的手牌送回卡组顶端。
	local g=Duel.SelectMatchingCard(tp,Card.IsAbleToDeckAsCost,tp,LOCATION_HAND,0,1,1,nil)
	-- 效果作用：将选中的卡送回卡组顶端作为发动代价。
	Duel.SendtoDeck(g,nil,SEQ_DECKTOP,REASON_COST)
end
-- 效果作用：判断是否满足特殊召唤条件，即场上存在空位且该卡可被特殊召唤。
function c33420078.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 效果作用：判断场上是否有足够的怪兽区域。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 效果作用：设置连锁操作信息，表示将要特殊召唤此卡。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 效果作用：执行特殊召唤操作，并设置特殊召唤后该卡离场时的去向为除外区。
function c33420078.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 效果作用：判断此卡是否仍存在于场上且成功特殊召唤，若成功则设置其离场时的去向。
	if c:IsRelateToEffect(e) and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)>0 then
		-- 效果原文：这个效果特殊召唤的这张卡从场上离开的场合除外。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_REDIRECT)
		e1:SetValue(LOCATION_REMOVED)
		c:RegisterEffect(e1,true)
	end
end
