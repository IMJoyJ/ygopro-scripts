--ドドドボット
-- 效果：
-- 这张卡通常召唤的场合，必须里侧守备表示盖放。这张卡攻击的场合，这张卡直到伤害步骤结束时不受这张卡以外的卡的效果影响。
function c19700943.initial_effect(c)
	-- 这张卡通常召唤的场合，必须里侧守备表示盖放。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_LIMIT_SUMMON_PROC)
	e1:SetCondition(c19700943.sumcon)
	c:RegisterEffect(e1)
	-- 这张卡攻击的场合，这张卡直到伤害步骤结束时不受这张卡以外的卡的效果影响。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCode(EFFECT_IMMUNE_EFFECT)
	e2:SetCondition(c19700943.immcon)
	e2:SetValue(c19700943.efilter)
	c:RegisterEffect(e2)
end
-- 召唤条件始终不满足，即该卡无法通常召唤，只能通过其他方式特殊召唤。
function c19700943.sumcon(e,c,minc)
	if not c then return true end
	return false
end
-- 攻击时触发的效果条件，判断当前攻击的怪兽是否为该卡。
function c19700943.immcon(e)
	-- 判断当前攻击的怪兽是否为该卡。
	return Duel.GetAttacker()==e:GetHandler()
end
-- 效果过滤器，用于判断效果的发动者是否为该卡的持有者。
function c19700943.efilter(e,te)
	return te:GetOwner()~=e:GetOwner()
end
