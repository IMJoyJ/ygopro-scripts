--森の番人グリーン・バブーン
-- 效果：
-- ①：这张卡在手卡·墓地存在，自己场上的表侧表示的兽族怪兽被效果破坏送去墓地时，支付1000基本分才能发动。这张卡特殊召唤。
function c46668237.initial_effect(c)
	-- 效果原文内容：①：这张卡在手卡·墓地存在，自己场上的表侧表示的兽族怪兽被效果破坏送去墓地时，支付1000基本分才能发动。这张卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(46668237,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetRange(LOCATION_HAND+LOCATION_GRAVE)
	e1:SetCode(EVENT_TO_GRAVE)
	e1:SetCondition(c46668237.condition)
	e1:SetCost(c46668237.cost)
	e1:SetTarget(c46668237.target)
	e1:SetOperation(c46668237.operation)
	c:RegisterEffect(e1)
end
-- 检索满足条件的被破坏怪兽：必须是怪兽、兽族、从前控制者为自己、从前正面表示、从前在主要怪兽区、种族包含兽族
function c46668237.cfilter(c,tp)
	return c:IsType(TYPE_MONSTER) and c:IsRace(RACE_BEAST) and c:IsPreviousControler(tp) and c:IsPreviousPosition(POS_FACEUP)
		and c:IsPreviousLocation(LOCATION_MZONE) and bit.band(c:GetPreviousRaceOnField(),RACE_BEAST)~=0
end
-- 判断是否满足发动条件：被破坏怪兽组不包含此卡自身、存在满足cfilter条件的怪兽、破坏原因同时包含REASON_DESTROY和REASON_EFFECT
function c46668237.condition(e,tp,eg,ep,ev,re,r,rp)
	return not eg:IsContains(e:GetHandler()) and eg:IsExists(c46668237.cfilter,1,nil,tp) and bit.band(r,REASON_DESTROY+REASON_EFFECT)==REASON_DESTROY+REASON_EFFECT
end
-- 支付1000基本分的处理：检查是否能支付1000基本分并执行支付
function c46668237.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否能支付1000基本分
	if chk==0 then return Duel.CheckLPCost(tp,1000) end
	-- 执行支付1000基本分
	Duel.PayLPCost(tp,1000)
end
-- 设置特殊召唤目标：判断场上是否有空位且此卡可特殊召唤
function c46668237.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断场上是否有空位用于特殊召唤
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置连锁操作信息：确定将要特殊召唤此卡
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 执行特殊召唤处理：检查此卡是否仍与效果相关，然后将其特殊召唤到场上
function c46668237.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 将此卡特殊召唤到场上
	Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
end
