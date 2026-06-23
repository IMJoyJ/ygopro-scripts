--破邪の刻印
-- 效果：
-- 对方的准备阶段时只有1次，选择场上表侧表示存在的1张卡。选择的卡的效果在那个回合中无效。这张卡的控制者在每次自己的准备阶段支付500基本分。或者不支付500基本分让这张卡破坏。
function c17874674.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- 对方的准备阶段时只有1次，选择场上表侧表示存在的1张卡。选择的卡的效果在那个回合中无效。
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
	-- 这张卡的控制者在每次自己的准备阶段支付500基本分。或者不支付500基本分让这张卡破坏。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e3:SetCode(EVENT_TURN_END)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCountLimit(1)
	e3:SetCondition(c17874674.condition)
	e3:SetOperation(c17874674.ctarget)
	c:RegisterEffect(e3)
	-- 效果无效
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e4:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e4:SetRange(LOCATION_SZONE)
	e4:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e4:SetCountLimit(1)
	e4:SetCondition(c17874674.costcon)
	e4:SetOperation(c17874674.costop)
	c:RegisterEffect(e4)
	-- 请选择要无效的卡
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_TARGET)
	e5:SetCode(EFFECT_DISABLE)
	e5:SetRange(LOCATION_SZONE)
	c:RegisterEffect(e5)
	-- 是否支付500基本分维持「破邪之刻印」？
	local e6=Effect.CreateEffect(c)
	e6:SetType(EFFECT_TYPE_TARGET)
	e6:SetCode(EFFECT_DISABLE_EFFECT)
	e6:SetRange(LOCATION_SZONE)
	c:RegisterEffect(e6)
end
-- 判断是否为对方回合
function c17874674.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 判断是否为对方回合
	return Duel.GetTurnPlayer()~=tp
end
-- 设置选择目标的过滤条件，确保目标为场上表侧表示且可被无效的卡
function c17874674.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	-- 设置选择目标的过滤条件，确保目标为场上表侧表示且可被无效的卡
	if chkc then return chkc:IsOnField() and aux.NegateAnyFilter(chkc) end
	if chk==0 then return true end
	-- 提示玩家选择要无效的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISABLE)  --"请选择要无效的卡"
	-- 选择场上一张可被无效的卡作为目标
	Duel.SelectTarget(tp,aux.NegateAnyFilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
end
-- 将选中的卡设为当前效果的目标卡
function c17874674.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前连锁中选择的目标卡
	local tc=Duel.GetFirstTarget()
	if tc and ((tc:IsFaceup() and not tc:IsDisabled()) or tc:IsType(TYPE_TRAPMONSTER)) and tc:IsRelateToEffect(e) then
		c:SetCardTarget(tc)
	end
end
-- 取消当前效果的目标卡
function c17874674.ctarget(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetHandler():GetFirstCardTarget()
	if tc then e:GetHandler():CancelCardTarget(tc) end
end
-- 判断是否为己方回合
function c17874674.costcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断是否为己方回合
	return Duel.GetTurnPlayer()==tp
end
-- 处理支付LP或破坏卡片的逻辑
function c17874674.costop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查是否能支付500基本分并询问玩家是否支付
	if Duel.CheckLPCost(tp,500) and Duel.SelectYesNo(tp,aux.Stringid(17874674,1)) then  --"是否支付500基本分维持「破邪之刻印」？"
		-- 支付500基本分
		Duel.PayLPCost(tp,500)
	else
		-- 因未支付费用而破坏此卡
		Duel.Destroy(e:GetHandler(),REASON_COST)
	end
end
