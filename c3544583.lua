--無の畢竟 オールヴェイン
-- 效果：
-- 通常怪兽×2
function c3544583.initial_effect(c)
	c:EnableReviveLimit()
	-- 为这张卡添加融合召唤手续：融合素材要求为2只满足“通常怪兽”条件的怪兽，即可以以2只通常怪兽为素材进行融合召唤。
	aux.AddFusionProcFunRep(c,aux.FilterBoolFunction(Card.IsFusionType,TYPE_NORMAL),2,true)
end
