--スウィートルームメイド
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：从自己或者对方的手卡·卡组有卡被送去墓地的场合，以自己或者对方的墓地1张卡为对象才能发动。那张卡回到持有者卡组。
local s,id,o=GetID()
-- 创建并注册效果e1：该效果为魔法卡发动型效果（EFFECT_TYPE_ACTIVATE），在卡片从手卡·卡组被送去墓地时（EVENT_TO_GRAVE）满足条件可以发动；作为取对象效果，1回合只能发动1次（限制码为id+EFFECT_COUNT_CODE_OATH），发动时选择自己或对方墓地1张卡为对象，效果处理时将其返回持有者卡组。
function s.initial_effect(c)
	-- 这个卡名的卡在1回合只能发动1张。①：从自己或者对方的手卡·卡组有卡被送去墓地的场合，以自己或者对方的墓地1张卡为对象才能发动。那张卡回到持有者卡组。
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
-- 筛选条件：用于判断触发事件的卡是否是从手卡或卡组被送去墓地的卡（其之前的位置为手卡或卡组）。
function s.cfilter(c)
	return c:IsPreviousLocation(LOCATION_HAND+LOCATION_DECK)
end
-- 效果发动条件：本次送去墓地的卡集合eg中，存在至少1张之前位于手卡或卡组的卡（即从手卡·卡组送去墓地），满足该场合即可发动。
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.cfilter,1,nil)
end
-- 目标选择函数：效果发动时，从双方墓地选择1张可以返回卡组的卡作为对象。先进行合法性检查，再让玩家选择1张，并将该处理登记为‘返回卡组’的操作信息。
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsAbleToDeck() end
	-- 发动合法性判定：检查双方墓地是否存在至少1张可以返回卡组的卡，若不存在则不能发动该效果。
	if chk==0 then return Duel.IsExistingTarget(Card.IsAbleToDeck,tp,LOCATION_GRAVE,LOCATION_GRAVE,1,nil) end
	-- 向玩家显示选择卡片的提示消息，提示内容为‘请选择要返回卡组的卡’（HINTMSG_TODECK）。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 让玩家从双方墓地选择1张可以返回卡组的卡，并将该卡设置为当前连锁的对象（取对象目标）。
	local g=Duel.SelectTarget(tp,Card.IsAbleToDeck,tp,LOCATION_GRAVE,LOCATION_GRAVE,1,1,nil)
	-- 将当前连锁的操作信息登记为‘返回卡组’（CATEGORY_TODECK），作用对象为已选择的卡，数量为1，供后续处理及相关效果检测使用。
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,1,0,0)
end
-- 效果处理函数：取出发动时选择的对象卡，若该卡仍与效果保持关联（未被无效或离场等），则将其返回持有者卡组并洗牌。
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取本连锁发动时选择的对象卡。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 以‘效果’为原因将对象卡返回持有者卡组，并执行洗牌（SEQ_DECKSHUFFLE）。
		Duel.SendtoDeck(tc,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	end
end
