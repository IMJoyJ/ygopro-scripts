--森羅の隠蜜 スナッフ
-- 效果：
-- 手卡·场上的这张卡被送去墓地的场合，可以把自己卡组最上面的卡翻开。翻开的卡是植物族怪兽的场合，那只怪兽送去墓地。不是的场合，那张卡回到卡组最下面。此外，卡组的这张卡被卡的效果翻开送去墓地的场合，可以把自己卡组最上面的卡翻开。翻开的卡是植物族怪兽的场合，那只怪兽送去墓地。不是的场合，那张卡回到卡组最下面。
function c47741109.initial_effect(c)
	-- 手卡·场上的这张卡被送去墓地的场合，可以把自己卡组最上面的卡翻开。翻开的卡是植物族怪兽的场合，那只怪兽送去墓地。不是的场合，那张卡回到卡组最下面。此外，卡组的这张卡被卡的效果翻开送去墓地的场合，可以把自己卡组最上面的卡翻开。翻开的卡是植物族怪兽的场合，那只怪兽送去墓地。不是的场合，那张卡回到卡组最下面。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(47741109,0))  --"翻开卡组"
	e1:SetCategory(CATEGORY_DECKDES)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_TO_GRAVE)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCondition(c47741109.condition)
	e1:SetTarget(c47741109.target)
	e1:SetOperation(c47741109.operation)
	c:RegisterEffect(e1)
end
-- 该效果为这张卡被送去墓地时的诱发选发效果，触发条件判断：这张卡被送去墓地时，其原位置为手卡或场上，或者原位置为卡组且因卡的效果被翻开送去墓地（满足“手卡·场上的这张卡被送去墓地”或“卡组的这张卡被卡的效果翻开送去墓地”任一情形）。
function c47741109.condition(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsPreviousLocation(LOCATION_HAND+LOCATION_ONFIELD) or (c:IsPreviousLocation(LOCATION_DECK) and	c:IsReason(REASON_REVEAL))
end
-- 发动效果时的合法性判定函数：检查玩家是否能把卡组最上方的1张卡送去墓地；若不能，则效果不能发动。
function c47741109.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动前检查（chk==0）时，返回玩家能否把卡组最上方1张卡送去墓地，以确保效果可以处理。
	if chk==0 then return Duel.IsPlayerCanDiscardDeck(tp,1) end
end
-- 效果处理函数：实际执行翻开卡组最上方1张卡，若为植物族怪兽则将其送去墓地，若不是则将其放回卡组最下面。
function c47741109.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 效果处理开始时再次确认玩家仍能把卡组最上方1张卡送去墓地；若玩家此时不能（如卡组已空或受限制），则直接结束处理。
	if not Duel.IsPlayerCanDiscardDeck(tp,1) then return end
	-- 向双方玩家展示卡组最上方的1张卡，即执行“把卡组最上面的卡翻开”的确认动作。
	Duel.ConfirmDecktop(tp,1)
	-- 获取卡组最上方1张卡的卡组对象，用于后续判断其种族并决定送去墓地或放回卡组底部。
	local g=Duel.GetDecktopGroup(tp,1)
	local tc=g:GetFirst()
	if tc:IsRace(RACE_PLANT) then
		-- 禁用本次操作后的自动洗切检查，避免从卡组顶取出卡送至墓地或移回底部时触发无谓的卡组洗切。
		Duel.DisableShuffleCheck()
		-- 将翻开的卡送去墓地，并附带REASON_EFFECT与REASON_REVEAL原因，使其被视为“卡的效果翻开并被送去墓地”，以正确联动相关卡片。
		Duel.SendtoGrave(g,REASON_EFFECT+REASON_REVEAL)
	else
		-- 当翻开的卡不是植物族怪兽时，将其移动到卡组最下面，实现“那张卡回到卡组最下面”的效果。
		Duel.MoveSequence(tc,SEQ_DECKBOTTOM)
	end
end
