--水陸両用バグロス
-- 效果：
-- 「陆战型战斗艇」＋「守卫海洋的战士」
function c40173854.initial_effect(c)
	c:EnableReviveLimit()
	-- 融合召唤手续：使用卡号为58314394和85448931的2只怪兽为融合素材
	aux.AddFusionProcCode2(c,58314394,85448931,true,true)
end
