--王宮の号令
-- 效果：
-- 全部的反转效果的怪兽的发动和效果无效化。
function c33950246.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- 全部的反转效果的怪兽的发动和效果无效化。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCode(EFFECT_CANNOT_ACTIVATE)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetTargetRange(1,1)
	e2:SetValue(c33950246.aclimit)
	c:RegisterEffect(e2)
	-- 全部的反转效果的怪兽的发动和效果无效化。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetRange(LOCATION_SZONE)
	e2:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e2:SetTarget(c33950246.disable)
	e2:SetCode(EFFECT_DISABLE)
	c:RegisterEffect(e2)
	-- 全部的反转效果的怪兽的发动和效果无效化。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e3:SetCode(EVENT_CHAIN_SOLVING)
	e3:SetRange(LOCATION_MZONE)
	e3:SetOperation(c33950246.disop)
	c:RegisterEffect(e3)
end
-- 判断效果是否为反转怪兽的效果
function c33950246.aclimit(e,re,tp)
	return re:IsActiveType(TYPE_FLIP)
end
-- 判断怪兽是否为反转怪兽
function c33950246.disable(e,c)
	return c:IsType(TYPE_FLIP)
end
-- 连锁处理时判断是否为反转怪兽效果并使其无效
function c33950246.disop(e,tp,eg,ep,ev,re,r,rp)
	if re:IsActiveType(TYPE_FLIP) then
		-- 使对应连锁效果无效
		Duel.NegateEffect(ev)
	end
end
