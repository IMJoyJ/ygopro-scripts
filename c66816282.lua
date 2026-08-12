--コアキメイル・ウォール
-- 效果：
-- 这张卡的控制者在每次自己的结束阶段从手卡把1张「核成兽的钢核」送去墓地或把手卡1只岩石族怪兽给对方观看。或者都不进行让这张卡破坏。对方的魔法卡发动时，可以把这张卡解放让那个发动无效并破坏。
function c66816282.initial_effect(c)
	-- 注册卡片关联密码，表示该卡效果中记载了「核成兽的钢核」的卡名
	aux.AddCodeList(c,36623431)
	-- 这张卡的控制者在每次自己的结束阶段从手卡把1张「核成兽的钢核」送去墓地或把手卡1只岩石族怪兽给对方观看。或者都不进行让这张卡破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EVENT_PHASE+PHASE_END)
	e1:SetCountLimit(1)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(c66816282.mtcon)
	e1:SetOperation(c66816282.mtop)
	c:RegisterEffect(e1)
	-- 对方的魔法卡发动时，可以把这张卡解放让那个发动无效并破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(66816282,3))  --"魔法发动无效并破坏"
	e2:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e2:SetCode(EVENT_CHAINING)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(c66816282.condition)
	e2:SetCost(c66816282.cost)
	e2:SetTarget(c66816282.target)
	e2:SetOperation(c66816282.operation)
	c:RegisterEffect(e2)
end
-- 维持效果的发动条件函数：必须是自己的结束阶段
function c66816282.mtcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前回合玩家是否为该卡的控制者
	return Duel.GetTurnPlayer()==tp
end
-- 过滤手卡中可以作为Cost送去墓地的「核成兽的钢核」
function c66816282.cfilter1(c)
	return c:IsCode(36623431) and c:IsAbleToGraveAsCost()
end
-- 过滤手卡中未公开的岩石族怪兽
function c66816282.cfilter2(c)
	return c:IsType(TYPE_MONSTER) and c:IsRace(RACE_ROCK) and not c:IsPublic()
end
-- 维持效果的具体处理：选择将「核成兽的钢核」送去墓地、展示岩石族怪兽或将自身破坏
function c66816282.mtop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 选中并闪烁提示当前正在处理维持效果的这张卡
	Duel.HintSelection(Group.FromCards(c))
	-- 获取手卡中可送去墓地的「核成兽的钢核」卡片组
	local g1=Duel.GetMatchingGroup(c66816282.cfilter1,tp,LOCATION_HAND,0,nil)
	-- 获取手卡中可给对方观看的岩石族怪兽卡片组
	local g2=Duel.GetMatchingGroup(c66816282.cfilter2,tp,LOCATION_HAND,0,nil)
	local select=2
	-- 提示玩家进行维持方式的选择
	Duel.Hint(HINT_SELECTMSG,tp,0)
	if g1:GetCount()>0 and g2:GetCount()>0 then
		-- 手卡同时有钢核和岩石族怪兽时，让玩家在送墓、展示或破坏自身中选择
		select=Duel.SelectOption(tp,aux.Stringid(66816282,0),aux.Stringid(66816282,1),aux.Stringid(66816282,2))  --"选择一张「核成兽的钢核」送去墓地/选择一只岩石族怪物给对方观看/破坏「核成墙人」"
	elseif g1:GetCount()>0 then
		-- 手卡只有钢核时，让玩家在送墓或破坏自身中选择
		select=Duel.SelectOption(tp,aux.Stringid(66816282,0),aux.Stringid(66816282,2))  --"选择一张「核成兽的钢核」送去墓地/破坏「核成墙人」"
		if select==1 then select=2 end
	elseif g2:GetCount()>0 then
		-- 手卡只有岩石族怪兽时，让玩家在展示或破坏自身中选择，并调整选项索引
		select=Duel.SelectOption(tp,aux.Stringid(66816282,1),aux.Stringid(66816282,2))+1  --"选择一只岩石族怪物给对方观看/破坏「核成墙人」"
	else
		-- 手卡无对应卡片时，强制玩家选择破坏自身
		select=Duel.SelectOption(tp,aux.Stringid(66816282,2))  --"破坏「核成墙人」"
		select=2
	end
	if select==0 then
		-- 提示玩家选择要送去墓地的卡片
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
		local g=g1:Select(tp,1,1,nil)
		-- 将选中的卡片作为维持Cost送去墓地
		Duel.SendtoGrave(g,REASON_COST)
	elseif select==1 then
		-- 提示玩家选择要给对方确认的卡片
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)  --"请选择给对方确认的卡"
		local g=g2:Select(tp,1,1,nil)
		-- 将选中的卡片给对方玩家确认
		Duel.ConfirmCards(1-tp,g)
		-- 重新洗切手卡
		Duel.ShuffleHand(tp)
	else
		-- 因未进行维持处理而将这张卡破坏
		Duel.Destroy(c,REASON_COST)
	end
end
-- 魔法发动无效效果的发动条件：自身未被战斗破坏、对方发动了魔法卡且该发动可以被无效
function c66816282.condition(e,tp,eg,ep,ev,re,r,rp)
	return not e:GetHandler():IsStatus(STATUS_BATTLE_DESTROYED) and ep~=tp
		-- 检查发动的效果是否为魔法卡的发动，且该连锁的发动可以被无效
		and re:IsHasType(EFFECT_TYPE_ACTIVATE) and re:IsActiveType(TYPE_SPELL) and Duel.IsChainNegatable(ev)
end
-- 魔法发动无效效果的Cost：解放自身
function c66816282.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsReleasable() end
	-- 解放自身作为发动Cost
	Duel.Release(e:GetHandler(),REASON_COST)
end
-- 魔法发动无效效果的Target：设置无效与破坏的操作信息
function c66816282.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置操作信息：使该魔法卡的发动无效
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	if re:GetHandler():IsDestructable() and re:GetHandler():IsRelateToEffect(re) then
		-- 设置操作信息：破坏该魔法卡
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
	end
end
-- 魔法发动无效效果的运行：使发动无效并破坏
function c66816282.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 如果成功使发动无效，且该卡在连锁中仍与效果相关联
	if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) then
		-- 破坏被无效发动的卡片
		Duel.Destroy(eg,REASON_EFFECT)
	end
end
