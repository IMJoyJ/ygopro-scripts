--Kozmo－ダークエクリプサー
-- 效果：
-- ①：这张卡不会成为对方的效果的对象。
-- ②：陷阱卡发动时，从自己墓地把1只「星际仙踪」怪兽除外才能发动。那个发动无效并破坏。
-- ③：这张卡被战斗·效果破坏送去墓地的场合，把墓地的这张卡除外才能发动。从卡组把1只8星以下的「星际仙踪」怪兽加入手卡。
function c64063868.initial_effect(c)
	-- ①：这张卡不会成为对方的效果的对象。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	-- 设置不会成为对方卡的效果的对象（过滤对方玩家的效果）
	e1:SetValue(aux.tgoval)
	c:RegisterEffect(e1)
	-- ②：陷阱卡发动时，从自己墓地把1只「星际仙踪」怪兽除外才能发动。那个发动无效并破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCode(EVENT_CHAINING)
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e2:SetCondition(c64063868.condition)
	e2:SetCost(c64063868.cost)
	e2:SetTarget(c64063868.target)
	e2:SetOperation(c64063868.operation)
	c:RegisterEffect(e2)
	-- ③：这张卡被战斗·效果破坏送去墓地的场合，把墓地的这张卡除外才能发动。从卡组把1只8星以下的「星际仙踪」怪兽加入手卡。
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_TO_GRAVE)
	e3:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e3:SetCondition(c64063868.thcon)
	e3:SetCost(c64063868.thcost)
	e3:SetTarget(c64063868.thtg)
	e3:SetOperation(c64063868.thop)
	c:RegisterEffect(e3)
end
-- 效果②的发动条件：此卡未处于战破确定状态，且连锁中的效果是陷阱卡的发动，且该发动可以被无效
function c64063868.condition(e,tp,eg,ep,ev,re,r,rp)
	return not e:GetHandler():IsStatus(STATUS_BATTLE_DESTROYED)
		-- 检查发动的效果是否为陷阱卡的发动，且该发动可以被无效
		and re:IsHasType(EFFECT_TYPE_ACTIVATE) and re:IsActiveType(TYPE_TRAP) and Duel.IsChainNegatable(ev)
end
-- 过滤自己墓地中可以作为cost除外的「星际仙踪」怪兽
function c64063868.cfilter(c)
	return c:IsSetCard(0xd2) and c:IsType(TYPE_MONSTER) and c:IsAbleToRemoveAsCost()
end
-- 效果②的cost：从自己墓地把1只「星际仙踪」怪兽除外
function c64063868.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己墓地是否存在至少1只满足条件的「星际仙踪」怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c64063868.cfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 提示玩家选择要除外的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 让玩家从自己墓地选择1只满足条件的「星际仙踪」怪兽
	local g=Duel.SelectMatchingCard(tp,c64063868.cfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 将选中的怪兽表侧表示除外作为发动cost
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
-- 效果②的target：设置无效发动与破坏的操作信息
function c64063868.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置当前连锁的操作信息为“使该陷阱卡的发动无效”
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	if re:GetHandler():IsDestructable() and re:GetHandler():IsRelateToEffect(re) then
		-- 如果该卡可以被破坏且仍与效果关联，则设置操作信息为“破坏该卡”
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
	end
end
-- 效果②的operation：使发动无效并破坏该卡
function c64063868.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 如果成功使发动无效，且该卡仍与效果关联
	if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) then
		-- 破坏该卡
		Duel.Destroy(eg,REASON_EFFECT)
	end
end
-- 效果③的发动条件：此卡因战斗或效果破坏被送去墓地
function c64063868.thcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsReason(REASON_DESTROY) and c:IsReason(REASON_BATTLE+REASON_EFFECT)
end
-- 效果③的cost：把墓地的这张卡除外
function c64063868.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToRemoveAsCost() and e:GetHandler():IsLocation(LOCATION_GRAVE) end
	-- 将墓地的这张卡表侧表示除外作为发动cost
	Duel.Remove(e:GetHandler(),POS_FACEUP,REASON_COST)
end
-- 过滤卡组中可以加入手牌的8星以下的「星际仙踪」怪兽
function c64063868.thfilter(c)
	return c:IsSetCard(0xd2) and c:IsLevelBelow(8) and c:IsAbleToHand()
end
-- 效果③的target：检查卡组中是否存在满足条件的怪兽，并设置检索的操作信息
function c64063868.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在至少1只8星以下的「星际仙踪」怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c64063868.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息为“从卡组将1张卡加入手牌”
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果③的operation：从卡组把1只8星以下的「星际仙踪」怪兽加入手牌并给对方确认
function c64063868.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从卡组选择1只满足条件的「星际仙踪」怪兽
	local g=Duel.SelectMatchingCard(tp,c64063868.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的怪兽加入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 给对方玩家确认加入手牌的卡
		Duel.ConfirmCards(1-tp,g)
	end
end
