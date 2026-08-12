--アヌビスの裁き
-- 效果：
-- 丢弃1张手卡。对方控制的持有「把场上的魔法·陷阱卡破坏」效果的魔法卡的发动和效果无效并破坏。那之后，可以把对方场上1只表侧表示的怪兽破坏，给与对方玩家那只怪兽的攻击力数值的伤害。
function c55256016.initial_effect(c)
	-- 丢弃1张手卡。对方控制的持有「把场上的魔法·陷阱卡破坏」效果的魔法卡的发动和效果无效并破坏。那之后，可以把对方场上1只表侧表示的怪兽破坏，给与对方玩家那只怪兽的攻击力数值的伤害。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_CHAINING)
	e1:SetCondition(c55256016.condition)
	e1:SetCost(c55256016.cost)
	e1:SetTarget(c55256016.target)
	e1:SetOperation(c55256016.operation)
	c:RegisterEffect(e1)
end
-- 过滤条件：在场上的魔法·陷阱卡
function c55256016.cfilter(c)
	return c:IsOnField() and c:IsType(TYPE_SPELL+TYPE_TRAP)
end
-- 发动条件：对方发动了包含“破坏场上魔法·陷阱卡”效果的魔法卡，且该发动可以被无效
function c55256016.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检查是否为对方发动的效果，且该发动可以被无效
	if tp==ep or not Duel.IsChainNegatable(ev) then return false end
	if not (re:IsActiveType(TYPE_SPELL) and re:IsHasType(EFFECT_TYPE_ACTIVATE)) then return false end
	-- 获取该连锁中关于“破坏”的操作信息
	local ex,tg,tc=Duel.GetOperationInfo(ev,CATEGORY_DESTROY)
	return ex and tg~=nil and tc+tg:FilterCount(c55256016.cfilter,nil)-tg:GetCount()>0
end
-- 代价：丢弃1张手卡
function c55256016.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家是否受到改变丢弃手卡代价效果的影响（如解放之阿里阿德涅）
	if Duel.IsPlayerAffectedByEffect(tp,EFFECT_DISCARD_COST_CHANGE) then return true end
	-- 检查手卡中是否存在至少1张可以丢弃的卡
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,e:GetHandler()) end
	-- 玩家选择并丢弃1张手卡
	Duel.DiscardHand(tp,Card.IsDiscardable,1,1,REASON_COST+REASON_DISCARD)
end
-- 效果的目标：设置无效与破坏的操作信息
function c55256016.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置操作信息：使发动无效
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	if re:GetHandler():IsDestructable() and re:GetHandler():IsRelateToEffect(re) then
		-- 设置操作信息：破坏该魔法卡
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
	end
end
-- 过滤条件：表侧表示的怪兽
function c55256016.desfilter(c)
	return c:IsFaceup()
end
-- 效果处理：无效并破坏该魔法卡，之后可以破坏对方场上1只表侧表示怪兽并给予其攻击力数值的伤害
function c55256016.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 如果成功使发动无效，且该卡在场上存在
	if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) then
		-- 破坏该魔法卡
		Duel.Destroy(eg,REASON_EFFECT)
	end
	-- 获取对方场上所有表侧表示的怪兽
	local dg=Duel.GetMatchingGroup(c55256016.desfilter,tp,0,LOCATION_MZONE,nil)
	-- 如果对方场上有表侧表示怪兽，询问玩家是否选择破坏
	if dg:GetCount()>0 and Duel.SelectYesNo(tp,aux.Stringid(55256016,0)) then  --"是否要选对方场上1只表侧表示的怪兽破坏？"
		-- 提示玩家选择要破坏的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
		local des=dg:Select(tp,1,1,nil)
		-- 显式显示被选择破坏的怪兽
		Duel.HintSelection(des)
		local atk=des:GetFirst():GetAttack()
		-- 中断效果，使后续的破坏和伤害处理与前面的无效破坏不视为同时处理
		Duel.BreakEffect()
		-- 破坏选中的怪兽，如果成功破坏
		if Duel.Destroy(des,REASON_EFFECT)>0 then
			-- 给予对方玩家该怪兽攻击力数值的伤害
			Duel.Damage(1-tp,atk,REASON_EFFECT)
		end
	end
end
