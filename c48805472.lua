--蟲惑の誘い
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：把1只昆虫族·植物族的4星怪兽或者1张通常陷阱卡从手卡丢弃才能发动。自己从卡组抽2张。
-- ②：把墓地的这张卡除外，以除外的自己1只昆虫族·植物族的4星怪兽或者1张通常陷阱卡为对象才能发动。那张卡回到卡组最下面。
local s,id,o=GetID()
-- 注册两个效果，分别为①抽卡效果和②回收效果
function s.initial_effect(c)
	-- ①：把1只昆虫族·植物族的4星怪兽或者1张通常陷阱卡从手卡丢弃才能发动。自己从卡组抽2张。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"抽卡"
	e1:SetCategory(CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	-- ②：把墓地的这张卡除外，以除外的自己1只昆虫族·植物族的4星怪兽或者1张通常陷阱卡为对象才能发动。那张卡回到卡组最下面。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"回收"
	e2:SetCategory(CATEGORY_TODECK)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,id+o)
	-- 效果②的发动需要将此卡除外作为代价
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(s.tdtg)
	e2:SetOperation(s.tdop)
	c:RegisterEffect(e2)
end
-- 定义过滤函数，用于判断是否为昆虫族或植物族4星怪兽或通常陷阱卡
function s.filter(c)
	return c:IsRace(RACE_INSECT+RACE_PLANT) and c:IsLevel(4) or c:GetType()==TYPE_TRAP
end
-- 定义丢弃过滤函数，用于判断手牌中可丢弃的符合条件的卡片
function s.cfilter(c)
	return c:IsDiscardable() and s.filter(c)
end
-- 效果①的发动费用，需要从手牌中丢弃一张符合条件的卡片
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否满足效果①的发动条件，即手牌中是否存在符合条件的卡片
	if chk==0 then return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_HAND,0,1,nil) end
	-- 执行丢弃操作，丢弃一张符合条件的手牌
	Duel.DiscardHand(tp,s.cfilter,1,1,REASON_COST+REASON_DISCARD)
end
-- 效果①的发动宣言阶段，判断玩家是否可以抽2张卡并设置目标
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否满足效果①的发动条件，即玩家是否可以抽2张卡
	if chk==0 then return Duel.IsPlayerCanDraw(tp,2) end
	-- 设置效果①的目标玩家为当前玩家
	Duel.SetTargetPlayer(tp)
	-- 设置效果①的目标参数为抽2张卡
	Duel.SetTargetParam(2)
	-- 设置效果①的操作信息为抽卡效果
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,2)
end
-- 效果①的处理阶段，执行抽卡操作
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取连锁中设定的目标玩家和目标参数
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 执行抽卡操作，抽指定数量的卡
	Duel.Draw(p,d,REASON_EFFECT)
end
-- 定义回收效果的过滤函数，用于判断是否为可送回卡组的卡片
function s.tdfilter(c)
	return c:IsFaceup() and c:IsAbleToDeck() and s.filter(c)
end
-- 效果②的发动宣言阶段，选择一个符合条件的除外卡片作为对象
function s.tdtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_REMOVED) and chkc:IsControler(tp) and s.tdfilter(chkc) end
	-- 检查是否满足效果②的发动条件，即是否存在符合条件的除外卡片
	if chk==0 then return Duel.IsExistingTarget(s.tdfilter,tp,LOCATION_REMOVED,0,1,nil) end
	-- 提示玩家选择要送回卡组的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 选择一个符合条件的除外卡片作为目标
	local g=Duel.SelectTarget(tp,s.tdfilter,tp,LOCATION_REMOVED,0,1,1,nil)
	-- 设置效果②的操作信息为送回卡组效果
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,1,0,0)
end
-- 效果②的处理阶段，将目标卡片送回卡组最底端
function s.tdop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的目标卡片
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标卡片送回卡组最底端
		Duel.SendtoDeck(tc,nil,SEQ_DECKBOTTOM,REASON_EFFECT)
	end
end
