--ジュラック・モノロフ
-- 效果：
-- ①：这张卡可以向对方怪兽全部各作1次攻击。
function c36717258.initial_effect(c)
	-- ①：这张卡可以向对方怪兽全部各作1次攻击。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_ATTACK_ALL)
	e1:SetValue(1)
	c:RegisterEffect(e1)
end
