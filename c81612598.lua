--メタルフォーゼ・アダマンテ
-- 效果：
-- 「炼装」怪兽＋攻击力2500以下的怪兽
function c81612598.initial_effect(c)
	c:EnableReviveLimit()
	-- 设置融合召唤条件，融合素材为1只「炼装」怪兽和1只攻击力2500以下的怪兽
	aux.AddFusionProcFun2(c,aux.FilterBoolFunction(Card.IsFusionSetCard,0xe1),aux.FilterBoolFunction(Card.IsAttackBelow,2500),true)
end
