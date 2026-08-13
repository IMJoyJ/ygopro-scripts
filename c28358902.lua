--紅蓮の女守護兵
-- 效果：
-- 表侧表示的这张卡做祭品。1只这个回合被战斗破坏送去墓地的自己的怪兽回到卡组的最下面。
function c28358902.initial_effect(c)
	-- 表侧表示的这张卡做祭品。1只这个回合被战斗破坏送去墓地的自己的怪兽回到卡组的最下面。
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
-- 定义发动代价函数：在代价确认时（chk==0）检查此卡是否可以解放；确认后解放此卡作为发动代价。
function c28358902.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsReleasable() end
	-- 将这张卡以代价形式解放（REASON_COST），用于支付效果发动所需的祭品。
	Duel.Release(e:GetHandler(),REASON_COST)
end
-- 定义对象筛选函数：选择自己墓地中满足条件的怪兽——是怪兽卡、本回合被战斗破坏送入墓地、且能够返回卡组。
function c28358902.filter(c,tid)
	return c:IsType(TYPE_MONSTER) and c:GetTurnID()==tid and c:IsReason(REASON_BATTLE) and c:IsAbleToDeck()
end
-- 定义取对象目标函数：获取当前回合数，检查对象合法性，确认墓地是否存在可选择的怪兽，然后选择1只作为效果对象，并设置回卡组的操作信息。
function c28358902.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	-- 获取当前回合数，用于筛选“这个回合”被战斗破坏送去墓地的怪兽。
	local tid=Duel.GetTurnCount()
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c28358902.filter(chkc,tid) end
	-- 在效果发动确认阶段，检查自己墓地是否存在至少1只满足筛选条件的怪兽可以作为取对象目标。
	if chk==0 then return Duel.IsExistingTarget(c28358902.filter,tp,LOCATION_GRAVE,0,1,nil,tid) end
	-- 向玩家显示选择提示，提示内容为“请选择要返回卡组的卡”。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 让玩家从自己墓地选择1只满足条件的怪兽作为效果对象，并自动登记为当前连锁的对象。
	local g=Duel.SelectTarget(tp,c28358902.filter,tp,LOCATION_GRAVE,0,1,1,nil,tid)
	-- 设置操作信息：该效果处理时将执行回卡组（CATEGORY_TODECK）操作，对象为已选择的卡g，数量为1。
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,1,0,0)
end
-- 定义效果处理函数：效果结算时，若对象卡片仍与该效果存在关联，则将其送回卡组最下面。
function c28358902.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 取得当前连锁的效果处理时选择的对象卡片。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 以效果原因（REASON_EFFECT）将该对象卡片送去其持有者卡组的最下面（SEQ_DECKBOTTOM）。
		Duel.SendtoDeck(tc,nil,SEQ_DECKBOTTOM,REASON_EFFECT)
	end
end
