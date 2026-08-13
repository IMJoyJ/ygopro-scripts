--E・HERO フェニックスガイ
-- 效果：
-- 「元素英雄 羽翼侠」＋「元素英雄 爆热女郎」
-- 这只怪兽不能作融合召唤以外的特殊召唤。这张卡不会被战斗破坏。
function c41436536.initial_effect(c)
	c:EnableReviveLimit()
	-- 为这张卡添加融合召唤手续，融合素材指定为卡号21844576的「元素英雄 羽翼侠」和卡号58932615的「元素英雄 爆热女郎」（后两个true表示允许使用融合素材代用品并按融合召唤手续处理）。
	aux.AddFusionProcCode2(c,21844576,58932615,true,true)
	-- 这只怪兽不能作融合召唤以外的特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	-- 将特殊召唤条件设置为辅助函数aux.fuslimit：仅当本次特殊召唤的召唤类型是融合召唤时判定通过，从而实现『不能作融合召唤以外的特殊召唤』的限制。
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
