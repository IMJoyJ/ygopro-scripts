--アマゾネスの意地
-- 效果：
-- 从自己墓地选择1只名字带有「亚马逊」的怪兽，攻击表示特殊召唤。这个效果特殊召唤的怪兽不能把表示形式变更，可以攻击的场合必须作出攻击。这张卡不在场上存在时，那只怪兽破坏。那只怪兽破坏时这张卡破坏。
function c22082163.initial_effect(c)
	-- 从自己墓地选择1只名字带有「亚马逊」的怪兽，攻击表示特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMING_END_PHASE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetTarget(c22082163.target)
	e1:SetOperation(c22082163.operation)
	c:RegisterEffect(e1)
	-- 这张卡不在场上存在时，那只怪兽破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_SINGLE)
	e2:SetCode(EVENT_LEAVE_FIELD)
	e2:SetOperation(c22082163.desop)
	c:RegisterEffect(e2)
	-- 那只怪兽破坏时这张卡破坏。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCode(EVENT_LEAVE_FIELD)
	e3:SetCondition(c22082163.descon2)
	e3:SetOperation(c22082163.desop2)
	c:RegisterEffect(e3)
	-- 这个效果特殊召唤的怪兽不能把表示形式变更。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_TARGET)
	e4:SetCode(EFFECT_CANNOT_CHANGE_POSITION)
	e4:SetRange(LOCATION_SZONE)
	c:RegisterEffect(e4)
	-- 可以攻击的场合必须作出攻击。
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_TARGET)
	e5:SetCode(EFFECT_MUST_ATTACK)
	e5:SetRange(LOCATION_SZONE)
	c:RegisterEffect(e5)
end
-- 检索满足条件的卡片组，即名字带有「亚马逊」且能特殊召唤的怪兽。
function c22082163.filter(c,e,tp)
	return c:IsSetCard(0x4) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_ATTACK)
end
-- 判断是否满足发动条件，即场上存在满足条件的怪兽且有空位。
function c22082163.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c22082163.filter(chkc,e,tp) end
	-- 判断场上是否存在满足条件的怪兽。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 判断场上是否存在满足条件的怪兽。
		and Duel.IsExistingTarget(c22082163.filter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 提示玩家选择要特殊召唤的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择满足条件的怪兽作为目标。
	local g=Duel.SelectTarget(tp,c22082163.filter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置操作信息，确定特殊召唤的怪兽。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 执行特殊召唤操作，将目标怪兽特殊召唤到场上。
function c22082163.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前连锁的目标怪兽。
	local tc=Duel.GetFirstTarget()
	if c:IsRelateToEffect(e) and tc:IsRelateToEffect(e)
		-- 将目标怪兽特殊召唤到场上。
		and Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP_ATTACK) then
		c:SetCardTarget(tc)
	end
	-- 完成特殊召唤流程。
	Duel.SpecialSummonComplete()
end
-- 当此卡离开场时，破坏目标怪兽。
function c22082163.desop(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetHandler():GetFirstCardTarget()
	if tc and tc:IsLocation(LOCATION_MZONE) then
		-- 破坏目标怪兽。
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
-- 当目标怪兽被破坏时，破坏此卡。
function c22082163.descon2(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetHandler():GetFirstCardTarget()
	return tc and eg:IsContains(tc) and tc:IsReason(REASON_DESTROY)
end
-- 当此卡被破坏时，破坏此卡。
function c22082163.desop2(e,tp,eg,ep,ev,re,r,rp)
	-- 破坏此卡。
	Duel.Destroy(e:GetHandler(),REASON_EFFECT)
end
