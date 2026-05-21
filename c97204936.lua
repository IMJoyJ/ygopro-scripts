--大地の騎士ガイアナイト
-- 效果：
-- 调整＋调整以外的怪兽1只以上
function c97204936.initial_effect(c)
	-- 为这张卡添加同调召唤手续：需要调整怪兽1只以及1只以上的调整以外的怪兽
	aux.AddSynchroProcedure(c,nil,aux.NonTuner(nil),1)
	c:EnableReviveLimit()
end
