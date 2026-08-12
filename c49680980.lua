--コアキメイル・サンドマン
-- 效果：
-- 这张卡的控制者在每次自己的结束阶段从手卡把1张「核成兽的钢核」送去墓地或把手卡1只岩石族怪兽给对方观看。或者都不进行让这张卡破坏。对方的陷阱卡发动时，可以把这张卡解放让那个发动无效并破坏。
function c49680980.initial_effect(c)
	-- 记录该卡具有「核成兽的钢核」这张卡的卡片密码
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
-- 判断是否为自己的结束阶段
function c49680980.mtcon(e,tp,eg,ep,ev,re,r,rp)
	-- 当前回合玩家等于效果使用者
	return Duel.GetTurnPlayer()==tp
end
-- 过滤手牌中可作为cost送去墓地的「核成兽的钢核」
function c49680980.cfilter1(c)
	return c:IsCode(36623431) and c:IsAbleToGraveAsCost()
end
-- 过滤手牌中未公开的岩石族怪兽
function c49680980.cfilter2(c)
	return c:IsType(TYPE_MONSTER) and c:IsRace(RACE_ROCK) and not c:IsPublic()
end
-- 处理结束阶段效果，选择执行动作
function c49680980.mtop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 为该卡显示选为对象的动画效果
	Duel.HintSelection(Group.FromCards(c))
	-- 获取满足条件的「核成兽的钢核」卡片组
	local g1=Duel.GetMatchingGroup(c49680980.cfilter1,tp,LOCATION_HAND,0,nil)
	-- 获取满足条件的岩石族怪兽卡片组
	local g2=Duel.GetMatchingGroup(c49680980.cfilter2,tp,LOCATION_HAND,0,nil)
	local select=2
	-- 提示玩家进行选项选择
	Duel.Hint(HINT_SELECTMSG,tp,0)
	if g1:GetCount()>0 and g2:GetCount()>0 then
		-- 当手牌同时有「核成兽的钢核」和岩石族怪兽时，让玩家选择执行动作
		select=Duel.SelectOption(tp,aux.Stringid(49680980,0),aux.Stringid(49680980,1),aux.Stringid(49680980,2))  --"选择一张「核成兽的钢核」送去墓地/选择一只岩石族怪物给对方观看/破坏「核成沙人」"
	elseif g1:GetCount()>0 then
		-- 当手牌只有「核成兽的钢核」时，让玩家选择执行动作
		select=Duel.SelectOption(tp,aux.Stringid(49680980,0),aux.Stringid(49680980,2))  --"选择一张「核成兽的钢核」送去墓地/破坏「核成沙人」"
		if select==1 then select=2 end
	elseif g2:GetCount()>0 then
		-- 当手牌只有岩石族怪兽时，让玩家选择执行动作
		select=Duel.SelectOption(tp,aux.Stringid(49680980,1),aux.Stringid(49680980,2))+1  --"选择一只岩石族怪物给对方观看/破坏「核成沙人」"
	else
		-- 当手牌既无「核成兽的钢核」也无岩石族怪兽时，强制破坏该卡
		select=Duel.SelectOption(tp,aux.Stringid(49680980,2))  --"破坏「核成沙人」"
		select=2
	end
	if select==0 then
		-- 提示玩家选择要送去墓地的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
		local g=g1:Select(tp,1,1,nil)
		-- 将选中的卡送去墓地
		Duel.SendtoGrave(g,REASON_COST)
	elseif select==1 then
		-- 提示玩家选择要给对方确认的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)  --"请选择给对方确认的卡"
		local g=g2:Select(tp,1,1,nil)
		-- 向对方确认选中的卡
		Duel.ConfirmCards(1-tp,g)
		-- 洗切自己的手牌
		Duel.ShuffleHand(tp)
	else
		-- 破坏该卡
		Duel.Destroy(c,REASON_COST)
	end
end
-- 判断是否可以发动陷阱无效效果
function c49680980.condition(e,tp,eg,ep,ev,re,r,rp)
	return not e:GetHandler():IsStatus(STATUS_BATTLE_DESTROYED) and ep~=tp
		-- 确保发动的是陷阱卡且可被无效
		and re:IsHasType(EFFECT_TYPE_ACTIVATE) and re:IsActiveType(TYPE_TRAP) and Duel.IsChainNegatable(ev)
end
-- 设置解放该卡作为cost的处理
function c49680980.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsReleasable() end
	-- 解放该卡
	Duel.Release(e:GetHandler(),REASON_COST)
end
-- 设置连锁处理信息，准备使发动无效并破坏
function c49680980.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置使发动无效的操作信息
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	if re:GetHandler():IsDestructable() and re:GetHandler():IsRelateToEffect(re) then
		-- 设置破坏发动卡的操作信息
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
	end
end
-- 执行陷阱无效并破坏效果
function c49680980.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 判断是否成功无效发动且该卡仍存在
	if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) then
		-- 破坏发动的陷阱卡
		Duel.Destroy(eg,REASON_EFFECT)
	end
end
