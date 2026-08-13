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
-- 作为该永续效果的限制条件：判定被特殊召唤的怪兽属性，若其属性不是炎属性，则返回 true，即禁止该特殊召唤。
function c47961808.sumlimit(e,c,sump,sumtype,sumpos,targetp)
	return c:GetAttribute()~=ATTRIBUTE_FIRE
end
