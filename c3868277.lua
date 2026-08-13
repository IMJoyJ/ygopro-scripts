--TGX3－DX2
-- 效果：
-- 选择自己墓地存在的3只名字带有「科技属」的怪兽发动。选择的怪兽加入卡组洗切。那之后，从自己卡组抽2张卡。
function c3868277.initial_effect(c)
	-- 选择自己墓地存在的3只名字带有「科技属」的怪兽发动。选择的怪兽加入卡组洗切。那之后，从自己卡组抽2张卡。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TODECK+CATEGORY_DRAW)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c3868277.target)
	e1:SetOperation(c3868277.activate)
	c:RegisterEffect(e1)
end
-- 筛选自己墓地中满足以下条件的怪兽：是怪兽卡、拥有「科技属」字段、并且可以被送回卡组。
function c3868277.filter(c)
	return c:IsType(TYPE_MONSTER) and c:IsSetCard(0x27) and c:IsAbleToDeck()
end
-- 效果发动时的目标选择与合法性检查：确认可以抽2张卡，并将自己墓地3只符合条件的「科技属」怪兽作为取对象目标。
function c3868277.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c3868277.filter(chkc) end
	-- 发动条件判定：确认自己玩家可以抽2张卡。
	if chk==0 then return Duel.IsPlayerCanDraw(tp,2)
		-- 发动条件判定：确认自己墓地存在至少3只满足筛选条件的「科技属」怪兽可供选择。
		and Duel.IsExistingTarget(c3868277.filter,tp,LOCATION_GRAVE,0,3,nil) end
	-- 向玩家显示“请选择要返回卡组的卡”的选择提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 选择自己墓地3只满足条件的「科技属」怪兽作为效果对象，并设定为当前连锁的对象卡。
	local g=Duel.SelectTarget(tp,c3868277.filter,tp,LOCATION_GRAVE,0,3,3,nil)
	-- 设定操作信息：将选中的对象卡送回卡组，回卡组数量为选择的数量。
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,g:GetCount(),0,0)
	-- 设定操作信息：自己玩家将进行抽2张卡的抽卡效果。
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,2)
end
-- 效果处理：取出对象，确认对象仍与效果关联且数量为3后，将其全部送回卡组并洗牌；若实际回卡组数量为3，则再执行抽2张卡。
function c3868277.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取发动时选择的对象卡组。
	local tg=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	if not tg or tg:FilterCount(Card.IsRelateToEffect,nil,e)~=3 then return end
	-- 将对象卡以效果原因送回其持有者卡组，使用弹回卡组并洗牌的处理方式。
	Duel.SendtoDeck(tg,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	-- 取得刚刚因效果被送回卡组的实际卡片组。
	local g=Duel.GetOperatedGroup()
	-- 如果实际回卡组的卡中有位于卡组的卡，则洗切自己卡组。
	if g:IsExists(Card.IsLocation,1,nil,LOCATION_DECK) then Duel.ShuffleDeck(tp) end
	local ct=g:FilterCount(Card.IsLocation,nil,LOCATION_DECK+LOCATION_EXTRA)
	if ct==3 then
		-- 中断当前效果处理，使后续抽卡处理与回卡组处理不同时进行，避免错过时点。
		Duel.BreakEffect()
		-- 自己玩家以效果原因抽2张卡。
		Duel.Draw(tp,2,REASON_EFFECT)
	end
end
