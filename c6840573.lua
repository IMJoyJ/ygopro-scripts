--バロックス
-- 效果：
-- 「杀人熊猫」＋「石像怪」
function c6840573.initial_effect(c)
	c:EnableReviveLimit()
	-- 添加以「杀人熊猫」和「石像怪」为融合素材的融合召唤手续
	aux.AddFusionProcCode2(c,98818516,15303296,true,true)
end
