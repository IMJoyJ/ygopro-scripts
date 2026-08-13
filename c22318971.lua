--一角獣の使い魔
-- 效果：
-- 表侧守备表示存在的这张卡被选择作为攻击对象时，可以把这张卡以外的自己场上存在的1只怪兽从游戏中除外，把这张卡从游戏中除外。那个时候的攻击怪兽必须作出攻击。这个效果除外的这张卡在下次的自己的准备阶段时回到场上。
function c22318971.initial_effect(c)
	-- 表侧守备表示存在的这张卡被选择作为攻击对象时，可以把这张卡以外的自己场上存在的1只怪兽从游戏中除外，把这张卡从游戏中除外。那个时候的攻击怪兽必须作出攻击。这个效果除外的这张卡在下次的自己的准备阶段时回到场上。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(22318971,0))  --"除外"
	e1:SetCategory(CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_BE_BATTLE_TARGET)
	e1:SetCondition(c22318971.condition)
	e1:SetCost(c22318971.cost)
	e1:SetTarget(c22318971.target)
	e1:SetOperation(c22318971.operation)
	c:RegisterEffect(e1)
end
-- 本效果的发动条件：被选择为攻击对象时，这张卡自身处于表侧守备表示。
function c22318971.condition(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPosition(POS_FACEUP_DEFENSE)
end
-- 作为发动代价，从自己场上选择这张卡以外的1只可除外的怪兽并除外；效果处理时才把这张卡自己除外。
function c22318971.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否存在这张卡以外的、可以被除外的怪兽，以决定能否支付代价。
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsAbleToRemove,tp,LOCATION_MZONE,0,1,e:GetHandler()) end
	-- 弹出选择提示，让玩家选择要除外的怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 从自己场上选择1张这张卡以外的可除外怪兽作为代价对象。
	local g=Duel.SelectMatchingCard(tp,Card.IsAbleToRemove,tp,LOCATION_MZONE,0,1,1,e:GetHandler())
	-- 以表侧表示将选中的怪兽除外，作为发动代价。
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
-- 效果发动时：确认这张卡可被除外，将攻击怪兽设为效果对象，并告知系统本连锁要除外这张卡。
function c22318971.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToRemove() end
	-- 将当前攻击的怪兽记录为对象，以便后续让它必须攻击。
	Duel.SetTargetCard(Duel.GetAttacker())
	-- 设置操作信息，标明本连锁会把这张卡除外（供效果发动检测和提示使用）。
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,e:GetHandler(),1,0,0)
end
-- 效果处理：若这张卡仍与效果关联且表侧表示，则将其暂时除外，并注册准备阶段回场的处理，同时给当时的攻击怪兽附加必须攻击效果。
function c22318971.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 判断这张卡是否仍可被本效果处理（未离场/仍关联）且为表侧表示，并将其以表侧表示、暂时除外的方式除外；若除外成功则继续后续处理。
	if c:IsRelateToEffect(e) and c:IsFaceup() and Duel.Remove(c,0,REASON_EFFECT+REASON_TEMPORARY)~=0 then
		-- 那个时候的攻击怪兽必须作出攻击。这个效果除外的这张卡在下次的自己的准备阶段时回到场上。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_PHASE+PHASE_STANDBY)
		e1:SetReset(RESET_PHASE+PHASE_STANDBY+RESET_SELF_TURN)
		e1:SetCountLimit(1)
		e1:SetCondition(c22318971.retcon)
		e1:SetOperation(c22318971.retop)
		-- 将准备阶段回场的效果注册给当前回合玩家（持有者），等待下次自己的准备阶段触发。
		Duel.RegisterEffect(e1,tp)
		-- 取出之前锁定的攻击怪兽，用于给它附加必须攻击效果。
		local ac=Duel.GetFirstTarget()
		if ac:IsRelateToEffect(e) and ac:IsFaceup() then
			-- 那个时候的攻击怪兽必须作出攻击。
			local e2=Effect.CreateEffect(c)
			e2:SetType(EFFECT_TYPE_SINGLE)
			e2:SetCode(EFFECT_MUST_ATTACK)
			e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			ac:RegisterEffect(e2)
		end
	end
end
-- 准备阶段回场效果的触发条件：当前是这张卡持有者（即发动者）的准备阶段。
function c22318971.retcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前回合玩家是否为这张卡的持有者/发动者，确保是“下次自己的准备阶段”。
	return Duel.GetTurnPlayer()==tp
end
-- 回场效果的处理：将暂时除外的这张卡返回到场上。
function c22318971.retop(e,tp,eg,ep,ev,re,r,rp)
	-- 把暂除外状态的这张卡（效果的所有者）返回到其持有者的场上。
	Duel.ReturnToField(e:GetOwner())
end
