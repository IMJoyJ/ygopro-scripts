--神星なる因子
-- 效果：
-- ①：怪兽的效果·魔法·陷阱卡发动时，把自己场上1只表侧表示的「星骑士」怪兽送去墓地才能发动。那个发动无效并破坏。那之后，自己从卡组抽1张。
function c41510920.initial_effect(c)
	-- 创建效果，设置效果分类为无效、破坏和抽卡，类型为发动，触发时点为连锁发动，条件为c41510920.condition，代价为c41510920.cost，目标为c41510920.target，效果处理为c41510920.activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY+CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_CHAINING)
	e1:SetCondition(c41510920.condition)
	e1:SetCost(c41510920.cost)
	e1:SetTarget(c41510920.target)
	e1:SetOperation(c41510920.activate)
	c:RegisterEffect(e1)
end
-- 效果发动时的条件判断，当发动的是怪兽效果或魔法/陷阱卡且该连锁可以被无效时才能发动
function c41510920.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 发动的是怪兽效果或魔法/陷阱卡且该连锁可以被无效
	return (re:IsActiveType(TYPE_MONSTER) or re:IsHasType(EFFECT_TYPE_ACTIVATE)) and Duel.IsChainNegatable(ev)
end
-- 筛选场上表侧表示的星骑士怪兽的过滤函数
function c41510920.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x9c) and c:IsAbleToGraveAsCost() and not c:IsStatus(STATUS_BATTLE_DESTROYED)
end
-- 效果的发动代价，检查场上是否存在满足条件的星骑士怪兽，若存在则选择一只送去墓地作为代价
function c41510920.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查场上是否存在满足条件的星骑士怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c41510920.cfilter,tp,LOCATION_MZONE,0,1,nil) end
	-- 提示玩家选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 选择满足条件的星骑士怪兽
	local g=Duel.SelectMatchingCard(tp,c41510920.cfilter,tp,LOCATION_MZONE,0,1,1,nil)
	-- 将选中的怪兽送去墓地作为发动代价
	Duel.SendtoGrave(g,REASON_COST)
end
-- 设置效果处理的目标，检查玩家是否可以抽卡，若可以则设置无效、破坏和抽卡的操作信息
function c41510920.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家是否可以抽卡
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1) end
	-- 设置操作信息为使发动无效
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	if re:GetHandler():IsDestructable() and re:GetHandler():IsRelateToEffect(re) then
		-- 设置操作信息为破坏发动的卡
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
		-- 设置操作信息为抽一张卡
		Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
	end
end
-- 效果处理函数，使连锁发动无效，若发动的卡可以被破坏则破坏它，并抽一张卡
function c41510920.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 使连锁发动无效，若无效失败则返回
	if not Duel.NegateActivation(ev) then return end
	-- 若发动的卡与效果相关且可以被破坏，则进行破坏处理
	if re:GetHandler():IsRelateToEffect(re) and Duel.Destroy(eg,REASON_EFFECT)~=0 then
		-- 中断当前效果，使之后的效果处理视为不同时处理
		Duel.BreakEffect()
		-- 让玩家抽一张卡
		Duel.Draw(tp,1,REASON_EFFECT)
	end
end
