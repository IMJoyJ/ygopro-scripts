--古代の機械混沌巨人
-- 效果：
-- 「古代的机械」怪兽×4
-- 这张卡不用融合召唤不能特殊召唤。
-- ①：只要这张卡在怪兽区域存在，这张卡不受魔法·陷阱卡的效果影响，对方在战斗阶段中不能把怪兽的效果发动。
-- ②：这张卡可以向对方怪兽全部各作1次攻击，向守备表示怪兽攻击的场合，给与对方为攻击力超过那个守备力的数值的战斗伤害。
function c51788412.initial_effect(c)
	c:EnableReviveLimit()
	-- 添加融合召唤手续，使用4个「古代的机械」卡为融合素材进行融合召唤
	aux.AddFusionProcFunRep(c,aux.FilterBoolFunction(Card.IsFusionSetCard,0x7),4,true)
	-- 这张卡不用融合召唤不能特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	-- 设置该效果为融合召唤限制条件
	e1:SetValue(aux.fuslimit)
	c:RegisterEffect(e1)
	-- 只要这张卡在怪兽区域存在，这张卡不受魔法·陷阱卡的效果影响
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetCode(EFFECT_IMMUNE_EFFECT)
	e2:SetRange(LOCATION_MZONE)
	e2:SetValue(c51788412.efilter)
	c:RegisterEffect(e2)
	-- 对方在战斗阶段中不能把怪兽的效果发动
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e3:SetCode(EFFECT_CANNOT_ACTIVATE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetTargetRange(0,1)
	e3:SetCondition(c51788412.actcon)
	e3:SetValue(c51788412.actlimit)
	c:RegisterEffect(e3)
	-- 这张卡可以向对方怪兽全部各作1次攻击
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetCode(EFFECT_ATTACK_ALL)
	e4:SetValue(1)
	c:RegisterEffect(e4)
	-- 向守备表示怪兽攻击的场合，给与对方为攻击力超过那个守备力的数值的战斗伤害
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_SINGLE)
	e5:SetCode(EFFECT_PIERCE)
	c:RegisterEffect(e5)
end
-- 效果过滤函数，用于判断是否为魔法或陷阱卡的效果
function c51788412.efilter(e,te)
	return te:IsActiveType(TYPE_SPELL+TYPE_TRAP)
end
-- 条件函数，判断当前阶段是否为战斗阶段开始到战斗阶段结束之间
function c51788412.actcon(e)
	-- 获取当前游戏阶段
	local ph=Duel.GetCurrentPhase()
	return ph>=PHASE_BATTLE_START and ph<=PHASE_BATTLE
end
-- 效果限制函数，用于限制对方不能发动怪兽卡的效果
function c51788412.actlimit(e,re,tp)
	return re:IsActiveType(TYPE_MONSTER)
end
