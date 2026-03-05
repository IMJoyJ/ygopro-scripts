--影無茶ナイト
-- 效果：
-- 自己对3星怪兽的召唤成功时，这张卡可以从手卡特殊召唤。这张卡不能作为同调素材。
function c19353570.initial_effect(c)
	-- 自己对3星怪兽的召唤成功时，这张卡可以从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(19353570,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetRange(LOCATION_HAND)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetCondition(c19353570.spcon)
	e1:SetTarget(c19353570.sptg)
	e1:SetOperation(c19353570.spop)
	c:RegisterEffect(e1)
	-- 这张卡不能作为同调素材。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_CANNOT_BE_SYNCHRO_MATERIAL)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e2:SetValue(1)
	c:RegisterEffect(e2)
end
-- 效果发动时，检查是否为自己的召唤成功且被召唤的怪兽等级为3。
function c19353570.spcon(e,tp,eg,ep,ev,re,r,rp)
	return rp==tp and eg:GetFirst():IsLevel(3)
end
-- 效果处理时，判断场上是否有足够空间以及自身是否可以特殊召唤。
function c19353570.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断场上是否有空位。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置效果处理信息，表示将特殊召唤这张卡。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 效果发动时，确认自身是否还在场上并执行特殊召唤。
function c19353570.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 将自身以正面表示形式特殊召唤到场上。
	Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
end
