--召喚獣メガラニカ
-- 效果：
-- 「召唤师 阿莱斯特」＋地属性怪兽
function c48791583.initial_effect(c)
	c:EnableReviveLimit()
	-- 添加融合召唤手续，使用卡号为86120751的怪兽1只与1只满足地属性条件的怪兽作为融合素材进行融合召唤
	aux.AddFusionProcCodeFun(c,86120751,aux.FilterBoolFunction(Card.IsFusionAttribute,ATTRIBUTE_EARTH),1,true,true)
end
