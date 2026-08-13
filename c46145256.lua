--閃光の結界像
-- 效果：
-- ①：只要这张卡在怪兽区域存在，双方不是光属性怪兽不能特殊召唤。
function c46145256.initial_effect(c)
	-- ①：只要这张卡在怪兽区域存在，双方不是光属性怪兽不能特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,1)
	e1:SetTarget(c46145256.sumlimit)
	c:RegisterEffect(e1)
end
-- 作为效果的目标判定函数：当任意怪兽将要被特殊召唤时，检查其属性，若该怪兽的属性不是光属性（GetAttribute() != ATTRIBUTE_LIGHT），则返回 true，使本次特殊召唤被禁止。
function c46145256.sumlimit(e,c,sump,sumtype,sumpos,targetp)
	return c:GetAttribute()~=ATTRIBUTE_LIGHT
end
