--自由解放
-- 效果：
-- ①：自己怪兽被战斗破坏送去墓地时，以场上2只表侧表示怪兽为对象才能发动。那些表侧表示怪兽回到持有者卡组。
function c72022087.initial_effect(c)
	-- ①：自己怪兽被战斗破坏送去墓地时，以场上2只表侧表示怪兽为对象才能发动。那些表侧表示怪兽回到持有者卡组。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TODECK)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_BATTLE_DESTROYED)
	e1:SetCondition(c72022087.condition)
	e1:SetTarget(c72022087.target)
	e1:SetOperation(c72022087.activate)
	c:RegisterEffect(e1)
end
-- 过滤条件：被战斗破坏送去墓地的自己怪兽
function c72022087.cfilter(c,tp)
	return c:IsReason(REASON_BATTLE) and c:IsLocation(LOCATION_GRAVE) and c:IsPreviousControler(tp)
end
-- 发动条件：确认是否有自己怪兽被战斗破坏送去墓地
function c72022087.condition(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c72022087.cfilter,1,nil,tp)
end
-- 过滤条件：场上表侧表示且能回到卡组的怪兽
function c72022087.filter(c)
	return c:IsFaceup() and c:IsAbleToDeck()
end
-- 效果发动：选择对象并设置操作信息
function c72022087.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c72022087.filter(chkc) end
	-- 发动检测：检查场上是否存在至少2只可以回到卡组的表侧表示怪兽
	if chk==0 then return Duel.IsExistingTarget(c72022087.filter,tp,LOCATION_MZONE,LOCATION_MZONE,2,nil) end
	-- 提示玩家选择要返回卡组的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 选择场上2只表侧表示怪兽作为效果的对象
	local g=Duel.SelectTarget(tp,c72022087.filter,tp,LOCATION_MZONE,LOCATION_MZONE,2,2,nil)
	-- 设置操作信息：将2张卡送回卡组
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,2,0,0)
end
-- 过滤条件：仍存在于场上且表侧表示的对象怪兽
function c72022087.acfilter(c,e)
	return c:IsFaceup() and c:IsRelateToEffect(e)
end
-- 效果处理：将作为对象的怪兽送回持有者卡组
function c72022087.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中仍合法的对象怪兽
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(c72022087.acfilter,nil,e)
	-- 将目标怪兽送回持有者卡组并洗牌
	Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
end
