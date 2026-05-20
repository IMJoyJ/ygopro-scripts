--ジョルト・カウンター
-- 效果：
-- 自己场上有名字带有「燃烧拳击手」的怪兽存在的场合才能发动。战斗阶段中发动的效果怪兽的效果·魔法·陷阱卡的发动无效并破坏。
function c8316565.initial_effect(c)
	-- 自己场上有名字带有「燃烧拳击手」的怪兽存在的场合才能发动。战斗阶段中发动的效果怪兽的效果·魔法·陷阱卡的发动无效并破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_CHAINING)
	e1:SetCondition(c8316565.condition)
	e1:SetTarget(c8316565.target)
	e1:SetOperation(c8316565.activate)
	c:RegisterEffect(e1)
end
-- 过滤条件：自己场上表侧表示的「燃烧拳击手」怪兽
function c8316565.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x1084)
end
-- 发动条件：自己场上有「燃烧拳击手」怪兽存在，且在战斗阶段中，有可以被无效的怪兽效果或魔法·陷阱卡的发动
function c8316565.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前的阶段
	local ph=Duel.GetCurrentPhase()
	-- 检查自己场上是否存在表侧表示的「燃烧拳击手」怪兽
	return Duel.IsExistingMatchingCard(c8316565.cfilter,tp,LOCATION_MZONE,0,1,nil)
		and ph>PHASE_MAIN1 and ph<PHASE_MAIN2
		-- 并且发动的效果是怪兽效果或魔法·陷阱卡的发动，且该发动可以被无效
		and (re:IsActiveType(TYPE_MONSTER) or re:IsHasType(EFFECT_TYPE_ACTIVATE)) and Duel.IsChainNegatable(ev)
end
-- 设置发动无效与破坏的操作信息
function c8316565.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置操作信息：使该连锁的发动无效
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	if re:GetHandler():IsDestructable() and re:GetHandler():IsRelateToEffect(re) then
		-- 若发动的卡可被破坏且与效果有关联，则设置操作信息：破坏该卡
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
	end
end
-- 执行发动无效并破坏的效果处理
function c8316565.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 如果成功使该连锁的发动无效，且该卡与效果有关联
	if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) then
		-- 将该卡破坏
		Duel.Destroy(eg,REASON_EFFECT)
	end
end
