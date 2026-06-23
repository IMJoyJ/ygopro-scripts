--ブラック・デーモンズ・ドラゴン
-- 效果：
-- 「恶魔召唤」＋「真红眼黑龙」
function c11901678.initial_effect(c)
	c:EnableReviveLimit()
	-- 将使用卡号为70781052和74677422的2只怪兽作为融合素材的融合召唤手续加入此卡
	aux.AddFusionProcCode2(c,70781052,74677422,true,true)
end
c11901678.material_setcode=0x3b
