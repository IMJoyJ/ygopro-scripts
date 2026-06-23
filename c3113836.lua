--ジェムナイト・セラフィ
-- 效果：
-- 「宝石骑士」怪兽＋光属性怪兽
-- 这张卡用以上记的卡为融合素材的融合召唤才能从额外卡组特殊召唤。
-- ①：只要这张卡在怪兽区域存在，自己在通常召唤外加上只有1次，自己主要阶段可以把1只怪兽通常召唤。
function c3113836.initial_effect(c)
	c:EnableReviveLimit()
	-- 添加融合召唤手续，要求融合素材必须包含1只「宝石骑士」怪兽和1只光属性怪兽
	aux.AddFusionProcFun2(c,aux.FilterBoolFunction(Card.IsFusionSetCard,0x1047),aux.FilterBoolFunction(Card.IsFusionAttribute,ATTRIBUTE_LIGHT),false)
	-- ①：只要这张卡在怪兽区域存在，自己在通常召唤外加上只有1次，自己主要阶段可以把1只怪兽通常召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	e1:SetValue(c3113836.splimit)
	c:RegisterEffect(e1)
	-- ①：只要这张卡在怪兽区域存在，自己在通常召唤外加上只有1次，自己主要阶段可以把1只怪兽通常召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(3113836,0))  --"使用「宝石骑士·斜绿」的效果召唤"
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetTargetRange(LOCATION_HAND+LOCATION_MZONE,0)
	e2:SetCode(EFFECT_EXTRA_SUMMON_COUNT)
	e2:SetRange(LOCATION_MZONE)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EFFECT_EXTRA_SET_COUNT)
	c:RegisterEffect(e3)
end
-- 设置特殊召唤条件，只有当此卡从额外卡组特殊召唤且为融合召唤时才可特殊召唤
function c3113836.splimit(e,se,sp,st)
	return not e:GetHandler():IsLocation(LOCATION_EXTRA) or bit.band(st,SUMMON_TYPE_FUSION)==SUMMON_TYPE_FUSION
end
