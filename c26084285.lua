--墓守の監視者
-- 效果：
-- 对方发动效果中含有丢弃对方自己手卡的卡的效果时，可以将这张卡从手卡送去墓地，那张卡的发动与效果无效并且破坏。
function c26084285.initial_effect(c)
	-- 创建效果，描述为“丢弃手牌效果无效并且破坏”，设置效果分类为无效和破坏，效果类型为诱发即时效果，触发事件为连锁发动，生效位置为手卡，属性为伤害步骤可发动，条件函数为condition，代价函数为cost，目标函数为target，效果处理函数为operation
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(26084285,0))  --"丢弃手牌效果无效并且破坏"
	e1:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_CHAINING)
	e1:SetRange(LOCATION_HAND)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
	e1:SetCondition(c26084285.condition)
	e1:SetCost(c26084285.cost)
	e1:SetTarget(c26084285.target)
	e1:SetOperation(c26084285.operation)
	c:RegisterEffect(e1)
end
-- 对方发动效果中含有丢弃对方自己手卡的卡的效果时，可以将这张卡从手卡送去墓地，那张卡的发动与效果无效并且破坏。
function c26084285.condition(e,tp,eg,ep,ev,re,r,rp)
	if ep==tp or (not re:IsHasType(EFFECT_TYPE_ACTIVATE) and not re:IsActiveType(TYPE_MONSTER))
		-- 对方发动效果中含有丢弃对方自己手卡的卡的效果时，可以将这张卡从手卡送去墓地，那张卡的发动与效果无效并且破坏。
		or (not Duel.IsChainNegatable(ev)) then return false end
	-- 检索当前连锁中是否包含丢弃手牌效果的信息
	local ex,tg,tc,p=Duel.GetOperationInfo(ev,CATEGORY_HANDES)
	return ex and (p==ep or p==PLAYER_ALL)
end
-- 将此卡送入墓地作为发动代价
function c26084285.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToGraveAsCost() end
	-- 将此卡送入墓地作为发动代价
	Duel.SendtoGrave(e:GetHandler(),REASON_COST)
end
-- 设置连锁处理信息，包括使发动无效和破坏目标怪兽
function c26084285.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置连锁处理信息，使发动无效
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	if re:GetHandler():IsDestructable() and re:GetHandler():IsRelateToEffect(re) then
		-- 设置连锁处理信息，破坏目标怪兽
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
	end
end
-- 执行效果处理，使连锁发动无效并破坏目标怪兽
function c26084285.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 使连锁发动无效并且目标怪兽与效果相关时进行破坏
	if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) then
		-- 破坏目标怪兽
		Duel.Destroy(eg,REASON_EFFECT)
	end
end
