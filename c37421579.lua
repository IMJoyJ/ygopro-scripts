--炎の騎士 キラー
-- 效果：
-- 「怪兽蛋」＋「史汀」
function c37421579.initial_effect(c)
	c:EnableReviveLimit()
	-- 设置该卡的融合召唤手续，使用卡号为36121917和96851799的2只怪兽为融合素材
	aux.AddFusionProcCode2(c,36121917,96851799,true,true)
end
