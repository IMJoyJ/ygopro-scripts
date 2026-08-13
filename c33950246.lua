--王宮の号令
-- 效果：
-- 全部的反转效果的怪兽的发动和效果无效化。
function c33950246.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- 反转效果的怪兽的发动无效化。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCode(EFFECT_CANNOT_ACTIVATE)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetTargetRange(1,1)
	e2:SetValue(c33950246.aclimit)
	c:RegisterEffect(e2)
	-- 反转效果的怪兽的效果无效化。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetRange(LOCATION_SZONE)
	e2:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e2:SetTarget(c33950246.disable)
	e2:SetCode(EFFECT_DISABLE)
	c:RegisterEffect(e2)
	-- 反转效果的怪兽的发动无效化。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e3:SetCode(EVENT_CHAIN_SOLVING)
	e3:SetRange(LOCATION_MZONE)
	e3:SetOperation(c33950246.disop)
	c:RegisterEffect(e3)
end
-- 作为EFFECT_CANNOT_ACTIVATE的判定条件：若尝试发动的效果属于反转效果（TYPE_FLIP），则禁止该发动。
function c33950246.aclimit(e,re,tp)
	return re:IsActiveType(TYPE_FLIP)
end
-- 作为EFFECT_DISABLE的过滤条件：场上的怪兽若为反转怪兽（TYPE_FLIP），则将其效果无效化。
function c33950246.disable(e,c)
	return c:IsType(TYPE_FLIP)
end
-- 连锁处理时，若当前连锁中的效果为反转效果，则将其无效化，从而无效反转效果的发动。
function c33950246.disop(e,tp,eg,ep,ev,re,r,rp)
	if re:IsActiveType(TYPE_FLIP) then
		-- 使编号为ev的连锁效果无效化，即直接无效反转效果的发动。
		Duel.NegateEffect(ev)
	end
end
