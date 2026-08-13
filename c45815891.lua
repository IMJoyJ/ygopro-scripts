--スクラップ・デスデーモン
-- 效果：
-- 调整＋调整以外的怪兽1只以上
function c45815891.initial_effect(c)
	-- 为这张卡添加同调召唤手续：同调素材为1只调整怪兽＋1只以上调整以外的怪兽，且双方素材均无额外条件限制。
	aux.AddSynchroProcedure(c,nil,aux.NonTuner(nil),1)
	c:EnableReviveLimit()
end
