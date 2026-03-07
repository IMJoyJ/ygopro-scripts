--スウィートルームメイド
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：从自己或者对方的手卡·卡组有卡被送去墓地的场合，以自己或者对方的墓地1张卡为对象才能发动。那张卡回到持有者卡组。
local s,id,o=GetID()
-- 注册效果：将该卡设置为发动时点效果，触发条件为有卡送去墓地，可选择对象，限制1回合1次
function s.initial_effect(c)
	-- ①：从自己或者对方的手卡·卡组有卡被送去墓地的场合，以自己或者对方的墓地1张卡为对象才能发动。那张卡回到持有者卡组。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TODECK)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_TO_GRAVE)
	e1:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
-- 判断被送去墓地的卡是否来自手牌或卡组
function s.cfilter(c)
	return c:IsPreviousLocation(LOCATION_HAND+LOCATION_DECK)
end
-- 判断是否有卡从手牌或卡组送去墓地
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.cfilter,1,nil)
end
-- 处理效果的选卡阶段：选择1张可送回卡组的墓地卡作为对象
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsAbleToDeck() end
	-- 检查是否满足选卡条件：墓地存在可送回卡组的卡
	if chk==0 then return Duel.IsExistingTarget(Card.IsAbleToDeck,tp,LOCATION_GRAVE,LOCATION_GRAVE,1,nil) end
	-- 提示玩家选择要送回卡组的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 选择1张墓地的卡作为效果对象
	local g=Duel.SelectTarget(tp,Card.IsAbleToDeck,tp,LOCATION_GRAVE,LOCATION_GRAVE,1,1,nil)
	-- 设置效果处理信息：将选中的卡送回卡组
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,1,0,0)
end
-- 效果处理阶段：将选中的卡送回持有者卡组
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前效果选择的对象卡
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将对象卡以效果原因送回卡组并洗牌
		Duel.SendtoDeck(tc,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	end
end
