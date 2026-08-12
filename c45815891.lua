--スクラップ・デスデーモン
-- 效果：
-- 调整＋调整以外的怪兽1只以上
function c45815891.initial_effect(c)
	-- 添加同调召唤手续，要求1只满足条件的调整怪兽和1只满足条件的调整以外的怪兽
	aux.AddSynchroProcedure(c,nil,aux.NonTuner(nil),1)
	c:EnableReviveLimit()
end
