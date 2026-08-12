--ジェムナイト・ジルコニア
-- 效果：
-- 「宝石骑士」怪兽＋岩石族怪兽
function c8692301.initial_effect(c)
	c:EnableReviveLimit()
	-- 添加融合召唤手续，素材为1只「宝石骑士」怪兽和1只岩石族怪兽
	aux.AddFusionProcFun2(c,aux.FilterBoolFunction(Card.IsFusionSetCard,0x1047),aux.FilterBoolFunction(Card.IsRace,RACE_ROCK),true)
end
