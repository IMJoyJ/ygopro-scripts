--破邪の刻印
-- 效果：
-- 对方的准备阶段时只有1次，选择场上表侧表示存在的1张卡。选择的卡的效果在那个回合中无效。这张卡的控制者在每次自己的准备阶段支付500基本分。或者不支付500基本分让这张卡破坏。
function c17874674.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- 对方的准备阶段时只有1次，选择场上表侧表示存在的1张卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(17874674,0))  --"效果无效"
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e2:SetRange(LOCATION_SZONE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCountLimit(1)
	e2:SetCondition(c17874674.condition)
	e2:SetTarget(c17874674.target)
	e2:SetOperation(c17874674.operation)
	c:RegisterEffect(e2)
	-- 选择的卡的效果在那个回合中无效。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e3:SetCode(EVENT_TURN_END)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCountLimit(1)
	e3:SetCondition(c17874674.condition)
	e3:SetOperation(c17874674.ctarget)
	c:RegisterEffect(e3)
	-- 这张卡的控制者在每次自己的准备阶段支付500基本分。或者不支付500基本分让这张卡破坏。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e4:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e4:SetRange(LOCATION_SZONE)
	e4:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e4:SetCountLimit(1)
	e4:SetCondition(c17874674.costcon)
	e4:SetOperation(c17874674.costop)
	c:RegisterEffect(e4)
	-- 选择的卡的效果在那个回合中无效。
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_TARGET)
	e5:SetCode(EFFECT_DISABLE)
	e5:SetRange(LOCATION_SZONE)
	c:RegisterEffect(e5)
	-- 选择的卡的效果在那个回合中无效。
	local e6=Effect.CreateEffect(c)
	e6:SetType(EFFECT_TYPE_TARGET)
	e6:SetCode(EFFECT_DISABLE_EFFECT)
	e6:SetRange(LOCATION_SZONE)
	c:RegisterEffect(e6)
end
-- 效果触发条件：当前回合玩家不是这张卡的控制者，即仅在对方的准备阶段才能发动。
function c17874674.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前回合玩家不等于控制者tp，返回真表示处于对方回合。
	return Duel.GetTurnPlayer()~=tp
end
-- 效果发动时的取对象处理：从双方场上表侧表示且可被无效化的卡中选择1张作为对象；并给出选择提示。
function c17874674.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	-- 连锁处理中若需要验证已选对象，则检查该对象是否在场上表侧表示且满足可被无效化的条件。
	if chkc then return chkc:IsOnField() and aux.NegateAnyFilter(chkc) end
	if chk==0 then return true end
	-- 向控制者显示“请选择要无效的卡”的提示，准备进行对象选择。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISABLE)  --"请选择要无效的卡"
	-- 从双方场上表侧表示存在的卡中，选择1张可被无效化的卡作为本效果的取对象。
	Duel.SelectTarget(tp,aux.NegateAnyFilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
end
-- 效果处理时，若对象仍合法且与效果关联，则将该对象设置为本卡的永续对象，以便后续持续对该对象适用无效化效果。
function c17874674.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取本效果发动时选择的对象卡。
	local tc=Duel.GetFirstTarget()
	if tc and ((tc:IsFaceup() and not tc:IsDisabled()) or tc:IsType(TYPE_TRAPMONSTER)) and tc:IsRelateToEffect(e) then
		c:SetCardTarget(tc)
	end
end
-- 在回合结束时，若存在永续对象，则取消该永续对象，使无效化效果不再持续，从而体现“那个回合中”无效。
function c17874674.ctarget(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetHandler():GetFirstCardTarget()
	if tc then e:GetHandler():CancelCardTarget(tc) end
end
-- 维持代价效果的触发条件：当前回合玩家是这张卡的控制者，即在自己的准备阶段才进行处理。
function c17874674.costcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前回合玩家等于控制者tp，返回真表示处于自己的准备阶段。
	return Duel.GetTurnPlayer()==tp
end
-- 自己的准备阶段时的维持处理：若可以支付500基本分且玩家选择支付，则支付500；否则破坏此卡。
function c17874674.costop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查控制者是否有至少500基本分，并弹出是否支付500基本分维持此卡的选项。
	if Duel.CheckLPCost(tp,500) and Duel.SelectYesNo(tp,aux.Stringid(17874674,1)) then  --"是否支付500基本分维持「破邪之刻印」？"
		-- 控制者支付500基本分，作为维持此卡的费用。
		Duel.PayLPCost(tp,500)
	else
		-- 当不支付500基本分时，以规则代价方式破坏此卡。
		Duel.Destroy(e:GetHandler(),REASON_COST)
	end
end
