--大欲な壺
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：从除外的自己以及对方的怪兽之中以合计3只为对象才能发动。那3只怪兽回到持有者卡组洗切。那之后，自己从卡组抽1张。
function c64014615.initial_effect(c)
	-- 这个卡名的卡在1回合只能发动1张。①：从除外的自己以及对方的怪兽之中以合计3只为对象才能发动。那3只怪兽回到持有者卡组洗切。那之后，自己从卡组抽1张。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TODECK+CATEGORY_DRAW)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,64014615+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(c64014615.target)
	e1:SetOperation(c64014615.activate)
	c:RegisterEffect(e1)
end
-- 过滤条件：表侧表示的怪兽且可以回到卡组
function c64014615.filter(c)
	return c:IsFaceup() and c:IsType(TYPE_MONSTER) and c:IsAbleToDeck()
end
-- 过滤条件：在指定玩家的卡组中
function c64014615.sfilter(c,tp)
	return c:IsLocation(LOCATION_DECK) and c:IsControler(tp)
end
-- 效果发动的对象选择与可行性检查
function c64014615.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_REMOVED) and c64014615.filter(chkc) end
	-- 检查自身是否可以抽卡
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1)
		-- 检查双方除外区是否存在合计3只满足条件的怪兽
		and Duel.IsExistingTarget(c64014615.filter,tp,LOCATION_REMOVED,LOCATION_REMOVED,3,nil) end
	-- 提示玩家选择要返回卡组的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 选择3只除外的怪兽作为效果的对象
	local g=Duel.SelectTarget(tp,c64014615.filter,tp,LOCATION_REMOVED,LOCATION_REMOVED,3,3,nil)
	-- 设置操作信息：将选中的卡片送回卡组
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,g:GetCount(),0,0)
	-- 设置操作信息：玩家抽1张卡
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
-- 效果处理：将对象怪兽送回持有者卡组洗切，若成功送回3只，则自己抽1张卡
function c64014615.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的对象卡片
	local tg=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	if not tg or tg:FilterCount(Card.IsRelateToEffect,nil,e)~=3 then return end
	-- 将对象怪兽送回持有者卡组
	Duel.SendtoDeck(tg,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	-- 获取实际被操作（送回卡组/额外卡组）的卡片组
	local g=Duel.GetOperatedGroup()
	-- 如果有卡片回到了自己的主卡组，则洗切自己的卡组
	if g:IsExists(c64014615.sfilter,1,nil,tp) then Duel.ShuffleDeck(tp) end
	-- 如果有卡片回到了对方的主卡组，则洗切对方的卡组
	if g:IsExists(c64014615.sfilter,1,nil,1-tp) then Duel.ShuffleDeck(1-tp) end
	local ct=g:FilterCount(Card.IsLocation,nil,LOCATION_DECK+LOCATION_EXTRA)
	if ct==3 then
		-- 中断当前效果，使之后的效果处理（抽卡）视为不同时处理
		Duel.BreakEffect()
		-- 玩家从卡组抽1张卡
		Duel.Draw(tp,1,REASON_EFFECT)
	end
end
