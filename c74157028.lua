--サイバー・ツイン・ドラゴン
-- 效果：
-- 「电子龙」＋「电子龙」
-- 这张卡的融合召唤不用上记的卡不能进行。
-- ①：这张卡在同1次的战斗阶段中可以作2次攻击。
function c74157028.initial_effect(c)
	c:EnableReviveLimit()
	-- 设置以2只「电子龙」为素材的融合召唤手续，且不能使用融合代替素材
	aux.AddFusionProcCodeRep(c,70095154,2,false,false)
	-- ①：这张卡在同1次的战斗阶段中可以作2次攻击。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_EXTRA_ATTACK)
	e2:SetValue(1)
	c:RegisterEffect(e2)
end
c74157028.material_setcode=0x1093
