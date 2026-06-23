--コア濃度圧縮
-- 效果：
-- 把手卡1张「核成兽的钢核」给对方观看，从手卡丢弃1只名字带有「核成」的怪兽发动。从自己卡组抽2张卡。
function c13997673.initial_effect(c)
	-- 为卡片注册「核成兽的钢核」的卡片代码，用于后续效果判断
	aux.AddCodeList(c,36623431)
	-- 把手卡1张「核成兽的钢核」给对方观看，从手卡丢弃1只名字带有「核成」的怪兽发动。从自己卡组抽2张卡。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCost(c13997673.cost)
	e1:SetTarget(c13997673.target)
	e1:SetOperation(c13997673.activate)
	c:RegisterEffect(e1)
end
-- 过滤函数：检查手卡中是否存在未公开的「核成兽的钢核」
function c13997673.cfilter1(c)
	return c:IsCode(36623431) and not c:IsPublic()
end
-- 过滤函数：检查手卡中是否存在可丢弃的「核成」怪兽
function c13997673.cfilter2(c)
	return c:IsType(TYPE_MONSTER) and c:IsSetCard(0x1d) and c:IsDiscardable()
end
-- 效果发动时的费用处理函数
function c13997673.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断是否满足发动条件：手卡存在未公开的「核成兽的钢核」
	if chk==0 then return Duel.IsExistingMatchingCard(c13997673.cfilter1,tp,LOCATION_HAND,0,1,nil)
		-- 判断是否满足发动条件：手卡存在可丢弃的「核成」怪兽
		and Duel.IsExistingMatchingCard(c13997673.cfilter2,tp,LOCATION_HAND,0,1,nil) end
	-- 向玩家提示选择要确认的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)
	-- 选择1张手卡中的「核成兽的钢核」并展示给对方玩家
	local g1=Duel.SelectMatchingCard(tp,c13997673.cfilter1,tp,LOCATION_HAND,0,1,1,nil)
	-- 将选择的「核成兽的钢核」展示给对方玩家
	Duel.ConfirmCards(1-tp,g1)
	-- 向玩家提示选择要丢弃的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISCARD)
	-- 选择1张手卡中的「核成」怪兽
	local g2=Duel.SelectMatchingCard(tp,c13997673.cfilter2,tp,LOCATION_HAND,0,1,1,nil)
	-- 将选择的「核成」怪兽送入墓地作为发动费用
	Duel.SendtoGrave(g2,REASON_COST+REASON_DISCARD)
	-- 将玩家手牌洗牌
	Duel.ShuffleHand(tp)
end
-- 效果发动时的目标设定函数
function c13997673.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断玩家是否可以抽2张卡
	if chk==0 then return Duel.IsPlayerCanDraw(tp,2) end
	-- 设置连锁效果的目标玩家为当前玩家
	Duel.SetTargetPlayer(tp)
	-- 设置连锁效果的目标参数为2
	Duel.SetTargetParam(2)
	-- 设置连锁效果的操作信息为抽2张卡
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,2)
end
-- 效果发动时的处理函数
function c13997673.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取连锁效果的目标玩家和参数
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 使目标玩家抽指定数量的卡
	Duel.Draw(p,d,REASON_EFFECT)
end
