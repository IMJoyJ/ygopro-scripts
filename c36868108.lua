--ガラスの鎧
-- 效果：
-- 装备卡给怪兽装备时才能发动。直到回合结束时场上的全部装备卡的效果无效。
function c36868108.initial_effect(c)
	-- 装备卡给怪兽装备时才能发动。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_EQUIP)
	e1:SetOperation(c36868108.activate)
	c:RegisterEffect(e1)
end
-- 将效果注册到场上，使直到回合结束时场上的全部装备卡的效果无效。
function c36868108.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 直到回合结束时场上的全部装备卡的效果无效。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_DISABLE)
	e1:SetTargetRange(LOCATION_SZONE,LOCATION_SZONE)
	e1:SetTarget(c36868108.distarget)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将效果e1作为玩家tp的效果注册给全局环境
	Duel.RegisterEffect(e1,tp)
end
-- 目标为场上的装备卡
function c36868108.distarget(e,c)
	return c:IsType(TYPE_EQUIP)
end
