--厳格な老魔術師
-- 效果：
-- ①：这张卡反转的场合发动。场上盖放的卡全部确认。
function c87557188.initial_effect(c)
	-- ①：这张卡反转的场合发动。场上盖放的卡全部确认。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_FLIP)
	e1:SetTarget(c87557188.target)
	e1:SetOperation(c87557188.activate)
	c:RegisterEffect(e1)
end
-- 效果的发动准备与合法性检查：检查对方场上是否存在盖放的卡。
function c87557188.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查对方场上是否存在至少1张里侧表示（盖放）的卡。
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsFacedown,tp,0,LOCATION_ONFIELD,1,nil) end
end
-- 效果的处理：获取双方场上所有盖放的卡并让发动玩家确认。
function c87557188.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取双方场上所有处于里侧表示（盖放）的卡片组。
	local g=Duel.GetMatchingGroup(Card.IsFacedown,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
	if g:GetCount()>0 then
		-- 给发动效果的玩家确认双方场上所有的盖放卡片。
		Duel.ConfirmCards(tp,g)
	end
end
