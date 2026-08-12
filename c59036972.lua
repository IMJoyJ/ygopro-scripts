--マブラス
-- 效果：
-- 「大炮鸟」＋「邪炎之翼」
function c59036972.initial_effect(c)
	c:EnableReviveLimit()
	-- 添加以「大炮鸟」和「邪炎之翼」为融合素材的融合召唤手续
	aux.AddFusionProcCode2(c,72842870,92944626,true,true)
end
