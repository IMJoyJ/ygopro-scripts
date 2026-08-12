--炎渦の胎動
-- 效果：
-- 从手卡把1只名字带有「熔岩」的怪兽送去墓地发动。陷阱卡的发动无效并破坏。此外，这张卡在墓地存在的场合，可以把自己墓地存在的2只炎属性怪兽从游戏中除外，这张卡加入手卡。
function c86690572.initial_effect(c)
	-- 从手卡把1只名字带有「熔岩」的怪兽送去墓地发动。陷阱卡的发动无效并破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_CHAINING)
	e1:SetCondition(c86690572.condition)
	e1:SetCost(c86690572.cost)
	e1:SetTarget(c86690572.target)
	e1:SetOperation(c86690572.activate)
	c:RegisterEffect(e1)
	-- 此外，这张卡在墓地存在的场合，可以把自己墓地存在的2只炎属性怪兽从游戏中除外，这张卡加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetDescription(aux.Stringid(86690572,0))  --"这张卡加入手卡"
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCost(c86690572.thcost)
	e2:SetTarget(c86690572.thtg)
	e2:SetOperation(c86690572.thop)
	c:RegisterEffect(e2)
end
-- 发动条件：检查当前连锁中是否有可以被无效的陷阱卡的发动。
function c86690572.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 判断触发效果的卡是否为陷阱卡的发动，且该发动可以被无效。
	return re:IsActiveType(TYPE_TRAP) and re:IsHasType(EFFECT_TYPE_ACTIVATE) and Duel.IsChainNegatable(ev)
end
-- 过滤条件：手牌中名字带有「熔岩」且能送去墓地的卡。
function c86690572.cfilter(c)
	return c:IsSetCard(0x39) and c:IsAbleToGraveAsCost()
end
-- 发动代价：从手卡将1只「熔岩」怪兽送去墓地。
function c86690572.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动阶段，检查手牌中是否存在至少1只满足条件的「熔岩」怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(c86690572.cfilter,tp,LOCATION_HAND,0,1,nil) end
	-- 给玩家发送提示信息，要求选择送去墓地的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 让玩家从手牌中选择1只满足条件的「熔岩」怪兽。
	local g=Duel.SelectMatchingCard(tp,c86690572.cfilter,tp,LOCATION_HAND,0,1,1,nil)
	-- 将选中的怪兽作为发动代价送去墓地。
	Duel.SendtoGrave(g,REASON_COST)
end
-- 效果的目标：设置无效发动与破坏的操作信息。
function c86690572.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置操作信息，表示该效果包含“使发动无效”的操作，对象为触发连锁的卡。
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	if re:GetHandler():IsDestructable() and re:GetHandler():IsRelateToEffect(re) then
		-- 设置操作信息，表示该效果包含“破坏”的操作，对象为触发连锁的卡。
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
	end
end
-- 效果的处理：使陷阱卡的发动无效并破坏。
function c86690572.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 如果成功使该陷阱卡的发动无效，且该卡在场上或原位置与效果关联。
	if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) then
		-- 将该发动被无效的卡破坏。
		Duel.Destroy(eg,REASON_EFFECT)
	end
end
-- 过滤条件：墓地中可以被除外的炎属性怪兽。
function c86690572.thfilter(c)
	return c:IsAttribute(ATTRIBUTE_FIRE) and c:IsAbleToRemoveAsCost()
end
-- 发动代价：将自己墓地存在的2只炎属性怪兽除外。
function c86690572.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动阶段，检查自己墓地是否存在至少2只可以除外的炎属性怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(c86690572.thfilter,tp,LOCATION_GRAVE,0,2,nil) end
	-- 给玩家发送提示信息，要求选择要除外的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 让玩家从自己墓地选择2只炎属性怪兽。
	local g=Duel.SelectMatchingCard(tp,c86690572.thfilter,tp,LOCATION_GRAVE,0,2,2,nil)
	-- 将选中的2只炎属性怪兽表侧表示除外作为发动代价。
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
-- 效果的目标：检查自身是否能加入手卡，并设置回收的操作信息。
function c86690572.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToHand() and not e:GetHandler():IsStatus(STATUS_CHAINING) end
	-- 设置操作信息，表示该效果包含“加入手卡”的操作，对象为墓地的这张卡。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,e:GetHandler(),1,0,0)
end
-- 效果的处理：将墓地的这张卡加入手卡并给对方确认。
function c86690572.thop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 将这张卡加入持有者的手卡。
		Duel.SendtoHand(c,nil,REASON_EFFECT)
		-- 向对方玩家展示并确认加入手卡的这张卡。
		Duel.ConfirmCards(1-tp,c)
	end
end
