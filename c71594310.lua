--ジェムナイト・パール
-- 效果：
-- 4星怪兽×2
function c71594310.initial_effect(c)
	-- 为这张卡添加超量召唤手续，素材为2只4星怪兽
	aux.AddXyzProcedure(c,nil,4,2)
	c:EnableReviveLimit()
end
