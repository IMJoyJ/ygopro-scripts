--E・HERO エスクリダオ
-- 效果：
-- 名字带有「元素英雄」的怪兽＋暗属性怪兽
-- 这张卡不用融合召唤不能特殊召唤。这张卡的攻击力上升自己墓地存在的名字带有「元素英雄」的怪兽数量×100的数值。
function c33574806.initial_effect(c)
	c:EnableReviveLimit()
	-- 为这张卡添加融合召唤手续：融合素材为1只卡名带有「元素英雄」的怪兽和1只暗属性怪兽，二者各1只。
	aux.AddFusionProcFun2(c,aux.FilterBoolFunction(Card.IsFusionSetCard,0x3008),aux.FilterBoolFunction(Card.IsFusionAttribute,ATTRIBUTE_DARK),true)
	-- 这张卡不用融合召唤不能特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e2:SetCode(EFFECT_SPSUMMON_CONDITION)
	-- 设置特殊召唤限制的判定值：仅当召唤方式为融合召唤时才允许特殊召唤，否则不能特殊召唤。
	e2:SetValue(aux.fuslimit)
	c:RegisterEffect(e2)
	-- 这张卡的攻击力上升自己墓地存在的名字带有「元素英雄」的怪兽数量×100的数值。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCode(EFFECT_UPDATE_ATTACK)
	e3:SetValue(c33574806.atkup)
	c:RegisterEffect(e3)
end
c33574806.material_setcode=0x8
-- 定义攻击力上升效果的过滤函数：筛选出卡名带有「元素英雄」的怪兽卡。
function c33574806.atkfilter(c)
	return c:IsSetCard(0x3008) and c:IsType(TYPE_MONSTER)
end
-- 定义攻击力上升数值的取得函数：统计自己墓地里符合条件的「元素英雄」怪兽数量，并乘以100。
function c33574806.atkup(e,c)
	-- 返回自己墓地「元素英雄」怪兽数量×100，作为这张卡的攻击力上升数值。
	return Duel.GetMatchingGroupCount(c33574806.atkfilter,c:GetControler(),LOCATION_GRAVE,0,nil)*100
end
