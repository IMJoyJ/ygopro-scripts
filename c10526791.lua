--E・HERO ワイルドジャギーマン
-- 效果：
-- 「元素英雄 荒野侠」＋「元素英雄 金刃侠」
-- 这张卡不用融合召唤不能特殊召唤。
-- ①：这张卡可以向对方怪兽全部各作1次攻击。
function c10526791.initial_effect(c)
	c:EnableReviveLimit()
	-- 添加融合召唤手续，使用卡号为86188410和59793705的2只怪兽为融合素材
	aux.AddFusionProcCode2(c,86188410,59793705,true,true)
	-- 这张卡不用融合召唤不能特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	-- 设置融合召唤限制过滤函数
	e1:SetValue(aux.fuslimit)
	c:RegisterEffect(e1)
	-- ①：这张卡可以向对方怪兽全部各作1次攻击。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_ATTACK_ALL)
	e2:SetValue(1)
	c:RegisterEffect(e2)
end
c10526791.material_setcode=0x8
