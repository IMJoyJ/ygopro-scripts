--威風堂々
-- 效果：
-- 战斗阶段中才能发动。对方发动的效果怪兽的效果无效并破坏。
function c56532632.initial_effect(c)
	-- 战斗阶段中才能发动。对方发动的效果怪兽的效果无效并破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_CHAINING)
	e1:SetCondition(c56532632.condition)
	e1:SetTarget(c56532632.target)
	e1:SetOperation(c56532632.activate)
	c:RegisterEffect(e1)
end
-- 检查发动条件是否满足：处于战斗阶段、对方发动效果怪兽的效果且该连锁的发动可以被无效
function c56532632.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前的阶段
	local ph=Duel.GetCurrentPhase()
	return ep~=tp and ph>PHASE_MAIN1 and ph<PHASE_MAIN2
		-- 且发动效果的卡片是怪兽卡，并且该连锁的发动可以被无效
		and re:IsActiveType(TYPE_MONSTER) and Duel.IsChainNegatable(ev)
end
-- 设置效果发动的目标与操作信息
function c56532632.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置操作信息：使该连锁的发动无效
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	if re:GetHandler():IsDestructable() and re:GetHandler():IsRelateToEffect(re) then
		-- 设置操作信息：如果发动效果的卡片可被破坏且与该效果有关联，则将其破坏
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
	end
end
-- 执行效果处理：使发动无效并破坏
function c56532632.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 如果成功使该连锁的发动无效，且发动效果的卡片与该效果有关联
	if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) then
		-- 将发动效果的卡片破坏
		Duel.Destroy(eg,REASON_EFFECT)
	end
end
