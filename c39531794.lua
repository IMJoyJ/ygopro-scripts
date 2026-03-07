--ブレインハザード
-- 效果：
-- ①：以除外的1只自己的念动力族怪兽为对象才能把这张卡发动。那只怪兽特殊召唤。这张卡从场上离开时那只怪兽破坏。那只怪兽破坏时这张卡破坏。
function c39531794.initial_effect(c)
	-- 效果原文：①：以除外的1只自己的念动力族怪兽为对象才能把这张卡发动。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMING_END_PHASE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetTarget(c39531794.target)
	e1:SetOperation(c39531794.operation)
	c:RegisterEffect(e1)
	-- 效果原文：这张卡从场上离开时那只怪兽破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_SINGLE)
	e2:SetCode(EVENT_LEAVE_FIELD)
	e2:SetOperation(c39531794.desop)
	c:RegisterEffect(e2)
	-- 效果原文：那只怪兽破坏时这张卡破坏。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCode(EVENT_LEAVE_FIELD)
	e3:SetCondition(c39531794.descon2)
	e3:SetOperation(c39531794.desop2)
	c:RegisterEffect(e3)
end
-- 检索满足条件的念动力族怪兽（正面表示、可特殊召唤）
function c39531794.filter(c,e,tp)
	return c:IsFaceup() and c:IsRace(RACE_PSYCHO) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 判断是否满足发动条件（是否有除外的念动力族怪兽可特殊召唤）
function c39531794.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_REMOVED) and chkc:IsControler(tp) and c39531794.filter(chkc,e,tp) end
	-- 判断场上是否有空位可特殊召唤
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 判断是否有除外的念动力族怪兽可特殊召唤
		and Duel.IsExistingTarget(c39531794.filter,tp,LOCATION_REMOVED,0,1,nil,e,tp) end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择满足条件的除外怪兽作为对象
	local g=Duel.SelectTarget(tp,c39531794.filter,tp,LOCATION_REMOVED,0,1,1,nil,e,tp)
	-- 设置操作信息为特殊召唤
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 处理特殊召唤效果
function c39531794.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前效果的目标怪兽
	local tc=Duel.GetFirstTarget()
	if c:IsRelateToEffect(e) and tc:IsRelateToEffect(e) then
		-- 将目标怪兽特殊召唤到场上
		if Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)==0 then return end
		c:SetCardTarget(tc)
	end
end
-- 处理卡离开场上的效果
function c39531794.desop(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetHandler():GetFirstCardTarget()
	if tc and tc:IsLocation(LOCATION_MZONE) then
		-- 将目标怪兽破坏
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
-- 判断是否满足破坏条件
function c39531794.descon2(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetHandler():GetFirstCardTarget()
	return tc and eg:IsContains(tc) and tc:IsReason(REASON_DESTROY)
end
-- 处理卡被破坏的效果
function c39531794.desop2(e,tp,eg,ep,ev,re,r,rp)
	-- 将自身破坏
	Duel.Destroy(e:GetHandler(),REASON_EFFECT)
end
