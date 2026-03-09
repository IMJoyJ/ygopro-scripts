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
-- 判断参与特殊召唤的怪兽是否为光属性，若不是则禁止其特殊召唤
function c46145256.sumlimit(e,c,sump,sumtype,sumpos,targetp)
	return c:GetAttribute()~=ATTRIBUTE_LIGHT
end
