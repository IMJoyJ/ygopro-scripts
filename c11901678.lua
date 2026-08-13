--ブラック・デーモンズ・ドラゴン
-- 效果：
-- 「恶魔召唤」＋「真红眼黑龙」
function c11901678.initial_effect(c)
	c:EnableReviveLimit()
	-- 为『暗黑魔龙』添加融合召唤手续：以卡号70781052（『恶魔召唤』）和卡号74677422（『真红眼黑龙』）作为融合素材，并启用融合素材代用规则。
	aux.AddFusionProcCode2(c,70781052,74677422,true,true)
end
c11901678.material_setcode=0x3b
