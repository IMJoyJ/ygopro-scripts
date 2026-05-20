--魔力吸収球体
-- 效果：
-- 对方把魔法卡发动时，可以把自己场上表侧表示存在的这张卡解放，那个发动无效并破坏。这个效果在对方回合才能发动。
function c71466592.initial_effect(c)
	-- 对方把魔法卡发动时，可以把自己场上表侧表示存在的这张卡解放，那个发动无效并破坏。这个效果在对方回合才能发动。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(71466592,0))  --"魔法的发动无效并破坏"
	e1:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EVENT_CHAINING)
	e1:SetCondition(c71466592.condition)
	e1:SetCost(c71466592.cost)
	e1:SetTarget(c71466592.target)
	e1:SetOperation(c71466592.activate)
	c:RegisterEffect(e1)
end
-- 检查发动条件：自身未被战斗确定破坏、由对方玩家发动、是魔法卡的发动、该发动可被无效，且必须在对方回合
function c71466592.condition(e,tp,eg,ep,ev,re,r,rp)
	return not e:GetHandler():IsStatus(STATUS_BATTLE_DESTROYED) and rp==1-tp
		-- 检查发动的卡是否为魔法卡、是否为卡片的发动（非已在场上的魔法卡的效果发动），以及该连锁的发动是否可以被无效
		and re:IsActiveType(TYPE_SPELL) and re:IsHasType(EFFECT_TYPE_ACTIVATE) and Duel.IsChainNegatable(ev)
		-- 检查当前回合玩家是否不是自己，以满足“在对方回合才能发动”的限制
		and Duel.GetTurnPlayer()~=tp
end
-- 检查并执行发动代价：解放自身
function c71466592.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsReleasable() end
	-- 将自身解放作为发动效果的代价
	Duel.Release(e:GetHandler(),REASON_COST)
end
-- 设置效果处理信息：将无效发动和破坏的操作信息注册到连锁中
function c71466592.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置操作信息：使该魔法卡的发动无效
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	if re:GetHandler():IsDestructable() and re:GetHandler():IsRelateToEffect(re) then
		-- 若该卡可被破坏且仍与效果关联，则设置操作信息：破坏该卡
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
	end
end
-- 执行效果：使发动无效并破坏该卡
function c71466592.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 尝试使该连锁的发动无效，若成功且该卡仍与效果关联
	if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) then
		-- 破坏该被无效发动的卡
		Duel.Destroy(eg,REASON_EFFECT)
	end
end
