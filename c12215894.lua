--ブンボーグ・ベース
-- 效果：
-- ①：场上的「文具电子人」怪兽的攻击力·守备力上升500。
-- ②：1回合1次，自己主要阶段才能发动。手卡的「文具电子人」卡任意数量给对方观看，回到卡组洗切。那之后，自己从卡组抽出回到卡组的数量。
-- ③：把「文具电子人基地」以外的自己的场上·墓地的「文具电子人」卡9种类各1张除外才能发动。对方的手卡·场上·墓地的卡全部回到持有者卡组。
function c12215894.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- ①：场上的「文具电子人」怪兽的攻击力·守备力上升500。（此为攻击力上升部分的实现）
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetRange(LOCATION_FZONE)
	e2:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	-- 指定受该永续效果影响的怪兽必须满足「文具电子人」（0xab）字段。
	e2:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,0xab))
	e2:SetValue(500)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EFFECT_UPDATE_DEFENSE)
	c:RegisterEffect(e3)
	-- ②：1回合1次，自己主要阶段才能发动。手卡的「文具电子人」卡任意数量给对方观看，回到卡组洗切。那之后，自己从卡组抽出回到卡组的数量。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(12215894,0))  --"抽卡"
	e4:SetCategory(CATEGORY_TODECK+CATEGORY_DRAW)
	e4:SetType(EFFECT_TYPE_IGNITION)
	e4:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e4:SetCountLimit(1)
	e4:SetRange(LOCATION_FZONE)
	e4:SetTarget(c12215894.target)
	e4:SetOperation(c12215894.operation)
	c:RegisterEffect(e4)
	-- ③：把「文具电子人基地」以外的自己的场上·墓地的「文具电子人」卡9种类各1张除外才能发动。对方的手卡·场上·墓地的卡全部回到持有者卡组。
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(12215894,1))  --"对方卡返回卡组"
	e5:SetCategory(CATEGORY_TODECK)
	e5:SetType(EFFECT_TYPE_IGNITION)
	e5:SetRange(LOCATION_FZONE)
	e5:SetCost(c12215894.cost2)
	e5:SetTarget(c12215894.target2)
	e5:SetOperation(c12215894.operation2)
	c:RegisterEffect(e5)
end
-- ②的选牌过滤器：手牌中的「文具电子人」卡、可以返回卡组、且当前未公开的手牌。
function c12215894.filter(c)
	return c:IsSetCard(0xab) and c:IsAbleToDeck() and not c:IsPublic()
end
-- ②发动合法性检查：自己可以抽卡，且手牌中存在至少1张符合条件的「文具电子人」卡。
function c12215894.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己是否可以进行抽卡（如不受“不能抽卡”效果限制）。
	if chk==0 then return Duel.IsPlayerCanDraw(tp)
		-- 检查手牌中是否存在至少1张满足c12215894.filter的卡。
		and Duel.IsExistingMatchingCard(c12215894.filter,tp,LOCATION_HAND,0,1,nil) end
	-- 将当前连锁的对象玩家设置为自己，便于后续处理时获取抽卡玩家。
	Duel.SetTargetPlayer(tp)
	-- 设置回卡组的操作信息：分类为回卡组，对象位置为手牌，预计数量为1（满足发动检测的最小需求）。
	Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,1,tp,LOCATION_HAND)
