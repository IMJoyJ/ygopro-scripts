--E・HERO シャイニング・フェニックスガイ
-- 效果：
-- 「元素英雄 凤凰人」＋「元素英雄 电光侠」
-- 这只怪兽不能作融合召唤以外的特殊召唤。自己墓地每有1张名字带有「元素英雄」的卡，这张卡的攻击力上升300。这张卡不会被战斗破坏。
function c88820235.initial_effect(c)
	c:EnableReviveLimit()
	-- 设置融合召唤手续，融合素材为「元素英雄 凤凰人」和「元素英雄 电光侠」
	aux.AddFusionProcCode2(c,41436536,20721928,true,true)
	-- 这只怪兽不能作融合召唤以外的特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	-- 设置特殊召唤限制为仅能进行融合召唤
	e1:SetValue(aux.fuslimit)
	c:RegisterEffect(e1)
	-- 这张卡不会被战斗破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e2:SetValue(1)
	c:RegisterEffect(e2)
	-- 自己墓地每有1张名字带有「元素英雄」的卡，这张卡的攻击力上升300。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCode(EFFECT_UPDATE_ATTACK)
	e3:SetValue(c88820235.atkup)
	c:RegisterEffect(e3)
end
c88820235.material_setcode=0x8
-- 计算自身攻击力上升数值的辅助函数
function c88820235.atkup(e,c)
	-- 获取自己墓地中名字带有「元素英雄」的卡片数量并乘以300作为攻击力上升值
	return Duel.GetMatchingGroupCount(Card.IsSetCard,c:GetControler(),LOCATION_GRAVE,0,nil,0x3008)*300
end
