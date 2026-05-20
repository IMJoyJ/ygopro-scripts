--アクア・ドラゴン
-- 效果：
-- 「妖精龙」＋「海原的女战士」＋「区域吞噬者」
function c86164529.initial_effect(c)
	c:EnableReviveLimit()
	-- 添加以「妖精龙」、「海原的女战士」和「区域吞噬者」为素材的融合召唤手续
	aux.AddFusionProcCode3(c,20315854,17968114,86100785,true,true)
end
