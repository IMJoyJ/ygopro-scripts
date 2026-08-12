--フラワー・ウルフ
-- 效果：
-- 「银牙狼」＋「魔界之棘」
function c95952802.initial_effect(c)
	c:EnableReviveLimit()
	-- 添加以「银牙狼」和「魔界之棘」为融合素材的融合召唤手续
	aux.AddFusionProcCode2(c,90357090,43500484,true,true)
end
