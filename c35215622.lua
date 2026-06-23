--盲信するゴブリン
-- 效果：
-- 只要这张卡在场上表侧表示存在，控制权不会被转移。
function c35215622.initial_effect(c)
	-- 只要这张卡在场上表侧表示存在，控制权不会被转移。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EFFECT_CANNOT_CHANGE_CONTROL)
	c:RegisterEffect(e1)
end
