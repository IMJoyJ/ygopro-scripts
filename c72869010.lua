--ソウル・ハンター
-- 效果：
-- 「神灯魔人」＋「来自异次元的侵略者」
function c72869010.initial_effect(c)
	c:EnableReviveLimit()
	-- 添加以「神灯魔人」和「来自异次元的侵略者」为融合素材的融合召唤手续（允许使用融合代替素材）
	aux.AddFusionProcCode2(c,99510761,28450915,true,true)
end
