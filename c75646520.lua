--金属探知器
-- 效果：
-- 永续陷阱卡发动时才能发动。直到回合结束时场上的全部永续陷阱卡的效果无效。
function c75646520.initial_effect(c)
	-- 永续陷阱卡发动时才能发动。直到回合结束时场上的全部永续陷阱卡的效果无效。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_CHAINING)
	e1:SetCondition(c75646520.condition)
	e1:SetOperation(c75646520.activate)
	c:RegisterEffect(e1)
end
-- 检查连锁中的效果是否为永续陷阱卡的发动
function c75646520.condition(e,tp,eg,ep,ev,re,r,rp)
	return re:IsHasType(EFFECT_TYPE_ACTIVATE) and re:GetActiveType()==TYPE_CONTINUOUS+TYPE_TRAP
end
-- 在场上注册两个全局效果，分别用于无效魔陷区的永续陷阱卡和怪兽区的永续陷阱怪兽，持续到回合结束
function c75646520.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 直到回合结束时场上的全部永续陷阱卡的效果无效。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_DISABLE)
	e1:SetTargetRange(LOCATION_SZONE,LOCATION_SZONE)
	e1:SetTarget(c75646520.distarget)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 向全局环境注册无效魔陷区卡片效果的永续效果
	Duel.RegisterEffect(e1,tp)
	-- 直到回合结束时场上的全部永续陷阱卡的效果无效。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_DISABLE_TRAPMONSTER)
	e2:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e2:SetTarget(c75646520.distarget)
	e2:SetReset(RESET_PHASE+PHASE_END)
	-- 向全局环境注册无效怪兽区陷阱怪兽效果的永续效果
	Duel.RegisterEffect(e2,tp)
end
-- 判断卡片是否为永续陷阱卡
function c75646520.distarget(e,c)
	return bit.band(c:GetType(),0x20004)==0x20004
end
