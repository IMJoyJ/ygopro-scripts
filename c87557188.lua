--厳格な老魔術師
-- 效果：
-- ①：这张卡反转的场合发动。场上盖放的卡全部确认。
function c87557188.initial_effect(c)
	-- 处理卡片效果的发动条件、目标选择及效果操作
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_FLIP)
	e1:SetTarget(c87557188.target)
	e1:SetOperation(c87557188.activate)
	c:RegisterEffect(e1)
end
-- 执行对应的效果条件检查或辅助函数处理
function c87557188.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 执行对应的效果条件检查或辅助函数处理
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsFacedown,tp,0,LOCATION_ONFIELD,1,nil) end
end
-- 执行对应的效果条件检查或辅助函数处理
function c87557188.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 执行对应的效果条件检查或辅助函数处理
	local g=Duel.GetMatchingGroup(Card.IsFacedown,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
	if g:GetCount()>0 then
		-- 执行对应的效果条件检查或辅助函数处理
		Duel.ConfirmCards(tp,g)
	end
end
