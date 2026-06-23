--砂の魔女
-- 效果：
-- 「岩石巨兵」＋「古代精灵」
function c32751480.initial_effect(c)
	c:EnableReviveLimit()
	-- 设置融合召唤手续，使用卡号为13039848和93221206的2只怪兽为融合素材
	aux.AddFusionProcCode2(c,13039848,93221206,true,true)
end
