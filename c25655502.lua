--デビル・ボックス
-- 效果：
-- 「杀人小丑」＋「梦幻小丑」
function c25655502.initial_effect(c)
	c:EnableReviveLimit()
	-- 为「恶魔箱」添加融合召唤手续：以卡号93889755（「杀人小丑」）和卡号13215230（「梦幻小丑」）作为融合素材进行融合召唤；两个true参数分别启用了对应的融合手续辅助设定（sub与insf）。
	aux.AddFusionProcCode2(c,93889755,13215230,true,true)
end
