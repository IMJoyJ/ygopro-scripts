--星呼びの天儀台
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：从手卡以及自己场上的表侧表示怪兽之中让1只6星怪兽回到持有者卡组最下面才能发动。自己从卡组抽2张。
function c67378104.initial_effect(c)
	-- 这个卡名的卡在1回合只能发动1张。①：从手卡以及自己场上的表侧表示怪兽之中让1只6星怪兽回到持有者卡组最下面才能发动。自己从卡组抽2张。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,67378104+EFFECT_COUNT_CODE_OATH)
	e1:SetCost(c67378104.cost)
	e1:SetTarget(c67378104.target)
	e1:SetOperation(c67378104.activate)
	c:RegisterEffect(e1)
end
-- 过滤手卡中或自己场上表侧表示的、可以作为代价返回卡组的6星怪兽
function c67378104.filter(c)
	return c:IsLevel(6) and (c:IsFaceup() or not c:IsLocation(LOCATION_MZONE)) and c:IsAbleToDeckAsCost()
end
-- 检查并执行发动代价：将手卡或自己场上表侧表示的一只6星怪兽送回持有者卡组最下面
function c67378104.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查手卡或自己场上是否存在至少1只满足条件的6星怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c67378104.filter,tp,LOCATION_HAND+LOCATION_MZONE,0,1,nil) end
	-- 给玩家发送提示信息，提示选择要返回卡组的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 让玩家选择1只手卡或自己场上表侧表示的满足条件的6星怪兽
	local g=Duel.SelectMatchingCard(tp,c67378104.filter,tp,LOCATION_HAND+LOCATION_MZONE,0,1,1,nil)
	-- 给对方玩家确认选中的卡片
	Duel.ConfirmCards(1-tp,g)
	-- 作为发动代价，将选中的怪兽送回持有者卡组最下面
	Duel.SendtoDeck(g,nil,SEQ_DECKBOTTOM,REASON_COST)
end
-- 检查玩家是否能抽卡，并设置效果处理所需的对象玩家、参数和操作信息
function c67378104.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己是否可以从卡组抽2张卡
	if chk==0 then return Duel.IsPlayerCanDraw(tp,2) end
	-- 将当前连锁的对象玩家设置为自己
	Duel.SetTargetPlayer(tp)
	-- 将当前连锁的对象参数设置为2（抽卡数量）
	Duel.SetTargetParam(2)
	-- 设置当前连锁的操作信息为：自己从卡组抽2张卡
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,2)
end
-- 效果处理：获取目标玩家和抽卡数量，执行抽卡效果
function c67378104.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁设定的目标玩家和抽卡数量
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 让目标玩家因效果抽指定数量的卡
	Duel.Draw(p,d,REASON_EFFECT)
end
