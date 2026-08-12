--血の刻印
-- 效果：
-- 选择自己场上1只名称中含有「恶魔」字样的怪兽发动。所选择的怪兽在准备阶段支付基本分时，对方也要支付相同的基本分。当这张卡离场时，所选择的怪兽被破坏；当所选择的怪兽离场时，这张卡被破坏。
function c94463200.initial_effect(c)
	-- 选择自己场上1只名称中含有「恶魔」字样的怪兽发动。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(TIMING_STANDBY_PHASE,0)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetTarget(c94463200.target)
	e1:SetOperation(c94463200.operation)
	c:RegisterEffect(e1)
	-- 所选择的怪兽在准备阶段支付基本分时，对方也要支付相同的基本分。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCode(EVENT_PAY_LPCOST)
	e2:SetCondition(c94463200.lpcon)
	e2:SetOperation(c94463200.lpop)
	c:RegisterEffect(e2)
	-- 当所选择的怪兽离场时，这张卡被破坏。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCode(EVENT_LEAVE_FIELD)
	e3:SetCondition(c94463200.descon)
	e3:SetOperation(c94463200.desop)
	c:RegisterEffect(e3)
	-- 当这张卡离场时，所选择的怪兽被破坏；
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e4:SetCode(EVENT_LEAVE_FIELD)
	e4:SetOperation(c94463200.desop2)
	c:RegisterEffect(e4)
end
-- 过滤自己场上表侧表示的「恶魔」怪兽
function c94463200.filter(c)
	return c:IsFaceup() and c:IsSetCard(0x45)
end
-- 发动时的对象选择与合法性检查
function c94463200.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c94463200.filter(chkc) end
	-- 检查自己场上是否存在可以作为对象的表侧表示「恶魔」怪兽
	if chk==0 then return Duel.IsExistingTarget(c94463200.filter,tp,LOCATION_MZONE,0,1,nil) end
	-- 提示玩家选择表侧表示的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择自己场上1只表侧表示的「恶魔」怪兽作为效果对象
	Duel.SelectTarget(tp,c94463200.filter,tp,LOCATION_MZONE,0,1,1,nil)
end
-- 效果处理时，使这张卡与目标怪兽建立对象连接关系
function c94463200.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取发动时选择的对象怪兽
	local tc=Duel.GetFirstTarget()
	if c:IsRelateToEffect(e) and tc:IsFaceup() and tc:IsRelateToEffect(e) then
		c:SetCardTarget(tc)
	end
end
-- 判定是否在准备阶段且由对象怪兽的控制者支付基本分
function c94463200.lpcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判定当前阶段是否为准备阶段，且支付基本分的玩家是自己
	return Duel.GetCurrentPhase()==PHASE_STANDBY and ep==tp
		and re:GetHandler()==e:GetHandler():GetFirstCardTarget()
end
-- 对方支付相同数值基本分的效果处理
function c94463200.lpop(e,tp,eg,ep,ev,re,r,rp)
	-- 让对方玩家支付与我方支付的相同数值的基本分
	Duel.PayLPCost(1-ep,ev)
end
-- 检查离场的卡是否为被破坏的对象怪兽，以决定是否破坏这张卡
function c94463200.descon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsStatus(STATUS_DESTROY_CONFIRMED) then return false end
	local tc=c:GetFirstCardTarget()
	return tc and eg:IsContains(tc) and tc:IsReason(REASON_DESTROY)
end
-- 破坏这张卡的效果处理
function c94463200.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 因效果破坏这张卡自身
	Duel.Destroy(e:GetHandler(),REASON_EFFECT)
end
-- 这张卡离场时，破坏对象怪兽的效果处理
function c94463200.desop2(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetHandler():GetFirstCardTarget()
	if tc and tc:IsLocation(LOCATION_MZONE) then
		-- 因效果破坏作为对象的怪兽
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
