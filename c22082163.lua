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
-- 选择墓地中满足“名字带有「亚马逊」且可以攻击表示特殊召唤”的怪兽作为候选对象的过滤条件。
function c22082163.filter(c,e,tp)
	return c:IsSetCard(0x4) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_ATTACK)
end
-- 发动时确认我方怪兽区有空位且墓地存在可特殊召唤的亚马逊怪兽；若满足则选择1只墓地怪兽作为对象。
function c22082163.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c22082163.filter(chkc,e,tp) end
	-- 检查我方主要怪兽区是否存在可用的空格。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查墓地是否存在至少1只满足条件且能成为效果对象的亚马逊怪兽。
		and Duel.IsExistingTarget(c22082163.filter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 向玩家显示“请选择要特殊召唤的卡”的选择提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从自己墓地选择1只名字带有「亚马逊」的怪兽作为效果对象，并将其登记为当前连锁的对象。
	local g=Duel.SelectTarget(tp,c22082163.filter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置本次效果处理中包含特殊召唤1只怪兽的操作信息。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 效果处理时，若这张卡与对象卡仍与效果关联，则将对象怪兽表侧攻击表示特殊召唤，并设为这张卡的永续对象。
function c22082163.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取效果发动时选择的对象怪兽。
	local tc=Duel.GetFirstTarget()
	if c:IsRelateToEffect(e) and tc:IsRelateToEffect(e)
		-- 将对象怪兽以表侧攻击表示进行特殊召唤（作为特殊召唤流程的步骤）。
		and Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP_ATTACK) then
		c:SetCardTarget(tc)
	end
	-- 完成整个特殊召唤流程，正式结算特殊召唤。
	Duel.SpecialSummonComplete()
end
-- 这张卡离场时，若其永续对象怪兽仍在场上，则将该怪兽破坏。
function c22082163.desop(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetHandler():GetFirstCardTarget()
	if tc and tc:IsLocation(LOCATION_MZONE) then
		-- 以效果原因破坏这张卡的永续对象怪兽。
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
-- 当这张卡的永续对象怪兽因被破坏而离场时，触发条件成立。
function c22082163.descon2(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetHandler():GetFirstCardTarget()
	return tc and eg:IsContains(tc) and tc:IsReason(REASON_DESTROY)
end
-- 当对象怪兽被破坏时，将这张卡自身破坏。
function c22082163.desop2(e,tp,eg,ep,ev,re,r,rp)
	-- 以效果原因破坏这张卡（亚马逊的意志）。
	Duel.Destroy(e:GetHandler(),REASON_EFFECT)
end
