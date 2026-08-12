--サイコ・チャージ
-- 效果：
-- 选择自己墓地存在的3只念动力族怪兽，加入卡组洗切。那之后，从自己卡组抽2张卡。
function c82633308.initial_effect(c)
	-- 选择自己墓地存在的3只念动力族怪兽，加入卡组洗切。那之后，从自己卡组抽2张卡。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TODECK+CATEGORY_DRAW)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c82633308.target)
	e1:SetOperation(c82633308.activate)
	c:RegisterEffect(e1)
end
-- 过滤条件：自己墓地的念动力族怪兽且可以回到卡组
function c82633308.filter(c)
	return c:IsRace(RACE_PSYCHO) and c:IsAbleToDeck()
end
-- 效果发动时的目标选择与合法性检查
function c82633308.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c82633308.filter(chkc) end
	-- 检查当前玩家是否可以效果抽2张卡
	if chk==0 then return Duel.IsPlayerCanDraw(tp,2)
		-- 检查自己墓地是否存在至少3只满足条件的念动力族怪兽
		and Duel.IsExistingTarget(c82633308.filter,tp,LOCATION_GRAVE,0,3,nil) end
	-- 给玩家发送提示信息：请选择要返回卡组的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 选择自己墓地3只满足条件的念动力族怪兽作为效果的对象
	local g=Duel.SelectTarget(tp,c82633308.filter,tp,LOCATION_GRAVE,0,3,3,nil)
	-- 设置连锁操作信息：将选中的卡片送回卡组
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,g:GetCount(),0,0)
	-- 设置连锁操作信息：玩家抽2张卡
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,2)
end
-- 效果处理函数：将对象怪兽返回卡组洗切，之后抽2张卡
function c82633308.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中被选为对象的卡片组
	local tg=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	if not tg or tg:FilterCount(Card.IsRelateToEffect,nil,e)~=3 then return end
	-- 将对象卡片送回持有者卡组
	Duel.SendtoDeck(tg,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	-- 获取上一步操作中实际移动位置的卡片组
	local g=Duel.GetOperatedGroup()
	-- 如果被操作的卡片中存在回到了主卡组的卡，则洗切卡组
	if g:IsExists(Card.IsLocation,1,nil,LOCATION_DECK) then Duel.ShuffleDeck(tp) end
	local ct=g:FilterCount(Card.IsLocation,nil,LOCATION_DECK+LOCATION_EXTRA)
	if ct==3 then
		-- 中断当前效果处理，使之后的操作不与返回卡组同时处理（用于处理“那之后”的时点）
		Duel.BreakEffect()
		-- 玩家从卡组抽2张卡
		Duel.Draw(tp,2,REASON_EFFECT)
	end
end
