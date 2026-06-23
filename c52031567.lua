--E・HERO マッドボールマン
-- 效果：
-- 「元素英雄 水泡侠」＋「元素英雄 黏土侠」
-- 这只怪兽不能作融合召唤以外的特殊召唤。
function c52031567.initial_effect(c)
	c:EnableReviveLimit()
	-- 添加融合召唤手续，使用卡号为79979666和84327329的两只怪兽为融合素材
	aux.AddFusionProcCode2(c,79979666,84327329,true,true)
	-- 这只怪兽不能作融合召唤以外的特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	-- 设置效果值为过滤函数aux.fuslimit，用于限制只能通过融合召唤特殊召唤
	e1:SetValue(aux.fuslimit)
	c:RegisterEffect(e1)
end
c52031567.material_setcode=0x8
