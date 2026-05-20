--闇より出でし絶望
-- 效果：
-- ①：这张卡被对方的效果从手卡·卡组送去墓地的场合发动。这张卡特殊召唤。
function c71200730.initial_effect(c)
	-- ①：这张卡被对方的效果从手卡·卡组送去墓地的场合发动。这张卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(71200730,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_TO_GRAVE)
	e1:SetCondition(c71200730.spcon)
	e1:SetTarget(c71200730.sptg)
	e1:SetOperation(c71200730.spop)
	c:RegisterEffect(e1)
end
-- 检查这张卡之前的位置是否是手卡或卡组，且是否因对方的效果送去墓地
function c71200730.spcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousLocation(LOCATION_HAND+LOCATION_DECK) and bit.band(r,REASON_EFFECT)~=0 and rp==1-tp
end
-- 特殊召唤效果的发动准备，因为是必发效果，直接通过并设置特殊召唤的操作信息
function c71200730.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置当前连锁的操作信息为将自身特殊召唤1只
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 特殊召唤效果的具体执行，若这张卡仍与效果存在联系，则将其特殊召唤
function c71200730.spop(e,tp,eg,ep,ev,re,r,rp)
	if e:GetHandler():IsRelateToEffect(e) then
		-- 将这张卡以表侧表示特殊召唤到自己的场上
		Duel.SpecialSummon(e:GetHandler(),0,tp,tp,false,false,POS_FACEUP)
	end
end
