--鋼核の輝き
-- 效果：
-- 把手卡1张「核成兽的钢核」给对方观看发动。对方的魔法·陷阱卡的发动无效并破坏。
function c34545235.initial_effect(c)
	-- 将该卡上记载的卡名「核成兽的钢核」（卡号36623431）加入代码列表，以便处理“这张卡上记载着另一张卡名”的相关效果。
	aux.AddCodeList(c,36623431)
	-- 把手卡1张「核成兽的钢核」给对方观看发动。对方的魔法·陷阱卡的发动无效并破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_CHAINING)
	e1:SetCondition(c34545235.condition)
	e1:SetCost(c34545235.cost)
	e1:SetTarget(c34545235.target)
	e1:SetOperation(c34545235.activate)
	c:RegisterEffect(e1)
end
-- 定义发动条件函数：仅当对方发动魔法·陷阱卡，且该连锁可以被无效时才满足发动条件。
function c34545235.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 具体条件：连锁的发动者不是自己（ep~=tp）；被连锁的效果是魔法·陷阱卡的发动（EFFECT_TYPE_ACTIVATE）；且该连锁可以被无效。
	return ep~=tp and re:IsHasType(EFFECT_TYPE_ACTIVATE) and Duel.IsChainNegatable(ev)
end
-- 定义手卡筛选函数：选择卡号为36623431（「核成兽的钢核」）且当前未公开表示的手卡卡。
function c34545235.cfilter(c)
	return c:IsCode(36623431) and not c:IsPublic()
end
-- 定义发动COST：从手卡选择1张「核成兽的钢核」给对方确认，然后洗切手卡；若没有满足条件的卡则不能发动。
function c34545235.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- COST的合法性检查：确认手卡中是否存在至少1张符合条件的「核成兽的钢核」。
	if chk==0 then return Duel.IsExistingMatchingCard(c34545235.cfilter,tp,LOCATION_HAND,0,1,nil) end
	-- 弹出选择提示，提示玩家选择1张卡给对方确认。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)  --"请选择给对方确认的卡"
	-- 玩家从手卡中选择1张符合条件的「核成兽的钢核」（当前未公开的）作为COST。
	local g=Duel.SelectMatchingCard(tp,c34545235.cfilter,tp,LOCATION_HAND,0,1,1,nil)
	-- 将选择的卡展示给对方玩家确认。
	Duel.ConfirmCards(1-tp,g)
	-- 洗切手卡，隐藏刚才选择过的卡的位置信息，防止泄露手卡排序。
	Duel.ShuffleHand(tp)
end
-- 定义效果发动时的目标/操作信息设置函数：登记“无效发动”类别；若对方发动的卡可被破坏且仍与效果关联，再登记“破坏”类别。
function c34545235.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置操作信息：效果类别为“无效发动”，对象为对方发动的卡（eg），数量为1。
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	if re:GetHandler():IsDestructable() and re:GetHandler():IsRelateToEffect(re) then
		-- 设置操作信息：效果类别为“破坏”，对象为对方发动的卡（eg），数量为1（仅当该卡可破坏且与效果关联时调用）。
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
	end
end
-- 定义效果处理函数：无效对方魔法·陷阱卡的发动，成功后将该卡破坏。
function c34545235.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 先无效对方卡片的发动；若无效成功且那张卡仍与连锁效果关联，则继续进行破坏处理。
	if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) then
		-- 以效果原因破坏被无效的那张对方的魔法·陷阱卡。
		Duel.Destroy(eg,REASON_EFFECT)
	end
end
