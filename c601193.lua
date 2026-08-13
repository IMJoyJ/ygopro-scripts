--彼岸の詩人 ウェルギリウス
-- 效果：
-- 调整＋调整以外的怪兽1只以上
-- 「彼岸的诗人 维吉尔」的③的效果1回合只能使用1次。
-- ①：「彼岸的诗人 维吉尔」在自己场上只能有1只表侧表示存在。
-- ②：1回合1次，从手卡丢弃1张「彼岸」卡，以对方的场上·墓地1张卡为对象才能发动。那张卡回到持有者卡组。
-- ③：场上的这张卡被战斗·效果破坏送去墓地的场合才能发动。自己从卡组抽1张。
function c601193.initial_effect(c)
	c:SetUniqueOnField(1,0,601193)
	-- 为这张卡添加同调召唤设定：调整＋调整以外的怪兽1只以上（这里调整无种类限制，非调整也无种类限制）。
	aux.AddSynchroProcedure(c,nil,aux.NonTuner(nil),1)
	c:EnableReviveLimit()
	-- ②：1回合1次，从手卡丢弃1张「彼岸」卡，以对方的场上·墓地1张卡为对象才能发动。那张卡回到持有者卡组。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(601193,0))  --"弹回卡组"
	e1:SetCategory(CATEGORY_TODECK)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCost(c601193.tdcost)
	e1:SetTarget(c601193.tdtg)
	e1:SetOperation(c601193.tdop)
	c:RegisterEffect(e1)
	-- 「彼岸的诗人 维吉尔」的③的效果1回合只能使用1次。③：场上的这张卡被战斗·效果破坏送去墓地的场合才能发动。自己从卡组抽1张。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(601193,1))  --"抽卡"
	e2:SetCategory(CATEGORY_DRAW)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetCountLimit(1,601193)
	e2:SetCondition(c601193.drcon)
	e2:SetTarget(c601193.drtg)
	e2:SetOperation(c601193.drop)
	c:RegisterEffect(e2)
end
-- 代价过滤函数：筛选手牌中持有「彼岸」字段（0xb1）且可以被丢弃的卡。
function c601193.filter(c)
	return c:IsSetCard(0xb1) and c:IsDiscardable()
end
-- ②效果的代价处理函数：确认并执行从手卡丢弃1张「彼岸」卡作为发动代价。
function c601193.tdcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 代价确认阶段：检查自己手牌中是否存在至少1张满足条件的「彼岸」卡可供丢弃。
	if chk==0 then return Duel.IsExistingMatchingCard(c601193.filter,tp,LOCATION_HAND,0,1,nil) end
	-- 执行代价：从手卡中选择并丢弃1张「彼岸」卡（丢弃原因包含COST与DISCARD）。
	Duel.DiscardHand(tp,c601193.filter,1,1,REASON_COST+REASON_DISCARD)
end
-- ②效果的发动目标筛选函数：选择对方场上·墓地的1张卡作为对象，该卡需能够返回卡组。
function c601193.tdtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_ONFIELD+LOCATION_GRAVE) and chkc:IsControler(1-tp) and chkc:IsAbleToDeck() end
	-- 对象确认阶段：检查对方场上·墓地是否存在至少1张可返回卡组的卡作为效果对象。
	if chk==0 then return Duel.IsExistingTarget(Card.IsAbleToDeck,tp,0,LOCATION_ONFIELD+LOCATION_GRAVE,1,nil) end
	-- 向操作者显示选择提示：请选择要返回卡组的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 优先从对方场上选择可回卡组的卡，若场上合法对象不足则从墓地选择；返回选中对象组（1张）。
	local g=aux.SelectTargetFromFieldFirst(tp,Card.IsAbleToDeck,tp,0,LOCATION_ONFIELD+LOCATION_GRAVE,1,1,nil)
	-- 设置回卡组效果的处理信息：确定本连锁将执行回卡组操作，对象为选中的卡。
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,1,0,0)
end
-- ②效果处理函数：将对象卡送回持有者卡组并洗切（若对象仍合法）。
function c601193.tdop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取本次效果连锁的第一个对象卡。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将对象卡以效果原因送回持有者卡组，并标记需要洗切卡组。
		Duel.SendtoDeck(tc,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	end
end
-- ③效果的触发条件：这张卡从场上被战斗或效果破坏并送去墓地时，满足场合型触发条件。
function c601193.drcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsPreviousLocation(LOCATION_ONFIELD) and c:IsReason(REASON_DESTROY) and c:IsReason(REASON_BATTLE+REASON_EFFECT)
end
-- ③效果的发动目标函数：进行发动判定，并设置目标玩家与参数为抽1张，同时写入抽卡操作信息。
function c601193.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 抽卡确认：检查效果发动者是否能够抽1张卡。
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1) end
	-- 将执行抽卡的对象玩家设置为当前效果发动者tp。
	Duel.SetTargetPlayer(tp)
	-- 将抽卡数量参数设置为1。
	Duel.SetTargetParam(1)
	-- 设置抽卡效果的操作信息：连锁处理时将执行从卡组抽卡，对象玩家为tp，抽卡数量为1。
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
-- ③效果处理函数：根据记录的信息执行抽卡。
function c601193.drop(e,tp,eg,ep,ev,re,r,rp)
	-- 从当前连锁信息中取出之前设置的对象玩家p和抽卡数量d。
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 让玩家p以效果原因抽d张卡。
	Duel.Draw(p,d,REASON_EFFECT)
end
