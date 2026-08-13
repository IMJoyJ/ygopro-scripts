--コアキメイル・ガーディアン
-- 效果：
-- 这张卡的控制者在每次自己的结束阶段从手卡把1张「核成兽的钢核」送去墓地或把手卡1只岩石族怪兽给对方观看。或者都不进行让这张卡破坏。效果怪兽的效果发动时，可以把这张卡解放让那个发动无效并破坏。
function c45041488.initial_effect(c)
	-- 记录这张卡卡名中提到的「核成兽的钢核」的卡号36623431，使后续脚本能通过IsCode识别该卡。
	aux.AddCodeList(c,36623431)
	-- 这张卡的控制者在每次自己的结束阶段从手卡把1张「核成兽的钢核」送去墓地或把手卡1只岩石族怪兽给对方观看。或者都不进行让这张卡破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EVENT_PHASE+PHASE_END)
	e1:SetCountLimit(1)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(c45041488.mtcon)
	e1:SetOperation(c45041488.mtop)
	c:RegisterEffect(e1)
	-- 效果怪兽的效果发动时，可以把这张卡解放让那个发动无效并破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(45041488,3))  --"效果怪物发动无效并破坏"
	e2:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e2:SetCode(EVENT_CHAINING)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(c45041488.condition)
	e2:SetCost(c45041488.cost)
	e2:SetTarget(c45041488.target)
	e2:SetOperation(c45041488.operation)
	c:RegisterEffect(e2)
end
-- 维持效果的发动条件：仅在当前回合玩家是这张卡的控制者（即控制者的结束阶段）时才会进行维持处理。
function c45041488.mtcon(e,tp,eg,ep,ev,re,r,rp)
	-- 返回当前回合玩家是否等于这张卡的控制者。
	return Duel.GetTurnPlayer()==tp
end
-- 过滤出可作为维持代价的手卡「核成兽的钢核」：卡号是36623431且可以当作代价送去墓地。
function c45041488.cfilter1(c)
	return c:IsCode(36623431) and c:IsAbleToGraveAsCost()
end
-- 过滤出可用于展示维持的怪兽：岩石族怪兽且当前不是公开状态。
function c45041488.cfilter2(c)
	return c:IsType(TYPE_MONSTER) and c:IsRace(RACE_ROCK) and not c:IsPublic()
end
-- 维持效果的操作：先展示这张卡，再根据手卡情况提供选项，让控制者选择送钢核、展示岩石族怪兽或破坏自身，并执行对应处理。
function c45041488.mtop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 手动为这张卡显示被选为对象的动画，并记录其被选为维持处理的对象。
	Duel.HintSelection(Group.FromCards(c))
	-- 获取我方手卡中满足 cfilter1 的「核成兽的钢核」的集合。
	local g1=Duel.GetMatchingGroup(c45041488.cfilter1,tp,LOCATION_HAND,0,nil)
	-- 获取我方手卡中满足 cfilter2 的岩石族怪兽的集合。
	local g2=Duel.GetMatchingGroup(c45041488.cfilter2,tp,LOCATION_HAND,0,nil)
	local select=2
	-- 提示玩家进行选择（将后续选项文本写入选择缓存）。
	Duel.Hint(HINT_SELECTMSG,tp,0)
	if g1:GetCount()>0 and g2:GetCount()>0 then
		-- 当两种维持方式都可行时，弹出三个选项：送钢核、展示岩石族怪兽、破坏自身，返回选择序号。
		select=Duel.SelectOption(tp,aux.Stringid(45041488,0),aux.Stringid(45041488,1),aux.Stringid(45041488,2))  --"选择一张「核成兽的钢核」送去墓地/选择一只岩石族怪物给对方观看/破坏「核成守护者」"
	elseif g1:GetCount()>0 then
		-- 只有送钢核可行时，弹出两个选项：送钢核或破坏自身；若玩家选择破坏则将序号映射为2。
		select=Duel.SelectOption(tp,aux.Stringid(45041488,0),aux.Stringid(45041488,2))  --"选择一张「核成兽的钢核」送去墓地/破坏「核成守护者」"
		if select==1 then select=2 end
	elseif g2:GetCount()>0 then
		-- 只有展示岩石族可行时，弹出两个选项：展示岩石族或破坏自身；返回序号+1，使展示对应0、破坏对应2。
		select=Duel.SelectOption(tp,aux.Stringid(45041488,1),aux.Stringid(45041488,2))+1  --"选择一只岩石族怪物给对方观看/破坏「核成守护者」"
	else
		-- 两种维持方式都不可行时，只提供破坏自身选项，并将序号固定为2。
		select=Duel.SelectOption(tp,aux.Stringid(45041488,2))  --"破坏「核成守护者」"
		select=2
	end
	if select==0 then
		-- 在选择送钢核后，提示玩家选择要送去墓地的「核成兽的钢核」。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
		local g=g1:Select(tp,1,1,nil)
		-- 将选择的「核成兽的钢核」作为维持代价送去墓地。
		Duel.SendtoGrave(g,REASON_COST)
	elseif select==1 then
		-- 在选择展示岩石族后，提示玩家选择要展示给对方确认的岩石族怪兽。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)  --"请选择给对方确认的卡"
		local g=g2:Select(tp,1,1,nil)
		-- 将选择的岩石族怪兽给对方玩家确认。
		Duel.ConfirmCards(1-tp,g)
		-- 展示后洗切手卡，重置手卡顺序的随机状态。
		Duel.ShuffleHand(tp)
	else
		-- 当控制者未进行任何维持动作时，将这张卡自身破坏作为维持失败的后果。
		Duel.Destroy(c,REASON_COST)
	end
end
-- 第二个效果的发动条件：本卡未被战斗破坏、连锁的是怪兽效果的发动，且该连锁可以被无效。
function c45041488.condition(e,tp,eg,ep,ev,re,r,rp)
	return not e:GetHandler():IsStatus(STATUS_BATTLE_DESTROYED) and re:IsActiveType(TYPE_MONSTER)
		-- 追加条件：该连锁当前能被无效，避免对无法无效的效果发动此卡。
		and Duel.IsChainNegatable(ev)
end
-- 第二个效果的代价判定与执行：发动时要求本卡可解放，然后解放自身作为代价。
function c45041488.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsReleasable() end
	-- 把这张卡解放作为发动代价。
	Duel.Release(e:GetHandler(),REASON_COST)
end
-- 第二个效果发动时的目标设置：宣告要无效并破坏；若发动效果的怪兽可破坏且仍与该效果关联，则追加破坏的操作信息。
function c45041488.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置操作信息：本次处理包含“无效发动”分类，目标为当前连锁的怪兽效果 eg。
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	if re:GetHandler():IsDestructable() and re:GetHandler():IsRelateToEffect(re) then
		-- 若该效果怪兽可以被破坏且与效果仍有关联，则追加“破坏”分类，目标同为 eg。
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
	end
end
-- 第二个效果的实际处理：若成功使该连锁发动无效，并且发动效果的怪兽仍与效果关联，则将其破坏。
function c45041488.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 判断是否成功无效了该连锁，且该怪兽效果仍与自身效果关联。
	if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) then
		-- 将发动被无效的效果怪兽破坏。
		Duel.Destroy(eg,REASON_EFFECT)
	end
end
