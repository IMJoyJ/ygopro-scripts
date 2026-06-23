--化石岩の解放
-- 效果：
-- 选择1只被除外的自己的岩石族怪兽在自己场上特殊召唤。这张卡从场上离开时，那只怪兽破坏。那只怪兽破坏时这张卡破坏。
function c26956670.initial_effect(c)
	-- 选择1只被除外的自己的岩石族怪兽在自己场上特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMING_END_PHASE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetTarget(c26956670.target)
	e1:SetOperation(c26956670.operation)
	c:RegisterEffect(e1)
	-- 这张卡从场上离开时，那只怪兽破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_SINGLE)
	e2:SetCode(EVENT_LEAVE_FIELD)
	e2:SetOperation(c26956670.desop)
	c:RegisterEffect(e2)
	-- 那只怪兽破坏时这张卡破坏。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCode(EVENT_LEAVE_FIELD)
	e3:SetCondition(c26956670.descon2)
	e3:SetOperation(c26956670.desop2)
	c:RegisterEffect(e3)
end
-- 过滤满足条件的岩石族怪兽（正面表示且可特殊召唤）
function c26956670.filter(c,e,tp)
	return c:IsFaceup() and c:IsRace(RACE_ROCK) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 设置效果目标为除外区的自己岩石族怪兽
function c26956670.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_REMOVED) and chkc:IsControler(tp) and c26956670.filter(chkc,e,tp) end
	-- 判断场上是否有空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 判断除外区是否有满足条件的岩石族怪兽
		and Duel.IsExistingTarget(c26956670.filter,tp,LOCATION_REMOVED,0,1,nil,e,tp) end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择满足条件的除外区岩石族怪兽作为目标
	local g=Duel.SelectTarget(tp,c26956670.filter,tp,LOCATION_REMOVED,0,1,1,nil,e,tp)
	-- 设置操作信息为特殊召唤
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 处理特殊召唤效果
function c26956670.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前效果的目标怪兽
	local tc=Duel.GetFirstTarget()
	if c:IsRelateToEffect(e) and tc:IsRelateToEffect(e) and tc:IsRace(RACE_ROCK)
		-- 执行特殊召唤步骤
		and Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP) then
		c:SetCardTarget(tc)
	end
	-- 完成特殊召唤流程
	Duel.SpecialSummonComplete()
end
-- 当卡片离开场时，若目标怪兽在场上则将其破坏
function c26956670.desop(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetHandler():GetFirstCardTarget()
	if tc and tc:IsLocation(LOCATION_MZONE) then
		-- 将目标怪兽破坏
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
-- 判断目标怪兽是否因破坏而离开场
function c26956670.descon2(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetHandler():GetFirstCardTarget()
	return tc and eg:IsContains(tc) and tc:IsReason(REASON_DESTROY)
end
-- 当目标怪兽因破坏离开场时，将此卡破坏
function c26956670.desop2(e,tp,eg,ep,ev,re,r,rp)
	-- 将此卡破坏
	Duel.Destroy(e:GetHandler(),REASON_EFFECT)
end
