--ウィキッド・リボーン
-- 效果：
-- 支付800基本分，选择自己墓地存在的1只同调怪兽发动。选择的怪兽表侧攻击表示特殊召唤。这个效果特殊召唤的怪兽的效果无效化，这个回合不能攻击宣言。这张卡不在场上存在时，那只怪兽破坏。那只怪兽破坏时这张卡破坏。
function c23440062.initial_effect(c)
	-- 支付800基本分，选择自己墓地存在的1只同调怪兽发动。选择的怪兽表侧攻击表示特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMING_END_PHASE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCost(c23440062.cost)
	e1:SetTarget(c23440062.target)
	e1:SetOperation(c23440062.operation)
	c:RegisterEffect(e1)
	-- 这张卡不在场上存在时，那只怪兽破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_SINGLE)
	e2:SetCode(EVENT_LEAVE_FIELD)
	e2:SetOperation(c23440062.desop)
	c:RegisterEffect(e2)
	-- 那只怪兽破坏时这张卡破坏。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCode(EVENT_LEAVE_FIELD)
	e3:SetCondition(c23440062.descon2)
	e3:SetOperation(c23440062.desop2)
	c:RegisterEffect(e3)
	-- 这个效果特殊召唤的怪兽的效果无效化
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_TARGET)
	e4:SetCode(EFFECT_DISABLE)
	e4:SetRange(LOCATION_SZONE)
	c:RegisterEffect(e4)
end
-- 检查玩家是否能支付800基本分
function c23440062.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家是否能支付800基本分
	if chk==0 then return Duel.CheckLPCost(tp,800) end
	-- 让玩家支付800基本分
	Duel.PayLPCost(tp,800)
end
-- 过滤满足条件的同调怪兽
function c23440062.filter(c,e,tp)
	return c:IsType(TYPE_SYNCHRO) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_ATTACK)
end
-- 设置效果目标为满足条件的墓地同调怪兽
function c23440062.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c23440062.filter(chkc,e,tp) end
	-- 检查玩家场上是否有足够的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查玩家墓地是否存在满足条件的同调怪兽
		and Duel.IsExistingTarget(c23440062.filter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择满足条件的墓地同调怪兽作为效果目标
	local g=Duel.SelectTarget(tp,c23440062.filter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置连锁操作信息为特殊召唤
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 处理特殊召唤效果
function c23440062.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前效果的目标怪兽
	local tc=Duel.GetFirstTarget()
	-- 判断效果是否有效且目标怪兽是否存在并进行特殊召唤
	if c:IsRelateToEffect(e) and tc:IsRelateToEffect(e) and Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP_ATTACK) then
		c:SetCardTarget(tc)
		-- 使特殊召唤的怪兽在本回合不能攻击
		local e5=Effect.CreateEffect(c)
		e5:SetType(EFFECT_TYPE_TARGET)
		e5:SetCode(EFFECT_CANNOT_ATTACK)
		e5:SetRange(LOCATION_SZONE)
		e5:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		c:RegisterEffect(e5)
	end
	-- 完成特殊召唤流程
	Duel.SpecialSummonComplete()
end
-- 处理卡片离场时的破坏效果
function c23440062.desop(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetHandler():GetFirstCardTarget()
	if tc and tc:IsLocation(LOCATION_MZONE) then
		-- 破坏目标怪兽
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
-- 判断是否为因破坏而离场
function c23440062.descon2(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetHandler():GetFirstCardTarget()
	return tc and eg:IsContains(tc) and tc:IsReason(REASON_DESTROY)
end
-- 处理卡片被破坏的效果
function c23440062.desop2(e,tp,eg,ep,ev,re,r,rp)
	-- 破坏自身
	Duel.Destroy(e:GetHandler(),REASON_EFFECT)
end
