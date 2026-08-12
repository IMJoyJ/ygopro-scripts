--原初のスープ
-- 效果：
-- 1回合1次，自己的主要阶段时才能发动。让手卡最多2只名字带有「进化龙」的怪兽回到卡组洗切，并从卡组抽出回去数量的卡。「原初之液」在自己场上只能有1张表侧表示存在。
function c78933589.initial_effect(c)
	c:SetUniqueOnField(1,0,78933589)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- 1回合1次，自己的主要阶段时才能发动。让手卡最多2只名字带有「进化龙」的怪兽回到卡组洗切，并从卡组抽出回去数量的卡。
	local e2=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(78933589,0))  --"手牌交换"
	e2:SetCategory(CATEGORY_TODECK+CATEGORY_DRAW)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1)
	e2:SetTarget(c78933589.target)
	e2:SetOperation(c78933589.activate)
	c:RegisterEffect(e2)
end
-- 过滤手牌中名字带有「进化龙」且可以回到卡组的怪兽卡
function c78933589.filter(c)
	return c:IsSetCard(0x604e) and c:IsAbleToDeck()
end
-- 效果发动的可行性检测：检查玩家是否可以抽卡，以及手牌中是否存在至少1张满足过滤条件的卡
function c78933589.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家当前是否具有抽卡的效果许可（至少能抽1张卡）
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1)
		-- 检查手牌中是否存在至少1张可以回到卡组的「进化龙」怪兽
		and Duel.IsExistingMatchingCard(c78933589.filter,tp,LOCATION_HAND,0,1,nil) end
	-- 设置连锁信息：预计将手牌中的至少1张卡送回卡组
	Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,1,tp,LOCATION_HAND)
	-- 设置连锁信息：预计让玩家抽至少1张卡
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
-- 效果处理的核心逻辑：验证合法性，计算最大可返回卡数，让玩家选择手牌中的「进化龙」怪兽送回卡组洗切，并抽取对应数量的卡
function c78933589.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 检查此卡是否仍在场上，以及玩家当前是否仍能抽卡，若不满足则不处理效果
	if not e:GetHandler():IsRelateToEffect(e) or not Duel.IsPlayerCanDraw(tp) then return end
	-- 获取玩家卡组中剩余的卡片数量
	local ct=Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)
	if ct==0 then return end
	if ct>2 then ct=2 end
	-- 给玩家发送提示信息，要求选择要返回卡组的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 让玩家从手牌中选择1张到ct张（最多2张）满足条件的「进化龙」怪兽
	local g=Duel.SelectMatchingCard(tp,c78933589.filter,tp,LOCATION_HAND,0,1,ct,nil)
	if g:GetCount()>0 then
		-- 给对方玩家确认选中的手牌怪兽
		Duel.ConfirmCards(1-tp,g)
		-- 将选中的怪兽卡送回持有者的卡组
		Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
		-- 手动洗切玩家的卡组
		Duel.ShuffleDeck(tp)
		-- 中断当前效果处理，使后续的抽卡动作与回卡组动作不视为同时处理
		Duel.BreakEffect()
		-- 让玩家从卡组抽出与送回卡组数量相同的卡
		Duel.Draw(tp,g:GetCount(),REASON_EFFECT)
	end
end
