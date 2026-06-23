--EMバブルドッグ
-- 效果：
-- ←5 【灵摆】 5→
-- ①：灵摆怪兽以外的从额外卡组特殊召唤的自己场上的表侧表示怪兽被战斗·效果破坏的场合，可以作为代替把这张卡破坏。
-- 【怪兽效果】
-- ①：这张卡从额外卡组的特殊召唤成功时才能发动。这个回合，从额外卡组特殊召唤的自己场上的灵摆怪兽不会被效果破坏。
function c34379489.initial_effect(c)
	-- 为卡片添加灵摆怪兽属性，使其可以灵摆召唤和发动灵摆卡
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
-- 定义一个过滤函数，用于判断目标怪兽是否满足被代替破坏的条件（表侧表示、自己控制、在主怪兽区、非灵摆怪兽、从额外卡组特殊召唤、因战斗或效果破坏且非代替破坏）
function c34379489.filter(c,tp)
	return c:IsFaceup() and c:IsControler(tp) and c:IsLocation(LOCATION_MZONE)
		and not c:IsType(TYPE_PENDULUM) and c:IsSummonLocation(LOCATION_EXTRA)
		and c:IsReason(REASON_BATTLE+REASON_EFFECT) and not c:IsReason(REASON_REPLACE)
end
-- 设置代替破坏效果的目标判定函数，检查是否有满足条件的怪兽被破坏，并判断该卡是否可以被破坏
function c34379489.reptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return eg:IsExists(c34379489.filter,1,nil,tp)
		and c:IsDestructable(e) and not c:IsStatus(STATUS_DESTROY_CONFIRMED) end
	-- 提示玩家是否发动该代替破坏效果
	return Duel.SelectEffectYesNo(tp,c,96)
end
-- 设置代替破坏效果的值函数，返回是否满足代替破坏条件
function c34379489.repval(e,c)
	return c34379489.filter(c,e:GetHandlerPlayer())
end
-- 设置代替破坏效果的操作函数，执行将该卡破坏的操作
function c34379489.repop(e,tp,eg,ep,ev,re,r,rp)
	-- 以效果和代替破坏的原因破坏该卡
	Duel.Destroy(e:GetHandler(),REASON_EFFECT+REASON_REPLACE)
end
-- 判断该卡是否是从额外卡组特殊召唤成功的
function c34379489.condition(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousLocation(LOCATION_EXTRA)
end
-- 发动效果后，创建一个永续效果，使本回合从额外卡组特殊召唤的灵摆怪兽不会被效果破坏
function c34379489.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 注册一个影响全场的永续效果，使灵摆怪兽不会被效果破坏
	local e2=Effect.CreateEffect(e:GetHandler())
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e2:SetTargetRange(LOCATION_MZONE,0)
	e2:SetTarget(c34379489.indtg)
	e2:SetReset(RESET_PHASE+PHASE_END)
	e2:SetValue(1)
	-- 将效果注册到全局环境
	Duel.RegisterEffect(e2,tp)
end
-- 定义一个目标函数，用于判断目标怪兽是否为从额外卡组特殊召唤的灵摆怪兽
function c34379489.indtg(e,c)
	return c:IsType(TYPE_PENDULUM) and c:IsSummonLocation(LOCATION_EXTRA)
end
