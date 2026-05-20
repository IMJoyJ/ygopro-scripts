--M・HERO 剛火
-- 效果：
-- 这张卡用「假面变化」的效果才能特殊召唤。这张卡的攻击力上升自己墓地存在的名字带有「英雄」的怪兽数量×100的数值。
function c58147549.initial_effect(c)
	c:EnableReviveLimit()
	-- 这张卡用「假面变化」的效果才能特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	-- 设置特殊召唤限制，仅允许通过「假面变化」的效果进行特殊召唤
	e1:SetValue(aux.MaskChangeLimit)
	c:RegisterEffect(e1)
	-- 这张卡的攻击力上升自己墓地存在的名字带有「英雄」的怪兽数量×100的数值。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetValue(c58147549.atkup)
	c:RegisterEffect(e2)
end
-- 过滤条件：判断是否为名字带有「英雄」的怪兽
function c58147549.atkfilter(c)
	return c:IsSetCard(0x8) and c:IsType(TYPE_MONSTER)
end
-- 计算攻击力上升数值的函数
function c58147549.atkup(e,c)
	-- 获取自己墓地中「英雄」怪兽的数量并乘以100，返回最终的攻击力上升值
	return Duel.GetMatchingGroupCount(c58147549.atkfilter,c:GetControler(),LOCATION_GRAVE,0,nil)*100
end
