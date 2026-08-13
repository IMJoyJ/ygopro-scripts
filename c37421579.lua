--炎の騎士 キラー
-- 效果：
-- 「怪兽蛋」＋「史汀」
function c37421579.initial_effect(c)
	c:EnableReviveLimit()
	-- 为这张卡添加融合召唤手续：以卡号36121917的「怪兽蛋」和卡号96851799的「史汀」作为融合素材进行融合召唤，后两个true分别表示允许使用融合素材代用品以及该融合素材组合可被代用品替代（即不是绝对严格的指定素材）。
	aux.AddFusionProcCode2(c,36121917,96851799,true,true)
end
