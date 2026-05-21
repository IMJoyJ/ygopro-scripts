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
-- 效果的目标过滤函数，用于判断对方场上是否存在盖放的卡
function c87557188.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在效果发动准备阶段，检查对方场上是否存在至少1张盖放的卡
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsFacedown,tp,0,LOCATION_ONFIELD,1,nil) end
end
-- 效果的运行空间函数，用于执行确认对方场上所有盖放卡的操作
function c87557188.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取对方场上所有盖放的卡片组
	local g=Duel.GetMatchingGroup(Card.IsFacedown,tp,0,LOCATION_ONFIELD,nil)
	if g:GetCount()>0 then
		-- 将获取到的卡片组给发动效果的玩家确认
		Duel.ConfirmCards(tp,g)
	end
end
