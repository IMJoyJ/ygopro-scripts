--堕天使ナース－レフィキュル
-- 效果：
-- 只要这张卡在场上表侧表示存在，对方基本分回复的效果变成给与对方基本分伤害的效果。
function c67316075.initial_effect(c)
	-- 只要这张卡在场上表侧表示存在，对方基本分回复的效果变成给与对方基本分伤害的效果。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EFFECT_REVERSE_RECOVER)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(0,1)
	e1:SetValue(1)
	c:RegisterEffect(e1)
end
