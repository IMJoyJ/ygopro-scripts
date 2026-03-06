--紅蓮の女守護兵
-- 效果：
-- 表侧表示的这张卡做祭品。1只这个回合被战斗破坏送去墓地的自己的怪兽回到卡组的最下面。
function c28358902.initial_effect(c)
	-- 创建效果，设置为起动效果，取对象，发动区域为主怪区，需要支付祭品，选择目标，发动时处理效果
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TODECK)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCost(c28358902.cost)
	e1:SetTarget(c28358902.target)
	e1:SetOperation(c28358902.operation)
	c:RegisterEffect(e1)
end
-- 支付祭品的处理函数，检查是否可以解放自身
function c28358902.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsReleasable() end
	-- 将自身从游戏中解放作为祭品
	Duel.Release(e:GetHandler(),REASON_COST)
end
-- 筛选符合条件的墓地怪兽，必须是怪兽卡、本回合被战斗破坏、可以送回卡组
function c28358902.filter(c,tid)
	return c:IsType(TYPE_MONSTER) and c:GetTurnID()==tid and c:IsReason(REASON_BATTLE) and c:IsAbleToDeck()
end
-- 选择目标的处理函数，检查是否有符合条件的墓地怪兽，提示选择并设置操作信息
function c28358902.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	-- 获取当前回合数，用于判断是否为本回合被破坏的怪兽
	local tid=Duel.GetTurnCount()
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c28358902.filter(chkc,tid) end
	-- 检查是否有满足条件的墓地怪兽作为目标
	if chk==0 then return Duel.IsExistingTarget(c28358902.filter,tp,LOCATION_GRAVE,0,1,nil,tid) end
	-- 提示玩家选择要送回卡组的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 选择符合条件的墓地怪兽作为目标
	local g=Duel.SelectTarget(tp,c28358902.filter,tp,LOCATION_GRAVE,0,1,1,nil,tid)
	-- 设置操作信息，指定将目标怪兽送回卡组
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,1,0,0)
end
-- 效果发动时的处理函数，将选中的怪兽送回卡组底端
function c28358902.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中选择的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标怪兽送回卡组底端
		Duel.SendtoDeck(tc,nil,SEQ_DECKBOTTOM,REASON_EFFECT)
	end
end
