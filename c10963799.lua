--豪雨の結界像
-- 效果：
-- 只要这张卡在场上表侧表示存在，双方不能把水属性以外的怪兽特殊召唤。
function c10963799.initial_effect(c)
	-- 只要这张卡在场上表侧表示存在，双方不能把水属性以外的怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,1)
	e1:SetTarget(c10963799.sumlimit)
	c:RegisterEffect(e1)
end
-- 检索满足条件的卡片组，将目标怪兽特殊召唤
function c10963799.sumlimit(e,c,sump,sumtype,sumpos,targetp)
	return c:GetAttribute()~=ATTRIBUTE_WATER
end
