--砂の魔女
-- 效果：
-- 「岩石巨兵」＋「古代精灵」
function c32751480.initial_effect(c)
	c:EnableReviveLimit()
	-- 为「砂之魔女」添加融合召唤手续：以卡号13039848的「岩石巨兵」与卡号93221206的「古代精灵」这2只怪兽为融合素材。
	aux.AddFusionProcCode2(c,13039848,93221206,true,true)
end
