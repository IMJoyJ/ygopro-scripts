--貪欲な瓶
-- 效果：
-- 「贪欲之瓶」在1回合只能发动1张。
-- ①：以「贪欲之瓶」以外的自己墓地5张卡为对象才能发动。那5张卡加入卡组洗切。那之后，自己从卡组抽1张。
function c98954106.initial_effect(c)
	-- 「贪欲之瓶」在1回合只能发动1张。①：以「贪欲之瓶」以外的自己墓地5张卡为对象才能发动。那5张卡加入卡组洗切。那之后，自己从卡组抽1张。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TODECK+CATEGORY_DRAW)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,98954106+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(c98954106.target)
	e1:SetOperation(c98954106.activate)
	c:RegisterEffect(e1)
end
-- 定义过滤条件：非同名卡且可以回到卡组的卡
function c98954106.filter(c)
	return not c:IsCode(98954106) and c:IsAbleToDeck()
end
-- 效果发动时的对象合法性检测
function c98954106.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c98954106.filter(chkc) end
	-- 检查玩家是否具有抽卡的效果许可
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1)
		-- 以及自己墓地是否存在5张满足过滤条件的卡作为对象
		and Duel.IsExistingTarget(c98954106.filter,tp,LOCATION_GRAVE,0,5,nil) end
	-- 提示玩家选择要返回卡组的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 选择自己墓地5张满足过滤条件的卡作为效果对象
	local g=Duel.SelectTarget(tp,c98954106.filter,tp,LOCATION_GRAVE,0,5,5,nil)
	-- 设置连锁操作信息：将5张卡送回卡组
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,5,0,0)
	-- 设置连锁操作信息：玩家抽1张卡
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
-- 效果处理的执行逻辑
function c98954106.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中作为效果对象的卡片组
	local tg=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	if tg:FilterCount(Card.IsRelateToEffect,nil,e)~=5 then return end
	-- 将作为对象的卡片送回持有者卡组并准备洗牌
	Duel.SendtoDeck(tg,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	-- 获取上一步实际被送回卡组/额外卡组的卡片组
	local g=Duel.GetOperatedGroup()
	-- 若有卡片实际回到了主卡组，则洗切卡组
	if g:IsExists(Card.IsLocation,1,nil,LOCATION_DECK) then Duel.ShuffleDeck(tp) end
	local ct=g:FilterCount(Card.IsLocation,nil,LOCATION_DECK+LOCATION_EXTRA)
	if ct==5 then
		-- 中断当前效果处理，使后续的抽卡处理不与回卡组视为同时进行
		Duel.BreakEffect()
		-- 玩家从卡组抽1张卡
		Duel.Draw(tp,1,REASON_EFFECT)
	end
end
