--セイバー・ヴォールト
-- 效果：
-- 场上表侧表示存在的名字带有「X-剑士」的怪兽的攻击力上升自身等级×100，守备力下降自身等级×100。
function c73787254.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- 场上表侧表示存在的名字带有「X-剑士」的怪兽的攻击力上升自身等级×100
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetRange(LOCATION_FZONE)
	e2:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	-- 设置效果影响的对象为名字带有「X-剑士」的怪兽
	e2:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,0x100d))
	e2:SetValue(c73787254.val1)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EFFECT_UPDATE_DEFENSE)
	e3:SetValue(c73787254.val2)
	c:RegisterEffect(e3)
end
-- 返回该怪兽自身等级×100的数值，作为攻击力上升的值
function c73787254.val1(e,c)
	return c:GetLevel()*100
end
-- 返回该怪兽自身等级×-100的数值，作为守备力下降的值
function c73787254.val2(e,c)
	return -c:GetLevel()*100
end
