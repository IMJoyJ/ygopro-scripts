--マインド・オン・エア
-- 效果：
-- 只要这张卡在场上表侧表示存在，对方必须永续公开手卡。
function c66690411.initial_effect(c)
	-- 只要这张卡在场上表侧表示存在，对方必须永续公开手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_PUBLIC)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(0,LOCATION_HAND)
	c:RegisterEffect(e1)
end
