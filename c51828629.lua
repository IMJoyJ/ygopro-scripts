--魔導騎士ギルティア
-- 效果：
-- 「冥界的番人」＋「王座守护者」
function c51828629.initial_effect(c)
	c:EnableReviveLimit()
	-- 为这张卡设置融合召唤手续：融合素材指定为卡号89272878的「冥界的番人」和卡号10071456的「王座守护者」（两个true表示允许使用融合素材代用怪兽等替代条件）。
	aux.AddFusionProcCode2(c,89272878,10071456,true,true)
end
