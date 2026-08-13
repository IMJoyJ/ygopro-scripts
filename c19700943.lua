--ドドドボット
-- 效果：
-- 这张卡通常召唤的场合，必须里侧守备表示盖放。这张卡攻击的场合，这张卡直到伤害步骤结束时不受这张卡以外的卡的效果影响。
function c19700943.initial_effect(c)
	-- 对应效果原文：“这张卡通常召唤的场合，必须里侧守备表示盖放。”
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_LIMIT_SUMMON_PROC)
	e1:SetCondition(c19700943.sumcon)
	c:RegisterEffect(e1)
	-- 对应效果原文：“这张卡攻击的场合，这张卡直到伤害步骤结束时不受这张卡以外的卡的效果影响。”
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCode(EFFECT_IMMUNE_EFFECT)
	e2:SetCondition(c19700943.immcon)
	e2:SetValue(c19700943.efilter)
	c:RegisterEffect(e2)
end
-- 召唤限制条件：若未指定怪兽（仅询问能否通常召唤时）放行，以便进行里侧守备表示盖放；若指定了要通常召唤的这张卡则返回false，禁止其表侧表示通常召唤。
function c19700943.sumcon(e,c,minc)
	if not c then return true end
	return false
end
-- 免疫效果的适用条件：判断当前攻击怪兽是否为本卡；只有在本卡发起攻击时才满足条件，免疫效果才生效。
function c19700943.immcon(e)
	-- 判定当前攻击者是否就是本卡，若是则说明本卡正在攻击，使免疫效果在“这张卡攻击的场合”这一时机生效。
	return Duel.GetAttacker()==e:GetHandler()
end
-- 免疫过滤：若欲适用的效果所属的卡不是本卡，则视为“这张卡以外的卡的效果”，返回true使该效果对本卡无效化。
function c19700943.efilter(e,te)
	return te:GetOwner()~=e:GetOwner()
end
