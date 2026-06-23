--業火の結界像
-- 效果：
-- ①：只要这张卡在怪兽区域存在，双方不是炎属性怪兽不能特殊召唤。
function c47961808.initial_effect(c)
	-- ①：只要这张卡在怪兽区域存在，双方不是炎属性怪兽不能特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,1)
	e1:SetTarget(c47961808.sumlimit)
	c:RegisterEffect(e1)
end
-- 检索满足条件的卡片组，判断怪兽属性是否为炎属性
function c47961808.sumlimit(e,c,sump,sumtype,sumpos,targetp)
	return c:GetAttribute()~=ATTRIBUTE_FIRE
end
