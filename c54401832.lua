--メタルフォーゼ・カーディナル
-- 效果：
-- 「炼装」怪兽＋攻击力3000以下的怪兽×2
function c54401832.initial_effect(c)
	c:EnableReviveLimit()
	-- 设置融合召唤手续：以1只「炼装」怪兽和2只攻击力3000以下的怪兽作为融合素材
	aux.AddFusionProcFunFun(c,aux.FilterBoolFunction(Card.IsFusionSetCard,0xe1),aux.FilterBoolFunction(Card.IsAttackBelow,3000),2,true)
end
