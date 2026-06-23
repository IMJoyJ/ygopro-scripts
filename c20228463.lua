--セレモニーベル
-- 效果：
-- 只要这张卡在场上表侧表示存在，双方玩家把手卡全部持续公开。
function c20228463.initial_effect(c)
	-- 只要这张卡在场上表侧表示存在，双方玩家把手卡全部持续公开。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_PUBLIC)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(LOCATION_HAND,LOCATION_HAND)
	c:RegisterEffect(e1)
end
