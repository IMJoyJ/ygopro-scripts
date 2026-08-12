--双頭の雷龍
-- 效果：
-- 「雷龙」＋「雷龙」
function c54752875.initial_effect(c)
	c:EnableReviveLimit()
	-- 添加融合召唤手续，需要2张「雷龙」作为融合素材（允许使用融合代替素材）
	aux.AddFusionProcCodeRep(c,31786629,2,true,true)
end
