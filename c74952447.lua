--かつて神と呼ばれた亀
-- 效果：
-- 只要这张卡在场上表侧表示存在，双方不能把攻击力1800以上的怪兽特殊召唤。
function c74952447.initial_effect(c)
	-- 只要这张卡在场上表侧表示存在，双方不能把攻击力1800以上的怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,1)
	e1:SetTarget(c74952447.sumlimit)
	c:RegisterEffect(e1)
end
-- 判定准备特殊召唤的怪兽攻击力是否在1800以上
function c74952447.sumlimit(e,c,sump,sumtype,sumpos,targetp)
	return c:IsAttackAbove(1800)
end
