--スーパービークロイド－ジャンボドリル
-- 效果：
-- 「蒸汽机人」＋「钻头机人」＋「潜艇机人」
-- 这只怪兽的融合召唤只能用上记的卡进行。这张卡攻击守备表示怪兽时，若攻击力超过那个守备力，给与对方基本分那个数值的战斗伤害。
function c36256625.initial_effect(c)
	c:EnableReviveLimit()
	-- 为卡片添加融合召唤手续，使用编号为44729197、71218746、99861526的3只怪兽作为融合素材
	aux.AddFusionProcCode3(c,44729197,71218746,99861526,false,false)
	-- 这张卡攻击守备表示怪兽时，若攻击力超过那个守备力，给与对方基本分那个数值的战斗伤害。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_PIERCE)
	c:RegisterEffect(e1)
end
