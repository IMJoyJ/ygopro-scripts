--神星なる因子
-- 效果：
-- ①：怪兽的效果·魔法·陷阱卡发动时，把自己场上1只表侧表示的「星骑士」怪兽送去墓地才能发动。那个发动无效并破坏。那之后，自己从卡组抽1张。
function c41510920.initial_effect(c)
	-- ①：怪兽的效果·魔法·陷阱卡发动时，把自己场上1只表侧表示的「星骑士」怪兽送去墓地才能发动。那个发动无效并破坏。那之后，自己从卡组抽1张。
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
-- 定义本卡的发动条件函数，用于判断当前连锁是否满足“怪兽的效果·魔法·陷阱卡发动时”这一发动时机。
function c41510920.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 当前连锁上的效果（re）是怪兽效果（TYPE_MONSTER）或魔法·陷阱卡的发动（EFFECT_TYPE_ACTIVATE），且该连锁可以被无效，则满足发动条件。
	return (re:IsActiveType(TYPE_MONSTER) or re:IsHasType(EFFECT_TYPE_ACTIVATE)) and Duel.IsChainNegatable(ev)
end
-- 定义代价筛选函数：选择自己场上表侧表示、属于「星骑士」字段、可作为代价送去墓地、且不属于战斗破坏确定状态的怪兽。
function c41510920.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x9c) and c:IsAbleToGraveAsCost() and not c:IsStatus(STATUS_BATTLE_DESTROYED)
end
-- 定义代价函数：确认存在可选的「星骑士」怪兽后，由玩家选择1只送去墓地作为发动代价。
function c41510920.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 代价判定阶段（chk==0）时，检查自己场上是否存在至少1只满足条件的表侧表示「星骑士」怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(c41510920.cfilter,tp,LOCATION_MZONE,0,1,nil) end
	-- 向玩家显示“请选择要送去墓地的卡”的选择提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 玩家从自己场上选择1只满足条件的表侧表示「星骑士」怪兽。
	local g=Duel.SelectMatchingCard(tp,c41510920.cfilter,tp,LOCATION_MZONE,0,1,1,nil)
	-- 将选择的怪兽以代价（REASON_COST）方式送去墓地，完成发动所需コスト。
	Duel.SendtoGrave(g,REASON_COST)
end
-- 定义目标函数：确认本卡可以发动并设置无效、破坏、抽卡相关的操作信息。
function c41510920.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 目标判定阶段检查自己是否可以抽1张卡，保证后续抽卡部分能够执行。
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1) end
	-- 设置操作信息：将当前连锁中的对象（eg）标记为将被无效的效果，用于连锁无效相关判定。
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	if re:GetHandler():IsDestructable() and re:GetHandler():IsRelateToEffect(re) then
		-- 当被连锁的效果卡可以破坏且与效果仍有联系时，设置操作信息：将该卡标记为将被破坏的对象。
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
		-- 设置操作信息：本次效果处理中自己会从卡组抽1张卡（对象未知、数量1、目标玩家为tp）。
		Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
	end
end
-- 定义效果处理函数：执行无效对方发动、破坏对应卡，然后抽1张卡。
function c41510920.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 尝试无效当前连锁（ev）；如果无效失败则直接结束处理。
	if not Duel.NegateActivation(ev) then return end
	-- 若被无效的卡的卡片本体仍与效果相关，且成功将其破坏（返回值不为0），则继续后续抽卡处理。
	if re:GetHandler():IsRelateToEffect(re) and Duel.Destroy(eg,REASON_EFFECT)~=0 then
		-- 中断当前效果处理流程，使“破坏”与“抽卡”被视为不同时处理，避免误合并时点而导致星尘龙等卡无法正确对应。
		Duel.BreakEffect()
		-- 效果处理完毕后，自己从卡组抽1张卡（REASON_EFFECT）。
		Duel.Draw(tp,1,REASON_EFFECT)
	end
end
