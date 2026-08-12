--フュージョニスト
-- 效果：
-- 「小天使」＋「催眠羊」
function c1641882.initial_effect(c)
	c:EnableReviveLimit()
	-- 设置该卡片的融合召唤手续，使用卡号为38142739和83464209的2只怪兽为融合素材
	aux.AddFusionProcCode2(c,38142739,83464209,true,true)
end
