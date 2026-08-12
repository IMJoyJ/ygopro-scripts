--メテオ・ブラック・ドラゴン
-- 效果：
-- 「真红眼黑龙」＋「流星之龙」
function c90660762.initial_effect(c)
	c:EnableReviveLimit()
	-- 为卡片c添加以「真红眼黑龙」和「流星之龙」为素材的融合召唤手续，并允许使用融合代替素材
	aux.AddFusionProcCode2(c,74677422,64271667,true,true)
end
c90660762.material_setcode=0x3b
