--強欲ゴブリン
-- 效果：
-- 只要这张卡在自己场上以表侧表示存在，双方都不能发动「通过丢弃手卡来发动」的效果。
function c425934.initial_effect(c)
	-- 只要这张卡在自己场上以表侧表示存在，双方都不能发动「通过丢弃手卡来发动」的效果。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(1,1)
	e1:SetCode(EFFECT_CANNOT_DISCARD_HAND)
	e1:SetTarget(c425934.target)
	e1:SetValue(1)
	c:RegisterEffect(e1)
end
-- 判断效果是否因丢弃手卡作为发动代价而触发
function c425934.target(e,dc,re,r)
	return r&REASON_COST==REASON_COST
end
