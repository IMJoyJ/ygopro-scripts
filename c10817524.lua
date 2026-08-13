--始祖竜ワイアーム
-- 效果：
-- 通常怪兽×2
-- 这张卡不用融合召唤不能特殊召唤。
-- ①：「始祖龙 古龙」在自己场上只能有1张表侧表示存在。
-- ②：这张卡只要在怪兽区域存在，不会被和通常怪兽以外的怪兽的战斗破坏，不受这张卡以外的怪兽的效果影响。
function c10817524.initial_effect(c)
	c:SetUniqueOnField(1,0,10817524)
	c:EnableReviveLimit()
	-- 为这张卡添加融合召唤手续：以2只通常怪兽作为融合素材进行融合召唤（对应效果原文‘通常怪兽×2’）。
	aux.AddFusionProcFunRep(c,aux.FilterBoolFunction(Card.IsFusionType,TYPE_NORMAL),2,true)
	-- 这张卡不用融合召唤不能特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	-- 将特殊召唤条件效果的值设为aux.fuslimit，即只有融合召唤这一特殊召唤方式被允许，其他特殊召唤方式均被禁止。
	e1:SetValue(aux.fuslimit)
	c:RegisterEffect(e1)
	-- ②：这张卡只要在怪兽区域存在，不会被和通常怪兽以外的怪兽的战斗破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e2:SetValue(c10817524.indval)
	c:RegisterEffect(e2)
	-- ②：这张卡只要在怪兽区域存在，不受这张卡以外的怪兽的效果影响。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCode(EFFECT_IMMUNE_EFFECT)
	e3:SetValue(c10817524.efilter)
	c:RegisterEffect(e3)
end
-- 战斗破坏免疫的判定函数：对方怪兽不是通常怪兽时返回true，即与通常怪兽以外的怪兽战斗时本卡不会被战斗破坏；与通常怪兽战斗时不免疫战斗破坏。
function c10817524.indval(e,c)
	return not c:IsType(TYPE_NORMAL)
end
-- 效果免疫的判定函数：若来源效果是怪兽效果且其所有者不是本卡则返回true，即只不受这张卡以外的怪兽的效果影响。
function c10817524.efilter(e,te)
	return te:IsActiveType(TYPE_MONSTER) and te:GetOwner()~=e:GetOwner()
end
