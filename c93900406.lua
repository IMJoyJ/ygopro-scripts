--マタンゴ
-- 效果：
-- 每次的自己准备阶段受到300分的伤害。可以在自己的结束阶段支付500分，把这张卡的控制权转移给对方。
function c93900406.initial_effect(c)
	-- 每次的自己准备阶段受到300分的伤害。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(93900406,0))  --"伤害"
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e1:SetCategory(CATEGORY_DAMAGE)
	e1:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCondition(c93900406.damcon)
	e1:SetTarget(c93900406.damtg)
	e1:SetOperation(c93900406.damop)
	c:RegisterEffect(e1)
	-- 可以在自己的结束阶段支付500分，把这张卡的控制权转移给对方。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(93900406,1))  --"控制权转移"
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCategory(CATEGORY_CONTROL)
	e2:SetCode(EVENT_PHASE+PHASE_END)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetCondition(c93900406.ctlcon)
	e2:SetCost(c93900406.ctlcost)
	e2:SetTarget(c93900406.ctltg)
	e2:SetOperation(c93900406.ctlop)
	c:RegisterEffect(e2)
end
-- 准备阶段伤害效果的发动条件函数
function c93900406.damcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查当前回合玩家是否为自己（即自己的准备阶段）
	return Duel.GetTurnPlayer()==tp
end
-- 准备阶段伤害效果的目标处理函数
function c93900406.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置效果处理信息为给与当前回合玩家300点伤害
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,0,0,tp,300)
end
-- 准备阶段伤害效果的执行函数
function c93900406.damop(e,tp,eg,ep,ev,re,r,rp)
	-- 给与当前回合玩家300点效果伤害
	Duel.Damage(tp,300,REASON_EFFECT)
end
-- 控制权转移效果的发动条件函数
function c93900406.ctlcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查当前回合玩家是否为自己（即自己的结束阶段）
	return Duel.GetTurnPlayer()==tp
end
-- 控制权转移效果的代价（Cost）处理函数
function c93900406.ctlcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动时检查玩家是否能支付500点基本分
	if chk==0 then return Duel.CheckLPCost(tp,500) end
	-- 支付500点基本分作为发动代价
	Duel.PayLPCost(tp,500)
end
-- 控制权转移效果的目标处理函数
function c93900406.ctltg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsControlerCanBeChanged() end
	-- 设置效果处理信息为转移这张卡的控制权
	Duel.SetOperationInfo(0,CATEGORY_CONTROL,e:GetHandler(),1,0,0)
end
-- 控制权转移效果的执行函数
function c93900406.ctlop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and c:IsFaceup() then
		-- 将这张卡的控制权转移给对方
		Duel.GetControl(c,1-tp)
	end
end
