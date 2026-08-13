--グラディアル・リターン
-- 效果：
-- 墓地存在的3张名字带有「剑斗兽」的卡回到卡组。那之后，从自己卡组抽1张卡。
function c24285858.initial_effect(c)
	-- 墓地存在的3张名字带有「剑斗兽」的卡回到卡组。那之后，从自己卡组抽1张卡。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TODECK+CATEGORY_DRAW)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c24285858.target)
	e1:SetOperation(c24285858.activate)
	c:RegisterEffect(e1)
end
-- 筛选出名字带有「剑斗兽」且能够回到卡组的卡，作为效果处理时可选择的对象。
function c24285858.filter(c)
	return c:IsSetCard(0x1019) and c:IsAbleToDeck()
end
-- 效果发动时的目标选择函数：确认对象为墓地中由我方持有的3张符合条件的「剑斗兽」卡，并检查我方能否抽1张卡；若为连锁处理选择对象时，则检查对象是否位于墓地且满足筛选条件。
function c24285858.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c24285858.filter(chkc) end
	-- 在效果发动合法性检查时，确认我方玩家可以进行1张抽卡（不会被“不能抽卡”效果限制）。
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1)
		-- 同时确认墓地存在至少3张满足条件且可以被选择为对象的「剑斗兽」卡（满足回卡组部分的条件）。
		and Duel.IsExistingTarget(c24285858.filter,tp,LOCATION_GRAVE,0,3,nil) end
	-- 向玩家显示“请选择要返回卡组的卡”的提示消息，用于选择卡片的提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 让玩家从自己墓地选择3张满足条件的「剑斗兽」卡作为效果对象，并同时将其登记为本连锁的对象。
	local g=Duel.SelectTarget(tp,c24285858.filter,tp,LOCATION_GRAVE,0,3,3,nil)
	-- 设置本次效果处理的操作信息：分类为“回卡组”，对象为选择的g张卡，数量为g的数量，用于后续相关效果检测（如星尘龙等）。
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,g:GetCount(),0,0)
	-- 设置本次效果操作信息：分类为“抽卡”，对象为不确定（nil），数量为1，抽卡玩家为tp，用于后续抽卡相关效果检测。
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
-- 效果处理时的执行函数：取得连锁对象；确认对象仍然有效且数量为3；将对象返回卡组并洗牌；如果3张都返回成功（在卡组/额外），则中断效果后抽1张卡。
function c24285858.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁处理中记录的对象卡组（即发动时选择的3张卡）。
	local tg=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	if not tg or tg:FilterCount(Card.IsRelateToEffect,nil,e)~=3 then return end
	-- 将对象卡返回持有者卡组，并标记需要洗牌（SEQ_DECKSHUFFLE）；原因视为效果处理。
	Duel.SendtoDeck(tg,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	-- 获取刚刚被送回卡组的实际操作的卡片组（用于确认实际返回成功的卡）。
	local g=Duel.GetOperatedGroup()
	-- 如果返回卡组后其中有卡存在于卡组，则洗切我方卡组（因为卡组顺序可能变化）。
	if g:IsExists(Card.IsLocation,1,nil,LOCATION_DECK) then Duel.ShuffleDeck(tp) end
	local ct=g:FilterCount(Card.IsLocation,nil,LOCATION_DECK+LOCATION_EXTRA)
	if ct==3 then
		-- 中断当前效果的处理流程，使后续的抽卡处理与前段的回卡组处理视为不同时处理，避免错误的时点/连锁判定。
		Duel.BreakEffect()
		-- 让我方玩家因效果抽1张卡。
		Duel.Draw(tp,1,REASON_EFFECT)
	end
end
