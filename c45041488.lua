--コアキメイル・ガーディアン
-- 效果：
-- 这张卡的控制者在每次自己的结束阶段从手卡把1张「核成兽的钢核」送去墓地或把手卡1只岩石族怪兽给对方观看。或者都不进行让这张卡破坏。效果怪兽的效果发动时，可以把这张卡解放让那个发动无效并破坏。
function c45041488.initial_effect(c)
	-- 记录该卡具有「核成兽的钢核」这张卡的名称
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
-- 判断是否为当前回合玩家
function c45041488.mtcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断是否为当前回合玩家
	return Duel.GetTurnPlayer()==tp
end
-- 过滤手卡中可作为墓地代价的「核成兽的钢核」
function c45041488.cfilter1(c)
	return c:IsCode(36623431) and c:IsAbleToGraveAsCost()
end
-- 过滤手卡中未公开的岩石族怪兽
function c45041488.cfilter2(c)
	return c:IsType(TYPE_MONSTER) and c:IsRace(RACE_ROCK) and not c:IsPublic()
end
-- 处理结束阶段效果，允许玩家选择执行三种行为之一
function c45041488.mtop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 显示被选为对象的动画效果
	Duel.HintSelection(Group.FromCards(c))
	-- 获取满足条件的「核成兽的钢核」卡片组
	local g1=Duel.GetMatchingGroup(c45041488.cfilter1,tp,LOCATION_HAND,0,nil)
	-- 获取满足条件的岩石族怪兽卡片组
	local g2=Duel.GetMatchingGroup(c45041488.cfilter2,tp,LOCATION_HAND,0,nil)
	local select=2
	-- 提示玩家进行选择
	Duel.Hint(HINT_SELECTMSG,tp,0)
	if g1:GetCount()>0 and g2:GetCount()>0 then
		-- 玩家选择三种行为之一：送去墓地、给对方观看、破坏自己
		select=Duel.SelectOption(tp,aux.Stringid(45041488,0),aux.Stringid(45041488,1),aux.Stringid(45041488,2))  --"选择一张「核成兽的钢核」送去墓地/选择一只岩石族怪物给对方观看/破坏「核成守护者」"
	elseif g1:GetCount()>0 then
		-- 玩家选择两种行为之一：送去墓地、破坏自己
		select=Duel.SelectOption(tp,aux.Stringid(45041488,0),aux.Stringid(45041488,2))  --"选择一张「核成兽的钢核」送去墓地/破坏「核成守护者」"
		if select==1 then select=2 end
	elseif g2:GetCount()>0 then
		-- 玩家选择两种行为之一：给对方观看、破坏自己
		select=Duel.SelectOption(tp,aux.Stringid(45041488,1),aux.Stringid(45041488,2))+1  --"选择一只岩石族怪物给对方观看/破坏「核成守护者」"
	else
		-- 玩家只能选择破坏自己
		select=Duel.SelectOption(tp,aux.Stringid(45041488,2))  --"破坏「核成守护者」"
		select=2
	end
	if select==0 then
		-- 提示玩家选择要送去墓地的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
		local g=g1:Select(tp,1,1,nil)
		-- 将选择的卡送去墓地
		Duel.SendtoGrave(g,REASON_COST)
	elseif select==1 then
		-- 提示玩家选择要给对方确认的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)  --"请选择给对方确认的卡"
		local g=g2:Select(tp,1,1,nil)
		-- 向对方确认选择的卡
		Duel.ConfirmCards(1-tp,g)
		-- 洗切自己的手牌
		Duel.ShuffleHand(tp)
	else
		-- 破坏自己
		Duel.Destroy(c,REASON_COST)
	end
end
-- 判断效果发动是否满足条件
function c45041488.condition(e,tp,eg,ep,ev,re,r,rp)
	return not e:GetHandler():IsStatus(STATUS_BATTLE_DESTROYED) and re:IsActiveType(TYPE_MONSTER)
		-- 判断连锁是否可以被无效
		and Duel.IsChainNegatable(ev)
end
-- 支付解放费用
function c45041488.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsReleasable() end
	-- 解放自己作为费用
	Duel.Release(e:GetHandler(),REASON_COST)
end
-- 设置效果处理信息
function c45041488.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置使发动无效的效果信息
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	if re:GetHandler():IsDestructable() and re:GetHandler():IsRelateToEffect(re) then
		-- 设置破坏效果信息
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
	end
end
-- 执行效果处理
function c45041488.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 判断是否成功使发动无效并确认目标卡是否有效
	if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) then
		-- 破坏目标卡
		Duel.Destroy(eg,REASON_EFFECT)
	end
end
