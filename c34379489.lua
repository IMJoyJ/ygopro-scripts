--EMバブルドッグ
-- 效果：
-- ←5 【灵摆】 5→
-- ①：灵摆怪兽以外的从额外卡组特殊召唤的自己场上的表侧表示怪兽被战斗·效果破坏的场合，可以作为代替把这张卡破坏。
-- 【怪兽效果】
-- ①：这张卡从额外卡组的特殊召唤成功时才能发动。这个回合，从额外卡组特殊召唤的自己场上的灵摆怪兽不会被效果破坏。
function c34379489.initial_effect(c)
	-- 为这张卡添加灵摆怪兽属性（包括灵摆召唤、灵摆卡发动）。
	aux.EnablePendulumAttribute(c)
	-- ①：灵摆怪兽以外的从额外卡组特殊召唤的自己场上的表侧表示怪兽被战斗·效果破坏的场合，可以作为代替把这张卡破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_DESTROY_REPLACE)
	e2:SetRange(LOCATION_PZONE)
	e2:SetTarget(c34379489.reptg)
	e2:SetValue(c34379489.repval)
	e2:SetOperation(c34379489.repop)
	c:RegisterEffect(e2)
	-- ①：这张卡从额外卡组的特殊召唤成功时才能发动。这个回合，从额外卡组特殊召唤的自己场上的灵摆怪兽不会被效果破坏。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	e3:SetCondition(c34379489.condition)
	e3:SetOperation(c34379489.operation)
	c:RegisterEffect(e3)
end
-- 筛选满足代替破坏条件的怪兽：表侧表示且自己场上的主要怪兽区、不是灵摆怪兽、从额外卡组特殊召唤、因战斗或效果被破坏且不是因代替效果被破坏。
function c34379489.filter(c,tp)
	return c:IsFaceup() and c:IsControler(tp) and c:IsLocation(LOCATION_MZONE)
		and not c:IsType(TYPE_PENDULUM) and c:IsSummonLocation(LOCATION_EXTRA)
		and c:IsReason(REASON_BATTLE+REASON_EFFECT) and not c:IsReason(REASON_REPLACE)
end
-- 代替破坏效果的发动条件：场上存在符合filter的被破坏怪兽，且此卡自身可被破坏且未被预定破坏。
function c34379489.reptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return eg:IsExists(c34379489.filter,1,nil,tp)
		and c:IsDestructable(e) and not c:IsStatus(STATUS_DESTROY_CONFIRMED) end
	-- 让控制者选择是否发动此卡的代替破坏效果。
	return Duel.SelectEffectYesNo(tp,c,96)
end
-- 判定某只将要被破坏的怪兽是否属于可以被此卡代替破坏的对象。
function c34379489.repval(e,c)
	return c34379489.filter(c,e:GetHandlerPlayer())
end
-- 代替破坏实际的执行：将此卡破坏。
function c34379489.repop(e,tp,eg,ep,ev,re,r,rp)
	-- 以效果破坏与代替破坏的理由破坏此卡，从而代替目标怪兽被破坏。
	Duel.Destroy(e:GetHandler(),REASON_EFFECT+REASON_REPLACE)
end
-- 发动条件：这张卡从额外卡组特殊召唤成功时。
function c34379489.condition(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousLocation(LOCATION_EXTRA)
end
-- 发动后处理：给己方场上从额外卡组特殊召唤的灵摆怪兽附加“不会被效果破坏”的效果，持续到回合结束。
function c34379489.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 这个回合，从额外卡组特殊召唤的自己场上的灵摆怪兽不会被效果破坏。
	local e2=Effect.CreateEffect(e:GetHandler())
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e2:SetTargetRange(LOCATION_MZONE,0)
	e2:SetTarget(c34379489.indtg)
	e2:SetReset(RESET_PHASE+PHASE_END)
	e2:SetValue(1)
	-- 将上述免疫效果注册到场上，使其在本回合内适用于我方场上的对象。
	Duel.RegisterEffect(e2,tp)
end
-- 判定对象怪兽是否为从额外卡组特殊召唤的灵摆怪兽。
function c34379489.indtg(e,c)
	return c:IsType(TYPE_PENDULUM) and c:IsSummonLocation(LOCATION_EXTRA)
end
