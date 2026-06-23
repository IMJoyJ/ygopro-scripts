--プランクスケール
-- 效果：
-- ①：这个回合中，以下效果适用。
-- ●双方场上的全部3阶以下的超量怪兽的攻击力·守备力上升500。
-- ●双方场上的全部4阶以上的超量怪兽不能攻击。
function c10282757.initial_effect(c)
	-- ①：这个回合中，以下效果适用。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetOperation(c10282757.activate)
	c:RegisterEffect(e1)
end
-- 此卡发动时的效果处理：在此回合内注册适用的攻击力·守备力上升以及不能攻击的场地效果
function c10282757.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- ●双方场上的全部3阶以下的超量怪兽的攻击力·守备力上升500。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e1:SetValue(500)
	e1:SetTarget(c10282757.filter1)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 在全局注册使3阶以下超量怪兽攻击力上升的效果
	Duel.RegisterEffect(e1,tp)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_UPDATE_DEFENSE)
	-- 在全局注册使3阶以下超量怪兽守备力上升的效果
	Duel.RegisterEffect(e2,tp)
	-- ●双方场上的全部4阶以上的超量怪兽不能攻击。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_CANNOT_ATTACK)
	e3:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e3:SetReset(RESET_PHASE+PHASE_END)
	e3:SetTarget(c10282757.filter2)
	-- 在全局注册使4阶以上超量怪兽不能攻击的效果
	Duel.RegisterEffect(e3,tp)
end
-- 过滤双方场上3阶以下的超量怪兽
function c10282757.filter1(e,c)
	return c:IsType(TYPE_XYZ) and c:IsRankBelow(3)
end
-- 过滤双方场上4阶以上的超量怪兽
function c10282757.filter2(e,c)
	return c:IsType(TYPE_XYZ) and c:IsRankAbove(4)
end
