--厳格な老魔術師
-- 效果：
-- ①：这张卡反转的场合发动。场上盖放的卡全部确认。
function c87557188.initial_effect(c)
	-- ①：这张卡反转的场合发动。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_FLIP)
	e1:SetTarget(c87557188.target)
	e1:SetOperation(c87557188.activate)
	c:RegisterEffect(e1)
end
-- 检查场上是否存在盖放的卡
function c87557188.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 若场上存在盖放的卡则满足效果发动条件
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsFacedown,tp,0,LOCATION_ONFIELD,1,nil) end
end
-- 确认场上所有盖放的卡
function c87557188.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 检索场上所有盖放的卡组成组
	local g=Duel.GetMatchingGroup(Card.IsFacedown,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
	if g:GetCount()>0 then
		-- 向玩家确认这些盖放的卡
		Duel.ConfirmCards(tp,g)
	end
end
