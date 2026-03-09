--ガーディアン・グラール
-- 效果：
-- 当自己场上存在「重力之斧-咆哮」时才能召唤·反转召唤·特殊召唤。当手卡仅有这张卡1张时，这张卡可以从手卡直接特殊召唤上场。
function c47150851.initial_effect(c)
	-- 当自己场上不存在「重力之斧-咆哮」时不能召唤
	local e1=Effect.CreateEffect(c)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_CANNOT_SUMMON)
	e1:SetCondition(c47150851.sumcon)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_CANNOT_FLIP_SUMMON)
	c:RegisterEffect(e2)
	-- 当自己场上存在「重力之斧-咆哮」时才能特殊召唤
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e3:SetCode(EFFECT_SPSUMMON_CONDITION)
	e3:SetValue(c47150851.sumlimit)
	c:RegisterEffect(e3)
	-- 当手卡仅有这张卡1张时，可以从手卡直接特殊召唤上场
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD)
	e4:SetCode(EFFECT_SPSUMMON_PROC)
	e4:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e4:SetRange(LOCATION_HAND)
	e4:SetCondition(c47150851.spcon)
	c:RegisterEffect(e4)
end
-- 过滤函数，检查场上是否存在表侧表示的「重力之斧-咆哮」
function c47150851.cfilter(c)
	return c:IsFaceup() and c:IsCode(32022366)
end
-- 判断是否满足召唤条件：自己场上不存在「重力之斧-咆哮」
function c47150851.sumcon(e)
	-- 检索满足条件的卡片组，即场上是否存在「重力之斧-咆哮」
	return not Duel.IsExistingMatchingCard(c47150851.cfilter,e:GetHandlerPlayer(),LOCATION_ONFIELD,0,1,nil)
end
-- 判断是否满足特殊召唤条件：自己场上存在「重力之斧-咆哮」
function c47150851.sumlimit(e,se,sp,st,pos,tp)
	-- 检索满足条件的卡片组，即场上是否存在「重力之斧-咆哮」
	return Duel.IsExistingMatchingCard(c47150851.cfilter,sp,LOCATION_ONFIELD,0,1,nil)
end
-- 判断是否满足手卡直接特殊召唤条件：有足够怪兽区域、手卡只有1张且场上存在「重力之斧-咆哮」
function c47150851.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 检查玩家是否有足够的怪兽区域
	return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查玩家手卡是否仅有1张
		and Duel.GetFieldGroupCount(tp,LOCATION_HAND,0)==1
		-- 检索满足条件的卡片组，即场上是否存在「重力之斧-咆哮」
		and Duel.IsExistingMatchingCard(c47150851.cfilter,e:GetHandlerPlayer(),LOCATION_ONFIELD,0,1,nil)
end
