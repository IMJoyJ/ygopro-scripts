--否定ペンギン
-- 效果：
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：只要这张卡在怪兽区域存在，「企鹅」卡的效果从场上回到手卡的卡不回到手卡而除外。
-- ②：这张卡在墓地存在，「企鹅」怪兽的效果发动时发动。这张卡特殊召唤。
function c32623004.initial_effect(c)
	-- ②：这张卡在墓地存在，「企鹅」怪兽的效果发动时发动。这张卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(32623004,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_QUICK_F)
	e1:SetCode(EVENT_CHAINING)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e1:SetRange(LOCATION_GRAVE)
	e1:SetCountLimit(1,32623004)
	e1:SetCondition(c32623004.spcon)
	e1:SetTarget(c32623004.sptg)
	e1:SetOperation(c32623004.spop)
	c:RegisterEffect(e1)
	-- ①：只要这张卡在怪兽区域存在，「企鹅」卡的效果从场上回到手卡的卡不回到手卡而除外。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetProperty(EFFECT_FLAG_SET_AVAILABLE+EFFECT_FLAG_IGNORE_IMMUNE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCode(EFFECT_TO_HAND_REDIRECT)
	e2:SetTargetRange(LOCATION_ONFIELD,LOCATION_ONFIELD)
	e2:SetTarget(c32623004.rmtg)
	e2:SetValue(LOCATION_REMOVED)
	c:RegisterEffect(e2)
end
-- 效果发动的条件：对方发动的怪兽卡效果，且该效果的发动者为「企鹅」卡组的怪兽。
function c32623004.spcon(e,tp,eg,ep,ev,re,r,rp)
	return re:IsActiveType(TYPE_MONSTER) and re:GetHandler():IsSetCard(0x5a)
end
-- 效果的发动目标设定：确定将自身特殊召唤。
function c32623004.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置连锁处理信息，表明此效果会将自身特殊召唤。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 效果的发动处理：若自身存在于场上，则进行特殊召唤。
function c32623004.spop(e,tp,eg,ep,ev,re,r,rp)
	if e:GetHandler():IsRelateToEffect(e) then
		-- 将自身以正面表示特殊召唤到自己场上。
		Duel.SpecialSummon(e:GetHandler(),0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 效果适用对象的判定：被效果送入墓地且其效果的发动者为「企鹅」卡组的怪兽。
function c32623004.rmtg(e,c)
	return c:IsReason(REASON_EFFECT) and c:GetReasonEffect():GetHandler():IsSetCard(0x5a)
end
