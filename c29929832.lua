--マリン・ビースト
-- 效果：
-- 「水之魔导师」＋「大肚海蛇」
function c29929832.initial_effect(c)
	c:EnableReviveLimit()
	-- 将该卡设为需要使用卡号为93343894和94022093的2只怪兽作为融合素材才能融合召唤
	aux.AddFusionProcCode2(c,93343894,94022093,true,true)
end
