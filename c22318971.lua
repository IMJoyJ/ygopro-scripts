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
-- 效果发动的条件：这张卡必须是表侧守备表示
function c22318971.condition(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPosition(POS_FACEUP_DEFENSE)
end
-- 效果的费用：选择1只自己场上存在的可除外的怪兽进行除外
function c22318971.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否满足除外费用的条件
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsAbleToRemove,tp,LOCATION_MZONE,0,1,e:GetHandler()) end
	-- 提示玩家选择要除外的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 选择1只自己场上存在的可除外的怪兽
	local g=Duel.SelectMatchingCard(tp,Card.IsAbleToRemove,tp,LOCATION_MZONE,0,1,1,e:GetHandler())
	-- 将选择的怪兽除外作为费用
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
-- 效果的发动目标：将自身除外
function c22318971.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToRemove() end
	-- 设置连锁处理的目标为攻击怪兽
	Duel.SetTargetCard(Duel.GetAttacker())
	-- 设置效果处理信息为除外
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,e:GetHandler(),1,0,0)
end
-- 效果的处理：将自身除外并设置下次准备阶段返回场上的效果
function c22318971.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 确认自身是否在连锁处理中且处于表侧表示，然后将自身以暂时除外方式除外
	if c:IsRelateToEffect(e) and c:IsFaceup() and Duel.Remove(c,0,REASON_EFFECT+REASON_TEMPORARY)~=0 then
		-- 设置下次准备阶段将除外的卡返回场上的效果
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_PHASE+PHASE_STANDBY)
		e1:SetReset(RESET_PHASE+PHASE_STANDBY+RESET_SELF_TURN)
		e1:SetCountLimit(1)
		e1:SetCondition(c22318971.retcon)
		e1:SetOperation(c22318971.retop)
		-- 将设置的返回效果注册到场上
		Duel.RegisterEffect(e1,tp)
		-- 获取连锁处理的目标怪兽
		local ac=Duel.GetFirstTarget()
		if ac:IsRelateToEffect(e) and ac:IsFaceup() then
			-- 设置攻击怪兽必须进行攻击的效果
			local e2=Effect.CreateEffect(c)
			e2:SetType(EFFECT_TYPE_SINGLE)
			e2:SetCode(EFFECT_MUST_ATTACK)
			e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			ac:RegisterEffect(e2)
		end
	end
end
-- 返回效果的触发条件：轮到自己回合时
function c22318971.retcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前回合玩家是否为效果持有者
	return Duel.GetTurnPlayer()==tp
end
-- 返回效果的处理：将除外的卡返回场上
function c22318971.retop(e,tp,eg,ep,ev,re,r,rp)
	-- 将除外的卡以原表示形式返回场上
	Duel.ReturnToField(e:GetOwner())
end
