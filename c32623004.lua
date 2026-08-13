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
-- ②效果的发动条件：确认当前连锁中发动的效果是怪兽效果，且该效果的发动者为「企鹅」怪兽。
function c32623004.spcon(e,tp,eg,ep,ev,re,r,rp)
	return re:IsActiveType(TYPE_MONSTER) and re:GetHandler():IsSetCard(0x5a)
end
-- ②效果的发动目标处理：无选择对象，chk==0时直接判定为可发动，并登记将自身特殊召唤的操作信息。
function c32623004.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 登记本次处理包含特殊召唤：将效果持有者（墓地中的这张卡）特殊召唤，数量为1。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- ②效果的结算：若这张卡仍与效果保持关联（未因故离场或效果被无效），则将其以表侧表示特殊召唤到自己场上。
function c32623004.spop(e,tp,eg,ep,ev,re,r,rp)
	if e:GetHandler():IsRelateToEffect(e) then
		-- 将这张卡以表侧表示特殊召唤到自己场上，不检查召唤条件、不限制苏生限制。
		Duel.SpecialSummon(e:GetHandler(),0,tp,tp,false,false,POS_FACEUP)
	end
end
-- ①效果的适用对象判断：这张卡因「企鹅」卡的效果从场上将被回到手卡时，其去向被重定向为除外区。
function c32623004.rmtg(e,c)
	return c:IsReason(REASON_EFFECT) and c:GetReasonEffect():GetHandler():IsSetCard(0x5a)
end
