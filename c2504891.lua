--スカルビショップ
-- 效果：
-- 「恶魔的智慧」＋「魔天老」
function c2504891.initial_effect(c)
	c:EnableReviveLimit()
	-- 为这张卡添加融合召唤手续：以卡号28725004的『恶魔的智慧』与卡号42431843的『魔天老』作为融合素材（允许融合素材代用品，且限定素材必须为上述二者）。
	aux.AddFusionProcCode2(c,28725004,42431843,true,true)
end
