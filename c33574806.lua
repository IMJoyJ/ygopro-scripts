--E・HERO エスクリダオ
-- 效果：
-- 名字带有「元素英雄」的怪兽＋暗属性怪兽
-- 这张卡不用融合召唤不能特殊召唤。这张卡的攻击力上升自己墓地存在的名字带有「元素英雄」的怪兽数量×100的数值。
function c33574806.initial_effect(c)
	c:EnableReviveLimit()
	-- 添加融合召唤手续，使用1只名字带有「元素英雄」的怪兽和1只暗属性怪兽作为融合素材
	aux.AddFusionProcFun2(c,aux.FilterBoolFunction(Card.IsFusionSetCard,0x3008),aux.FilterBoolFunction(Card.IsFusionAttribute,ATTRIBUTE_DARK),true)
	-- 这张卡不用融合召唤不能特殊召唤
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e2:SetCode(EFFECT_SPSUMMON_CONDITION)
	-- 设置该卡的特殊召唤方式必须为融合召唤
	e2:SetValue(aux.fuslimit)
	c:RegisterEffect(e2)
	-- 这张卡的攻击力上升自己墓地存在的名字带有「元素英雄」的怪兽数量×100的数值
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCode(EFFECT_UPDATE_ATTACK)
	e3:SetValue(c33574806.atkup)
	c:RegisterEffect(e3)
end
c33574806.material_setcode=0x8
-- 定义过滤函数，用于筛选墓地中的名字带有「元素英雄」的怪兽
function c33574806.atkfilter(c)
	return c:IsSetCard(0x3008) and c:IsType(TYPE_MONSTER)
end
-- 计算墓地符合条件的怪兽数量并乘以100作为攻击力提升值
function c33574806.atkup(e,c)
	-- 检索满足条件的卡片组并返回其数量，再乘以100
	return Duel.GetMatchingGroupCount(c33574806.atkfilter,c:GetControler(),LOCATION_GRAVE,0,nil)*100
end
