--対峙するG
-- 效果：
-- ①：对方从额外卡组把怪兽特殊召唤时才能发动。这张卡从手卡特殊召唤。这个效果特殊召唤的这张卡不受以这张卡为对象的怪兽的效果影响。
function c15721123.initial_effect(c)
	-- 效果原文内容：①：对方从额外卡组把怪兽特殊召唤时才能发动。这张卡从手卡特殊召唤。这个效果特殊召唤的这张卡不受以这张卡为对象的怪兽的效果影响。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(15721123,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetRange(LOCATION_HAND)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCondition(c15721123.spcon)
	e1:SetTarget(c15721123.sptg)
	e1:SetOperation(c15721123.spop)
	c:RegisterEffect(e1)
end
-- 规则层面作用：判断怪兽是否从额外卡组召唤
function c15721123.cfilter(c,tp)
	return c:IsSummonPlayer(tp) and c:IsPreviousLocation(LOCATION_EXTRA)
end
-- 规则层面作用：判断是否有对方怪兽从额外卡组特殊召唤
function c15721123.spcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c15721123.cfilter,1,nil,1-tp)
end
-- 规则层面作用：判断是否满足特殊召唤条件
function c15721123.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 规则层面作用：判断场上是否有足够的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 规则层面作用：设置连锁操作信息，表明将要特殊召唤此卡
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 规则层面作用：处理特殊召唤效果并设置免疫效果
function c15721123.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 规则层面作用：执行特殊召唤操作
	if Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)>0 then
		-- 效果原文内容：这个效果特殊召唤的这张卡不受以这张卡为对象的怪兽的效果影响。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE+EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetRange(LOCATION_MZONE)
		e1:SetCode(EFFECT_IMMUNE_EFFECT)
		e1:SetValue(c15721123.efilter)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		c:RegisterEffect(e1)
	end
end
-- 规则层面作用：判断效果是否对自身生效
function c15721123.efilter(e,te)
	if not te:IsActiveType(TYPE_MONSTER) then return false end
	local c=e:GetHandler()
	local ec=te:GetHandler()
	if ec:IsHasCardTarget(c) then return true end
	return te:IsHasType(EFFECT_TYPE_ACTIONS) and te:IsHasProperty(EFFECT_FLAG_CARD_TARGET) and c:IsRelateToEffect(te)
end