end
-- ②的效果处理：选任意数量手卡「文具电子人」给对方确认，回卡组洗切，抽等量卡。
function c12215894.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的对象玩家（即自己），存入局部变量p。
	local p=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER)
	-- 弹出选择提示，提示内容为“请选择要返回卡组的卡”。
	Duel.Hint(HINT_SELECTMSG,p,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 让玩家p从手牌中选择1～99张满足filter的「文具电子人」卡。
	local g=Duel.SelectMatchingCard(p,c12215894.filter,p,LOCATION_HAND,0,1,99,nil)
	if g:GetCount()>0 then
		-- 将选择的手牌给对方玩家确认（对应“给对方观看”）。
		Duel.ConfirmCards(1-p,g)
		-- 将选择的卡返回持有者卡组并标记需要洗切，返回实际返回的数量ct。
		local ct=Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
		-- 洗切玩家p的卡组，使返回的卡随机化。
		Duel.ShuffleDeck(p)
		-- 中断当前效果，使后续抽卡视为不同时处理，对应“那之后”的时点。
		Duel.BreakEffect()
		-- 玩家p抽ct张卡，抽卡数量等于返回卡组的数量。
		Duel.Draw(p,ct,REASON_EFFECT)
		-- 手动洗切玩家p的手牌（重置手牌洗切检测状态）。
		Duel.ShuffleHand(p)
	end
end
-- ③的cost素材过滤器：自己场上表侧表示或墓地的「文具电子人」卡，且不是「文具电子人基地」本身，并且可以作为cost除外。
function c12215894.cfilter(c)
	return c:IsSetCard(0xab) and c:IsAbleToRemoveAsCost() and not c:IsCode(12215894)
		and (c:IsLocation(LOCATION_GRAVE) or c:IsFaceup())
end
-- ③的cost处理：从自己场上·墓地的候选卡中，选择9种类各1张（即9张卡名互不相同的卡）除外作为发动代价。
function c12215894.cost2(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取自己场上（表侧表示）以及墓地中满足cfilter的所有卡（即可以作为③cost的「文具电子人」卡）。
	local g=Duel.GetMatchingGroup(c12215894.cfilter,tp,LOCATION_GRAVE+LOCATION_ONFIELD,0,nil)
	if chk==0 then return g:GetClassCount(Card.GetCode)>=9 end
	-- 弹出选择提示，提示内容为“请选择要除外的卡”。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 设置全局附加检查函数为aux.dncheck，使后续选择时要求所选卡的卡名互不相同。
	aux.GCheckAdditional=aux.dncheck
	-- 从候选集合中选择9张卡，组成一个卡名互不相同的子组（对应9种类各1张）。
	local rg=g:SelectSubGroup(tp,aux.TRUE,false,9,9)
	-- 清除全局附加检查函数，避免影响后续其他选择。
	aux.GCheckAdditional=nil
	-- 将选择的9张卡以表侧表示除外，作为发动③的cost。
	Duel.Remove(rg,POS_FACEUP,REASON_COST)
end
-- ③发动合法性检查与操作信息设定：确认对方有可回卡组的卡，并设置回卡组的对象范围和数量。
function c12215894.target2(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查对方手牌·场上·墓地是否存在至少1张可以返回卡组的卡。
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsAbleToDeck,tp,0,LOCATION_HAND+LOCATION_ONFIELD+LOCATION_GRAVE,1,nil) end
	-- 获取对方手牌·场上·墓地中所有可以返回卡组的卡。
	local g=Duel.GetMatchingGroup(Card.IsAbleToDeck,tp,0,LOCATION_HAND+LOCATION_ONFIELD+LOCATION_GRAVE,nil)
	-- 设置本次连锁的回卡组操作信息：对象为上述全部可回卡组的卡，数量为其总数。
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,g:GetCount(),0,LOCATION_HAND+LOCATION_ONFIELD+LOCATION_GRAVE)
end
-- ③的效果处理：将对方手牌·场上·墓地的所有可回卡组的卡全部返回持有者卡组并洗切。
function c12215894.operation2(e,tp,eg,ep,ev,re,r,rp)
	-- 获取对方手牌·场上·墓地中所有可以返回卡组的卡（处理时再确认，防止中途变化）。
	local g=Duel.GetMatchingGroup(Card.IsAbleToDeck,tp,0,LOCATION_ONFIELD+LOCATION_GRAVE+LOCATION_HAND,nil)
	-- 若这些卡中有受王家长眠之谷影响的卡，则无效并终止本次效果处理。
	if aux.NecroValleyNegateCheck(g) then return end
	if g:GetCount()>0 then
		-- 将对方场上·墓地·手牌的所有可回卡组的卡返回持有者卡组，并标记洗切。
		Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	end
end
