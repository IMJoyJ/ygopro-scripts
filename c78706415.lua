--ファイバーポッド
-- 效果：
-- 反转：双方把自己场上的卡，手卡，墓地的卡和卡组合在一起洗切。之后各自从卡组抽5张卡。
function c78706415.initial_effect(c)
	-- 反转：双方把自己场上的卡，手卡，墓地的卡和卡组合在一起洗切。之后各自从卡组抽5张卡。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TODECK+CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_FLIP)
	e1:SetTarget(c78706415.target)
	e1:SetOperation(c78706415.operation)
	c:RegisterEffect(e1)
end
-- 定义效果发动的目标处理函数
function c78706415.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 获取双方场上、手卡、墓地中未被战斗破坏确定的所有卡片
	local g=Duel.GetMatchingGroup(aux.NOT(Card.IsStatus),tp,0x1e,0x1e,nil,STATUS_BATTLE_DESTROYED)
	-- 设置操作信息，表示此效果包含将上述卡片送回卡组的操作
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,g:GetCount(),0,0x1e)
end
-- 定义效果运行的处理函数
function c78706415.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前双方场上、手卡、墓地中未被战斗破坏确定的所有卡片
	local g=Duel.GetMatchingGroup(aux.NOT(Card.IsStatus),tp,0x1e,0x1e,nil,STATUS_BATTLE_DESTROYED)
	-- 进行王家长眠之谷的无效化检测（因为涉及墓地卡片回卡组）
	if aux.NecroValleyNegateCheck(g) then return end
	-- 将这些卡片送回持有者的卡组并洗牌
	Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	-- 过滤出实际成功回到卡组的卡片组
	local tg=Duel.GetOperatedGroup():Filter(Card.IsLocation,nil,LOCATION_DECK)
	-- 若有属于自己的卡回到卡组，则洗切自己的卡组
	if tg:IsExists(Card.IsControler,1,nil,tp) then Duel.ShuffleDeck(tp) end
	-- 若有属于对方的卡回到卡组，则洗切对方的卡组
	if tg:IsExists(Card.IsControler,1,nil,1-tp) then Duel.ShuffleDeck(1-tp) end
	-- 中断效果连接，使后续的抽卡处理不与回卡组同时进行
	Duel.BreakEffect()
	-- 自己从卡组抽5张卡
	Duel.Draw(tp,5,REASON_EFFECT)
	-- 对方从卡组抽5张卡
	Duel.Draw(1-tp,5,REASON_EFFECT)
end
