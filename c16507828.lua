--ブラキオレイドス
-- 效果：
-- 「双头恐龙王」＋「贪尸龙」
function c16507828.initial_effect(c)
	c:EnableReviveLimit()
	-- 将该卡设为需要使用卡号为94119974和38289717的怪兽各1只作为融合素材的融合怪兽
	aux.AddFusionProcCode2(c,94119974,38289717,true,true)
end
