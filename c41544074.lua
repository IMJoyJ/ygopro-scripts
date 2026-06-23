--カオス・ウィザード
-- 效果：
-- 「圣精灵」＋「黑魔族的幕帘」
function c41544074.initial_effect(c)
	c:EnableReviveLimit()
	-- 将该卡设为需要使用卡号为15025844和22026707的2只怪兽作为融合素材才能融合召唤
	aux.AddFusionProcCode2(c,15025844,22026707,true,true)
end
