--氷結界の輸送部隊
-- 效果：
-- ①：1回合1次，以自己墓地2只「冰结界」怪兽为对象才能发动。那2只怪兽回到卡组。那之后，双方各自抽1张。
function c37806313.initial_effect(c)
	-- 效果原文内容：①：1回合1次，以自己墓地2只「冰结界」怪兽为对象才能发动。那2只怪兽回到卡组。那之后，双方各自抽1张。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TODECK+CATEGORY_DRAW)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetTarget(c37806313.target)
	e1:SetOperation(c37806313.operation)
	c:RegisterEffect(e1)
end
-- 效果作用：定义过滤器，用于筛选墓地中的「冰结界」怪兽
function c37806313.filter(c)
	return c:IsSetCard(0x2f) and c:IsType(TYPE_MONSTER) and c:IsAbleToDeck()
end
-- 效果作用：处理效果发动时的条件判断和目标选择
function c37806313.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c37806313.filter(chkc) end
	-- 效果作用：检查玩家是否可以抽卡
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1) and Duel.IsPlayerCanDraw(1-tp,1)
		-- 效果作用：检查是否存在满足条件的2只墓地怪兽
		and Duel.IsExistingTarget(c37806313.filter,tp,LOCATION_GRAVE,0,2,nil) end
	-- 效果作用：提示玩家选择要返回卡组的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 效果作用：选择2只满足条件的墓地怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c37806313.filter,tp,LOCATION_GRAVE,0,2,2,nil)
	-- 效果作用：设置效果操作信息，指定将怪兽送回卡组
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,g:GetCount(),0,0)
	-- 效果作用：设置效果操作信息，指定双方各抽1张卡
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,PLAYER_ALL,1)
end
-- 效果作用：处理效果的发动效果
function c37806313.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 效果作用：获取当前连锁中指定的效果对象卡片组
	local tg=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	if not tg or tg:FilterCount(Card.IsRelateToEffect,nil,e)~=2 then return end
	-- 效果作用：将指定的怪兽送回卡组
	Duel.SendtoDeck(tg,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	-- 效果作用：获取实际被操作的卡片组
	local g=Duel.GetOperatedGroup()
	-- 效果作用：若送回卡组的卡片中有在卡组中的，则洗切卡组
	if g:IsExists(Card.IsLocation,1,nil,LOCATION_DECK) then Duel.ShuffleDeck(tp) end
	local ct=g:FilterCount(Card.IsLocation,nil,LOCATION_DECK+LOCATION_EXTRA)
	if ct==2 then
		-- 效果作用：中断当前效果，使后续处理视为不同时处理
		Duel.BreakEffect()
		-- 效果作用：自己抽1张卡
		Duel.Draw(tp,1,REASON_EFFECT)
		-- 效果作用：对方抽1张卡
		Duel.Draw(1-tp,1,REASON_EFFECT)
	end
end
