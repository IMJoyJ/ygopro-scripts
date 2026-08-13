--迷宮の魔戦車
-- 效果：
-- 「高科技狼」＋「加农炮兵」
function c99551425.initial_effect(c)
	c:EnableReviveLimit()
	-- 为这张卡添加融合召唤手续，允许使用卡号8471389（高科技狼）和卡号11384280（加农炮兵）作为融合素材进行融合召唤，sub和insf均为true表示支持同一卡名的替代素材及特殊召唤手续。
	aux.AddFusionProcCode2(c,8471389,11384280,true,true)
end
