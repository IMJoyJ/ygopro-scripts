--魔導騎士ギルティア
-- 效果：
-- 「冥界的番人」＋「王座守护者」
function c51828629.initial_effect(c)
	c:EnableReviveLimit()
	-- 将该卡设为需要使用卡号为89272878和10071456的2只怪兽作为融合素材才能融合召唤
	aux.AddFusionProcCode2(c,89272878,10071456,true,true)
end
