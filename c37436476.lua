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
	-- 设置此陷阱卡的发动条件：仅在伤害步骤中且尚未进行伤害计算时才能发动。
	e1:SetCondition(aux.dscon)
	c:RegisterEffect(e1)
	-- 自己场上表侧表示存在的名字带有「熔岩」的怪兽的攻击力上升自己墓地存在的名字带有「熔岩」的怪兽数量×100的数值。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetRange(LOCATION_SZONE)
	e2:SetTargetRange(LOCATION_MZONE,0)
	-- 将效果适用对象限定为自己场上表侧表示的名字带有「熔岩」字段的怪兽。
	e2:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,0x39))
	e2:SetValue(c37436476.val)
	c:RegisterEffect(e2)
end
-- 计算攻击力上升数值：统计自身墓地中名字带有「熔岩」的怪兽数量，再乘以100。
function c37436476.val(e,c)
	-- 获取当前怪兽控制者的墓地中名字带有「熔岩」的怪兽数量，乘以100作为攻击力上升值。
	return Duel.GetMatchingGroupCount(Card.IsSetCard,c:GetControler(),LOCATION_GRAVE,0,nil,0x39)*100
end
