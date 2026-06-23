--スカルビショップ
-- 效果：
-- 「恶魔的智慧」＋「魔天老」
function c2504891.initial_effect(c)
	c:EnableReviveLimit()
	-- 将该卡设为需要使用卡号为28725004和42431843的2只怪兽作为融合素材才能融合召唤
	aux.AddFusionProcCode2(c,28725004,42431843,true,true)
end
