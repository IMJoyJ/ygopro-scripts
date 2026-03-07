--サイバー・ダイナソー
-- 效果：
-- 对方从手卡特殊召唤怪兽时，可以从手卡特殊召唤这张卡。
function c39439590.initial_effect(c)
	-- 效果原文：对方从手卡特殊召唤怪兽时，可以从手卡特殊召唤这张卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(39439590,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetRange(LOCATION_HAND)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCondition(c39439590.spcon)
	e1:SetTarget(c39439590.sptg)
	e1:SetOperation(c39439590.spop)
	c:RegisterEffect(e1)
end
-- 过滤函数，用于判断被特殊召唤的怪兽是否为对方从手卡召唤
function c39439590.cfilter(c,tp)
	return c:IsSummonPlayer(1-tp) and c:IsPreviousLocation(LOCATION_HAND)
end
-- 效果条件函数，检查是否有对方从手卡特殊召唤的怪兽
function c39439590.spcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c39439590.cfilter,1,nil,tp)
end
-- 效果目标函数，判断是否满足特殊召唤条件
function c39439590.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断玩家场上是否有足够的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置连锁操作信息，声明将要特殊召唤此卡
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 效果处理函数，执行特殊召唤操作
function c39439590.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 将此卡正面表示特殊召唤到场上
	Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
end
