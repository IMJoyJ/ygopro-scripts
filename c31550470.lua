--闇次元の解放
-- 效果：
-- ①：以除外的1只自己的暗属性怪兽为对象才能把这张卡发动。那只怪兽特殊召唤。这张卡从场上离开时那只怪兽破坏并除外。那只怪兽破坏时这张卡破坏。
function c31550470.initial_effect(c)
	-- ①：以除外的1只自己的暗属性怪兽为对象才能把这张卡发动。那只怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMING_END_PHASE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetTarget(c31550470.target)
	e1:SetOperation(c31550470.operation)
	c:RegisterEffect(e1)
	-- 这张卡从场上离开时那只怪兽破坏并除外。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_SINGLE)
	e2:SetCode(EVENT_LEAVE_FIELD)
	e2:SetOperation(c31550470.desop)
	c:RegisterEffect(e2)
	-- 那只怪兽破坏时这张卡破坏。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCode(EVENT_LEAVE_FIELD)
	e3:SetCondition(c31550470.descon2)
	e3:SetOperation(c31550470.desop2)
	c:RegisterEffect(e3)
end
-- 过滤满足条件的除外的暗属性怪兽
function c31550470.filter(c,e,tp)
	return c:IsFaceup() and c:IsAttribute(ATTRIBUTE_DARK) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 设置效果目标为除外的1只自己的暗属性怪兽
function c31550470.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_REMOVED) and chkc:IsControler(tp) and c31550470.filter(chkc,e,tp) end
	-- 判断场上是否有足够的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 判断是否存有满足条件的除外怪兽
		and Duel.IsExistingTarget(c31550470.filter,tp,LOCATION_REMOVED,0,1,nil,e,tp) end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择满足条件的除外怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c31550470.filter,tp,LOCATION_REMOVED,0,1,1,nil,e,tp)
	-- 设置效果操作信息为特殊召唤
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 处理效果的发动，将目标怪兽特殊召唤
function c31550470.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取效果的目标怪兽
	local tc=Duel.GetFirstTarget()
	if c:IsRelateToEffect(e) and tc:IsRelateToEffect(e)
		-- 执行特殊召唤步骤
		and Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP) then
		c:SetCardTarget(tc)
		e:SetLabelObject(tc)
		c:CreateRelation(tc,RESET_EVENT+RESETS_STANDARD)
		tc:CreateRelation(c,RESET_EVENT+RESETS_STANDARD)
	end
	-- 完成特殊召唤流程
	Duel.SpecialSummonComplete()
end
-- 当此卡离开场时，破坏并除外特殊召唤的怪兽
function c31550470.desop(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetHandler():GetFirstCardTarget()
	if tc and tc:IsLocation(LOCATION_MZONE) then
		-- 将目标怪兽破坏并除外
		Duel.Destroy(tc,REASON_EFFECT,LOCATION_REMOVED)
	end
end
-- 判断目标怪兽是否因破坏而离开场
function c31550470.descon2(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetHandler():GetFirstCardTarget()
	return tc and eg:IsContains(tc) and tc:IsReason(REASON_DESTROY)
end
-- 当目标怪兽被破坏时，破坏此卡
function c31550470.desop2(e,tp,eg,ep,ev,re,r,rp)
	-- 破坏此卡
	Duel.Destroy(e:GetHandler(),REASON_EFFECT)
end
