--クリッチー
-- 效果：
-- 「三眼怪」＋「黑森林的魔女」
function c53539634.initial_effect(c)
	c:EnableReviveLimit()
	-- 将该卡设为需要使用卡号为78010363和26202165的2只怪兽作为融合素材才能融合召唤
	aux.AddFusionProcCode2(c,78010363,26202165,true,true)
end
