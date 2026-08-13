--水陸両用バグロス
-- 效果：
-- 「陆战型战斗艇」＋「守卫海洋的战士」
function c40173854.initial_effect(c)
	c:EnableReviveLimit()
	-- 为这张卡添加融合召唤手续：指定以「陆战型战斗艇」（卡号58314394）和「守卫海洋的战士」（卡号85448931）作为融合素材，并允许使用融合素材代用/置换（sub=true, insf=true）。
	aux.AddFusionProcCode2(c,58314394,85448931,true,true)
end
