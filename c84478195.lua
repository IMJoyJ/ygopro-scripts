--深淵の結界像
-- 效果：
-- ①：只要这张卡在怪兽区域存在，双方不是暗属性怪兽不能特殊召唤。
function c84478195.initial_effect(c)
	-- ①：只要这张卡在怪兽区域存在，双方不是暗属性怪兽不能特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,1)
	e1:SetTarget(c84478195.sumlimit)
	c:RegisterEffect(e1)
end
-- 判断特殊召唤的怪兽属性是否不为暗属性，若不为暗属性则不能特殊召唤
function c84478195.sumlimit(e,c,sump,sumtype,sumpos,targetp)
	return c:GetAttribute()~=ATTRIBUTE_DARK
end
