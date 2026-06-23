--無の畢竟 オールヴェイン
-- 效果：
-- 通常怪兽×2
function c3544583.initial_effect(c)
	c:EnableReviveLimit()
	-- 融合召唤手续：使用2个类型为通常怪兽的融合素材进行融合召唤
	aux.AddFusionProcFunRep(c,aux.FilterBoolFunction(Card.IsFusionType,TYPE_NORMAL),2,true)
end
