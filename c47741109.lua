--森羅の隠蜜 スナッフ
-- 效果：
-- 手卡·场上的这张卡被送去墓地的场合，可以把自己卡组最上面的卡翻开。翻开的卡是植物族怪兽的场合，那只怪兽送去墓地。不是的场合，那张卡回到卡组最下面。此外，卡组的这张卡被卡的效果翻开送去墓地的场合，可以把自己卡组最上面的卡翻开。翻开的卡是植物族怪兽的场合，那只怪兽送去墓地。不是的场合，那张卡回到卡组最下面。
function c47741109.initial_effect(c)
	-- 效果原文内容：手卡·场上的这张卡被送去墓地的场合，可以把自己卡组最上面的卡翻开。此外，卡组的这张卡被卡的效果翻开送去墓地的场合，可以把自己卡组最上面的卡翻开。
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
-- 效果作用：判断此卡是否从手牌或场上被送去墓地，或者从卡组因翻开效果被送去墓地
function c47741109.condition(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsPreviousLocation(LOCATION_HAND+LOCATION_ONFIELD) or (c:IsPreviousLocation(LOCATION_DECK) and	c:IsReason(REASON_REVEAL))
end
-- 效果作用：检查玩家是否可以将卡组最上方的1张卡送去墓地
function c47741109.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 效果作用：检查玩家是否可以将卡组最上方的1张卡送去墓地
	if chk==0 then return Duel.IsPlayerCanDiscardDeck(tp,1) end
end
-- 效果作用：执行翻开卡组最上方1张卡并根据其种族决定处理方式（送去墓地或放回卡组底端）
function c47741109.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 效果作用：检查玩家是否可以将卡组最上方的1张卡送去墓地
	if not Duel.IsPlayerCanDiscardDeck(tp,1) then return end
	-- 效果作用：确认玩家卡组最上方的1张卡
	Duel.ConfirmDecktop(tp,1)
	-- 效果作用：获取玩家卡组最上方的1张卡组成的Group
	local g=Duel.GetDecktopGroup(tp,1)
	local tc=g:GetFirst()
	if tc:IsRace(RACE_PLANT) then
		-- 效果作用：禁用接下来的操作是否需要洗切卡组或手卡的检查
		Duel.DisableShuffleCheck()
		-- 效果作用：将翻开的卡送去墓地
		Duel.SendtoGrave(g,REASON_EFFECT+REASON_REVEAL)
	else
		-- 效果作用：将翻开的卡放回卡组底端
		Duel.MoveSequence(tc,SEQ_DECKBOTTOM)
	end
end
