--炎熱旋風壁
-- 效果：
-- 自己场上表侧表示存在的名字带有「熔岩」的怪兽的攻击力上升自己墓地存在的名字带有「熔岩」的怪兽数量×100的数值。
function c37436476.initial_effect(c)
	-- 自己场上表侧表示存在的名字带有「熔岩」的怪兽的攻击力上升自己墓地存在的名字带有「熔岩」的怪兽数量×100的数值。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(TIMING_DAMAGE_STEP)
	-- 限制效果只能在伤害计算前的时机发动或适用
	e1:SetCondition(aux.dscon)
	c:RegisterEffect(e1)
	-- 自己场上表侧表示存在的名字带有「熔岩」的怪兽的攻击力上升自己墓地存在的名字带有「熔岩」的怪兽数量×100的数值。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetRange(LOCATION_SZONE)
	e2:SetTargetRange(LOCATION_MZONE,0)
	-- 设定效果目标为场上表侧表示存在的名字带有「熔岩」的怪兽
	e2:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,0x39))
	e2:SetValue(c37436476.val)
	c:RegisterEffect(e2)
end
-- 计算墓地里名字带有「熔岩」的怪兽数量并乘以100作为攻击力提升值
function c37436476.val(e,c)
	-- 检索满足条件的墓地怪兽数量并乘以100
	return Duel.GetMatchingGroupCount(Card.IsSetCard,c:GetControler(),LOCATION_GRAVE,0,nil,0x39)*100
end
