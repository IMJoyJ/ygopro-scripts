--E・HERO マッドボールマン
-- 效果：
-- 「元素英雄 水泡侠」＋「元素英雄 黏土侠」
-- 这只怪兽不能作融合召唤以外的特殊召唤。
function c52031567.initial_effect(c)
	c:EnableReviveLimit()
	-- 为此卡添加融合召唤手续，指定融合素材为「元素英雄 水泡侠」(79979666)与「元素英雄 黏土侠」(84327329)，并允许使用融合素材代用（sub=true, insf=true）。
	aux.AddFusionProcCode2(c,79979666,84327329,true,true)
	-- 这只怪兽不能作融合召唤以外的特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	-- 将特殊召唤条件的判定函数设置为aux.fuslimit，即仅当召唤类型为融合召唤时才允许特殊召唤，实现“不能作融合召唤以外的特殊召唤”的限制。
	e1:SetValue(aux.fuslimit)
	c:RegisterEffect(e1)
end
c52031567.material_setcode=0x8
