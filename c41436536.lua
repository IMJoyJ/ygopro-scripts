--E・HERO フェニックスガイ
-- 效果：
-- 「元素英雄 羽翼侠」＋「元素英雄 爆热女郎」
-- 这只怪兽不能作融合召唤以外的特殊召唤。这张卡不会被战斗破坏。
function c41436536.initial_effect(c)
	c:EnableReviveLimit()
	-- 添加融合召唤手续，使用卡号为21844576和58932615的2只怪兽为融合素材
	aux.AddFusionProcCode2(c,21844576,58932615,true,true)
	-- 这只怪兽不能作融合召唤以外的特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	-- 设置效果值为融合召唤限制函数，确保只能通过融合召唤特殊召唤
	e1:SetValue(aux.fuslimit)
	c:RegisterEffect(e1)
	-- 这张卡不会被战斗破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e2:SetValue(1)
	c:RegisterEffect(e2)
end
c41436536.material_setcode=0x8
