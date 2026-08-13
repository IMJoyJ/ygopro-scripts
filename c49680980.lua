--コアキメイル・サンドマン
-- 效果：
-- 这张卡的控制者在每次自己的结束阶段从手卡把1张「核成兽的钢核」送去墓地或把手卡1只岩石族怪兽给对方观看。或者都不进行让这张卡破坏。对方的陷阱卡发动时，可以把这张卡解放让那个发动无效并破坏。
function c49680980.initial_effect(c)
	-- 将「核成兽的钢核」登记为这张卡所记载的关联卡名，便于后续检索该卡名。
	aux.AddCodeList(c,36623431)
	-- 这张卡的控制者在每次自己的结束阶段从手卡把1张「核成兽的钢核」送去墓地或把手卡1只岩石族怪兽给对方观看。或者都不进行让这张卡破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EVENT_PHASE+PHASE_END)
	e1:SetCountLimit(1)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(c49680980.mtcon)
	e1:SetOperation(c49680980.mtop)
	c:RegisterEffect(e1)
	-- 对方的陷阱卡发动时，可以把这张卡解放让那个发动无效并破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(49680980,3))  --"陷阱发动无效并破坏"
	e2:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e2:SetCode(EVENT_CHAINING)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(c49680980.condition)
	e2:SetCost(c49680980.cost)
	e2:SetTarget(c49680980.target)
	e2:SetOperation(c49680980.operation)
	c:RegisterEffect(e2)
end
-- 维持效果的发动条件：仅当当前回合玩家为这张卡的控制者（即控制者的结束阶段）时才处理维持COST。
function c49680980.mtcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前回合玩家是否等于效果持有者，用于限定在控制者的结束阶段发动。
	return Duel.GetTurnPlayer()==tp
end
-- 筛选控制者手卡中满足条件的卡：卡名为「核成兽的钢核」，且可以作为代价送去墓地。
function c49680980.cfilter1(c)
	return c:IsCode(36623431) and c:IsAbleToGraveAsCost()
end
-- 筛选控制者手卡中满足条件的卡：岩石族怪兽且当前未公开（不能给对方观看的已公开卡不满足条件）。
function c49680980.cfilter2(c)
	return c:IsType(TYPE_MONSTER) and c:IsRace(RACE_ROCK) and not c:IsPublic()
end
-- 结束阶段维持COST的处理：让控制者选择把「核成兽的钢核」送去墓地、展示手卡岩石族怪兽，或两者都不做而破坏这张卡。
function c49680980.mtop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 为这张卡播放被选择/处理效果的动画，向双方展示当前正在处理该卡。
	Duel.HintSelection(Group.FromCards(c))
	-- 获取控制者手卡中所有可作为代价送去墓地的「核成兽的钢核」。
	local g1=Duel.GetMatchingGroup(c49680980.cfilter1,tp,LOCATION_HAND,0,nil)
	-- 获取控制者手卡中所有可作为展示代价的岩石族怪兽。
	local g2=Duel.GetMatchingGroup(c49680980.cfilter2,tp,LOCATION_HAND,0,nil)
	local select=2
	-- 向控制者发送选择提示（初始化选择消息缓存），准备进行选项选择。
	Duel.Hint(HINT_SELECTMSG,tp,0)
	if g1:GetCount()>0 and g2:GetCount()>0 then
		-- 当手卡同时存在两种维持COST时，让控制者从“送钢核/展示岩石族/破坏自身”三项中选择一项。
		select=Duel.SelectOption(tp,aux.Stringid(49680980,0),aux.Stringid(49680980,1),aux.Stringid(49680980,2))  --"选择一张「核成兽的钢核」送去墓地/选择一只岩石族怪物给对方观看/破坏「核成沙人」"
	elseif g1:GetCount()>0 then
		-- 当手卡只有「核成兽的钢核」可处理时，让控制者在“送钢核”和“破坏自身”之间选择；若选择破坏则把选项索引映射为2。
		select=Duel.SelectOption(tp,aux.Stringid(49680980,0),aux.Stringid(49680980,2))  --"选择一张「核成兽的钢核」送去墓地/破坏「核成沙人」"
		if select==1 then select=2 end
	elseif g2:GetCount()>0 then
		-- 当手卡只有岩石族怪兽可展示时，让控制者在“展示岩石族”和“破坏自身”之间选择；结果加1以匹配后续分支索引。
		select=Duel.SelectOption(tp,aux.Stringid(49680980,1),aux.Stringid(49680980,2))+1  --"选择一只岩石族怪物给对方观看/破坏「核成沙人」"
	else
		-- 当手卡没有任何可支付的维持COST时，仅提供“破坏自身”选项，并强制选择破坏。
		select=Duel.SelectOption(tp,aux.Stringid(49680980,2))  --"破坏「核成沙人」"
		select=2
	end
	if select==0 then
		-- 提示控制者选择一张要送去墓地的卡（此处为核成兽的钢核）。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
		local g=g1:Select(tp,1,1,nil)
		-- 将选择的那张「核成兽的钢核」作为维持COST送去墓地。
		Duel.SendtoGrave(g,REASON_COST)
	elseif select==1 then
		-- 提示控制者选择一张手卡展示给对方确认。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)  --"请选择给对方确认的卡"
		local g=g2:Select(tp,1,1,nil)
		-- 将控制者选择的手卡展示给对方玩家确认。
		Duel.ConfirmCards(1-tp,g)
		-- 展示确认后洗切控制者的手卡，避免因展示泄露手牌顺序信息。
		Duel.ShuffleHand(tp)
	else
		-- 当控制者没有进行送墓或展示动作时，将这张卡自身破坏作为不维持的代价。
		Duel.Destroy(c,REASON_COST)
	end
end
-- 陷阱无效效果的发动条件：这张卡未被战斗破坏，且当前连锁是对方发动的陷阱卡，且该陷阱卡的发动可以被无效。
function c49680980.condition(e,tp,eg,ep,ev,re,r,rp)
	return not e:GetHandler():IsStatus(STATUS_BATTLE_DESTROYED) and ep~=tp
		-- 进一步确认连锁上的效果是陷阱卡的发动，且该发动处于可以被无效的状态。
		and re:IsHasType(EFFECT_TYPE_ACTIVATE) and re:IsActiveType(TYPE_TRAP) and Duel.IsChainNegatable(ev)
end
-- 发动代价检查与执行：先确认这张卡可以解放，实际发动时将其解放。
function c49680980.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsReleasable() end
	-- 将这张卡解放作为发动代价。
	Duel.Release(e:GetHandler(),REASON_COST)
end
-- 目标处理：允许效果发动；设置操作信息为无效当前连锁的陷阱卡；若该陷阱卡可破坏且仍与效果关联，则同时设置破坏信息。
function c49680980.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置本次连锁的处理信息：无效发动，对象为当前连锁上的陷阱卡。
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	if re:GetHandler():IsDestructable() and re:GetHandler():IsRelateToEffect(re) then
		-- 在陷阱卡可被破坏且仍与效果关联时，追加设置破坏该陷阱卡的处理信息。
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
	end
end
-- 效果处理：无效对方陷阱卡的发动；若无效成功且该陷阱卡仍与效果关联，则将其破坏。
function c49680980.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 判断无效发动是否成功，并确认该陷阱卡仍然与效果相关。
	if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) then
		-- 将无效发动的陷阱卡破坏（属于效果产生的破坏）。
		Duel.Destroy(eg,REASON_EFFECT)
	end
end
