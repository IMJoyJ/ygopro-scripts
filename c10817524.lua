--始祖竜ワイアーム
-- 效果：
-- 通常怪兽×2
-- 这张卡不用融合召唤不能特殊召唤。
-- ①：「始祖龙 古龙」在自己场上只能有1张表侧表示存在。
-- ②：这张卡只要在怪兽区域存在，不会被和通常怪兽以外的怪兽的战斗破坏，不受这张卡以外的怪兽的效果影响。
function c10817524.initial_effect(c)
	c:SetUniqueOnField(1,0,10817524)
	c:EnableReviveLimit()
	-- 添加融合召唤手续，使用2个通常怪兽作为融合素材
	aux.AddFusionProcFunRep(c,aux.FilterBoolFunction(Card.IsFusionType,TYPE_NORMAL),2,true)
	-- ①：「始祖龙 古龙」在自己场上只能有1张表侧表示存在。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	-- 设置该效果的值为aux.fuslimit函数，用于限制只能通过融合召唤特殊召唤
	e1:SetValue(aux.fuslimit)
	c:RegisterEffect(e1)
	-- ②：这张卡只要在怪兽区域存在，不会被和通常怪兽以外的怪兽的战斗破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e2:SetValue(c10817524.indval)
	c:RegisterEffect(e2)
	-- ②：这张卡只要在怪兽区域存在，不会被和通常怪兽以外的怪兽的战斗破坏，不受这张卡以外的怪兽的效果影响。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCode(EFFECT_IMMUNE_EFFECT)
	e3:SetValue(c10817524.efilter)
	c:RegisterEffect(e3)
end
-- indval函数用于判断是否不会被战斗破坏，当目标怪兽不是通常怪兽时返回true
function c10817524.indval(e,c)
	return not c:IsType(TYPE_NORMAL)
end
-- efilter函数用于判断是否免疫效果，当效果来源为怪兽且不是自己时返回true
function c10817524.efilter(e,te)
	return te:IsActiveType(TYPE_MONSTER) and te:GetOwner()~=e:GetOwner()
end
