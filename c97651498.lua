--魔轟神ルリー
-- 效果：
-- ①：这张卡从手卡丢弃去墓地的场合发动。这张卡特殊召唤。
function c97651498.initial_effect(c)
	-- ①：这张卡从手卡丢弃去墓地的场合发动。这张卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(97651498,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_TO_GRAVE)
	e1:SetCondition(c97651498.spcon)
	e1:SetTarget(c97651498.sptg)
	e1:SetOperation(c97651498.spop)
	c:RegisterEffect(e1)
end
-- 判断发动条件：这张卡是否是从手卡被丢弃送去墓地
function c97651498.spcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousLocation(LOCATION_HAND) and bit.band(r,REASON_DISCARD)~=0
end
-- 设置效果发动的目标，作为必发效果直接返回true，并设置特殊召唤的操作信息
function c97651498.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置特殊召唤的操作信息，表示将自身特殊召唤
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 效果处理：若自身仍与效果存在联系，则将自身特殊召唤
function c97651498.spop(e,tp,eg,ep,ev,re,r,rp)
	if e:GetHandler():IsRelateToEffect(e) then
		-- 将自身以表侧表示特殊召唤到当前玩家的场上
		Duel.SpecialSummon(e:GetHandler(),0,tp,tp,false,false,POS_FACEUP)
	end
end
