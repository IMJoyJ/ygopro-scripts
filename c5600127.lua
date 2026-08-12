--ヒューマノイド・ドレイク
-- 效果：
-- 「鳞虫」＋「人形史莱姆」
function c5600127.initial_effect(c)
	c:EnableReviveLimit()
	-- 添加以「鳞虫」和「人形史莱姆」为素材，且允许使用融合代替素材的融合召唤手续
	aux.AddFusionProcCode2(c,73216412,46821314,true,true)
end
