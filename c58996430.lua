--ライトロード・ビースト ウォルフ
-- 效果：
-- 这张卡不能通常召唤，用卡的效果才能特殊召唤。
-- ①：这张卡从卡组送去墓地的场合发动。这张卡特殊召唤。
function c58996430.initial_effect(c)
	-- ①：这张卡从卡组送去墓地的场合发动。这张卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetDescription(aux.Stringid(58996430,0))  --"特殊召唤"
	e1:SetCode(EVENT_TO_GRAVE)
	e1:SetCondition(c58996430.condtion)
	e1:SetTarget(c58996430.target)
	e1:SetOperation(c58996430.operation)
	c:RegisterEffect(e1)
	-- 这张卡不能通常召唤，用卡的效果才能特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e2:SetCode(EFFECT_SPSUMMON_CONDITION)
	e2:SetValue(c58996430.splimit)
	c:RegisterEffect(e2)
end
-- 定义特殊召唤限制，规定只能通过卡的效果（EFFECT_TYPE_ACTIONS）来特殊召唤。
function c58996430.splimit(e,se,sp,st)
	return se:IsHasType(EFFECT_TYPE_ACTIONS)
end
-- 判断触发条件，确认这张卡是否是从卡组送去墓地。
function c58996430.condtion(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousLocation(LOCATION_DECK)
end
-- 效果发动的目标处理，作为必发效果直接确认发动，并声明特殊召唤的操作信息。
function c58996430.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置连锁的操作信息，表明此效果将特殊召唤自身。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 效果处理，若这张卡在墓地且与效果存在关联，则将其特殊召唤。
function c58996430.operation(e,tp,eg,ep,ev,re,r,rp)
	if e:GetHandler():IsRelateToEffect(e) then
		-- 将这张卡以表侧表示特殊召唤到当前玩家的场上。
		Duel.SpecialSummon(e:GetHandler(),0,tp,tp,false,false,POS_FACEUP)
	end
end
