--千年竜
-- 效果：
-- 「时间魔术师」＋「宝贝龙」
function c41462083.initial_effect(c)
	c:EnableReviveLimit()
	-- 将该卡设为需要使用卡号为71625222和88819587的2只怪兽作为融合素材才能融合召唤
	aux.AddFusionProcCode2(c,71625222,88819587,true,true)
end
