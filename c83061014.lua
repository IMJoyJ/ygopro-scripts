--後に亀と呼ばれる神
-- 效果：
-- 只要这张卡在场上表侧表示存在，双方不能把攻击力1800以下的怪兽特殊召唤。
function c83061014.initial_effect(c)
	-- 只要这张卡在场上表侧表示存在，双方不能把攻击力1800以下的怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,1)
	e1:SetTarget(c83061014.sumlimit)
	c:RegisterEffect(e1)
end
-- 过滤特殊召唤限制的对象，判断被特殊召唤的怪兽攻击力是否在1800以下
function c83061014.sumlimit(e,c,sump,sumtype,sumpos,targetp)
	return c:IsAttackBelow(1800)
end
