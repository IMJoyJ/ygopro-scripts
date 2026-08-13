--氷結界の輸送部隊
-- 效果：
-- ①：1回合1次，以自己墓地2只「冰结界」怪兽为对象才能发动。那2只怪兽回到卡组。那之后，双方各自抽1张。
function c37806313.initial_effect(c)
	-- ①：1回合1次，以自己墓地2只「冰结界」怪兽为对象才能发动。那2只怪兽回到卡组。那之后，双方各自抽1张。
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
-- 筛选函数：判断卡片是否为「冰结界」字段的怪兽且可以返回卡组，作为效果的可选对象。
function c37806313.filter(c)
	return c:IsSetCard(0x2f) and c:IsType(TYPE_MONSTER) and c:IsAbleToDeck()
end
-- 目标选择函数：检查指定对象必须是己方墓地且符合筛选的「冰结界」怪兽；发动条件为双方可抽卡且墓地存在至少2只可选对象。
function c37806313.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c37806313.filter(chkc) end
	-- 发动条件之一：双方玩家都必须能抽1张卡，否则不能发动。
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1) and Duel.IsPlayerCanDraw(1-tp,1)
		-- 发动条件之二：自己墓地存在至少2只符合筛选条件的「冰结界」怪兽可作为效果对象。
		and Duel.IsExistingTarget(c37806313.filter,tp,LOCATION_GRAVE,0,2,nil) end
	-- 显示选择卡片的提示消息，提示玩家选择要返回卡组的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 让当前玩家从自己墓地选择2只符合筛选条件的「冰结界」怪兽，并将它们设为效果的对象。
	local g=Duel.SelectTarget(tp,c37806313.filter,tp,LOCATION_GRAVE,0,2,2,nil)
	-- 登记本连锁的“回卡组”操作信息：对象为已选中的卡，数量为选中数，用于后续相关效果检测。
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,g:GetCount(),0,0)
	-- 登记本连锁的“抽卡”操作信息：双方玩家各抽1张，用于后续相关效果检测。
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,PLAYER_ALL,1)
end
-- 效果处理：获取对象并确认其仍与效果关联且数量为2；将对象返回持有者卡组，若实际返回数量为2则洗牌，然后双方各抽1张；若数量不足2则整个处理不适用。
function c37806313.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁效果的对象卡组。
	local tg=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	if not tg or tg:FilterCount(Card.IsRelateToEffect,nil,e)~=2 then return end
	-- 将对象卡以效果原因返回持有者卡组（采用弹回卡组并洗牌的方式）。
	Duel.SendtoDeck(tg,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	-- 获取刚才送卡组操作实际处理的卡片，用于确认返回结果。
	local g=Duel.GetOperatedGroup()
	-- 若实际返回卡组的卡中有位于卡组的卡，则洗切发动玩家的卡组。
	if g:IsExists(Card.IsLocation,1,nil,LOCATION_DECK) then Duel.ShuffleDeck(tp) end
	local ct=g:FilterCount(Card.IsLocation,nil,LOCATION_DECK+LOCATION_EXTRA)
	if ct==2 then
		-- 中断当前效果处理，使此后的抽卡处理成为另一组时点，避免与回卡组同时处理。
		Duel.BreakEffect()
		-- 发动玩家抽1张卡。
		Duel.Draw(tp,1,REASON_EFFECT)
		-- 对方玩家抽1张卡。
		Duel.Draw(1-tp,1,REASON_EFFECT)
	end
end
