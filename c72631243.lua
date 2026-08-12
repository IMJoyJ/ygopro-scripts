--エナジー・ブレイブ
-- 效果：
-- 只要这张卡在自己场上表侧表示存在，自己场上存在的再度召唤状态的二重怪兽不会被卡的效果破坏。
function c72631243.initial_effect(c)
	-- 只要这张卡在自己场上表侧表示存在，自己场上存在的再度召唤状态的二重怪兽不会被卡的效果破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetTarget(c72631243.indtg)
	e1:SetValue(1)
	c:RegisterEffect(e1)
end
-- 判断目标怪兽是否处于再度召唤状态，以此确定其是否受到不会被效果破坏的保护
function c72631243.indtg(e,c)
	return c:IsDualState()
end
