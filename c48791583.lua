--召喚獣メガラニカ
-- 效果：
-- 「召唤师 阿莱斯特」＋地属性怪兽
function c48791583.initial_effect(c)
	c:EnableReviveLimit()
	-- 为「召唤兽 墨瓦腊泥加」添加融合召唤手续：指定融合素材为1只「召唤师 阿莱斯特」（卡号86120751）与1只地属性怪兽，使该卡可以按此素材组合进行融合召唤。
	aux.AddFusionProcCodeFun(c,86120751,aux.FilterBoolFunction(Card.IsFusionAttribute,ATTRIBUTE_EARTH),1,true,true)
end
