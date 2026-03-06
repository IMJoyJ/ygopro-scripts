--リミット・リバース
-- 效果：
-- 从自己墓地选择1只攻击力1000以下的怪兽，攻击表示特殊召唤。那只怪兽变成守备表示时，那只怪兽和这张卡破坏。这张卡从场上离开时，那只怪兽破坏。那只怪兽破坏时这张卡破坏。
function c27551.initial_effect(c)
	-- 从自己墓地选择1只攻击力1000以下的怪兽，攻击表示特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMING_END_PHASE+TIMING_ATTACK)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetTarget(c27551.target)
	e1:SetOperation(c27551.operation)
	c:RegisterEffect(e1)
	-- 这张卡从场上离开时，那只怪兽破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_SINGLE)
	e2:SetCode(EVENT_LEAVE_FIELD)
	e2:SetOperation(c27551.desop)
	c:RegisterEffect(e2)
	-- 那只怪兽破坏时这张卡破坏。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCode(EVENT_LEAVE_FIELD)
	e3:SetCondition(c27551.descon2)
	e3:SetOperation(c27551.desop2)
	c:RegisterEffect(e3)
	-- 那只怪兽变成守备表示时，那只怪兽和这张卡破坏。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e4:SetRange(LOCATION_SZONE)
	e4:SetCode(EVENT_CHANGE_POS)
	e4:SetCondition(c27551.descon3)
	e4:SetOperation(c27551.desop3)
	c:RegisterEffect(e4)
end
-- 满足条件的怪兽攻击力不超过1000且可以特殊召唤
function c27551.filter(c,e,tp)
	return c:IsAttackBelow(1000) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_ATTACK)
end
-- 判断是否满足发动条件，检查场上是否有空位且墓地是否存在符合条件的怪兽
function c27551.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c27551.filter(chkc,e,tp) end
	-- 检查场上是否有空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查墓地是否存在符合条件的怪兽
		and Duel.IsExistingTarget(c27551.filter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择满足条件的怪兽作为特殊召唤目标
	local g=Duel.SelectTarget(tp,c27551.filter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置效果处理信息，确定要特殊召唤的怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 执行效果处理，将目标怪兽特殊召唤
function c27551.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前效果的目标怪兽
	local tc=Duel.GetFirstTarget()
	if c:IsRelateToEffect(e) and tc:IsRelateToEffect(e)
		-- 将目标怪兽以攻击表示特殊召唤
		and Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP_ATTACK) then
		c:SetCardTarget(tc)
	end
	-- 完成特殊召唤流程
	Duel.SpecialSummonComplete()
end
-- 当此卡离开场时，破坏目标怪兽
function c27551.desop(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetHandler():GetFirstCardTarget()
	if tc and tc:IsLocation(LOCATION_MZONE) then
		-- 破坏目标怪兽
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
-- 判断目标怪兽是否因破坏而离场
function c27551.descon2(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetHandler():GetFirstCardTarget()
	return tc and eg:IsContains(tc) and tc:IsReason(REASON_DESTROY)
end
-- 当目标怪兽因破坏离场时，破坏此卡
function c27551.desop2(e,tp,eg,ep,ev,re,r,rp)
	-- 破坏此卡
	Duel.Destroy(e:GetHandler(),REASON_EFFECT)
end
-- 判断目标怪兽是否变为守备表示
function c27551.descon3(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetHandler():GetFirstCardTarget()
	return tc and eg:IsContains(tc) and tc:IsDefensePos()
end
-- 当目标怪兽变为守备表示时，破坏目标怪兽和此卡
function c27551.desop3(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=c:GetFirstCardTarget()
	local g=Group.FromCards(tc,c)
	-- 同时破坏目标怪兽和此卡
	Duel.Destroy(g,REASON_EFFECT)
end
