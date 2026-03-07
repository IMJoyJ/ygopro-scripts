--リンク・ディサイプル
-- 效果：
-- 4星以下的电子界族怪兽1只
-- 这个卡名的效果1回合只能使用1次。
-- ①：把这张卡所连接区1只怪兽解放才能发动。自己从卡组抽1张，那之后选1张手卡回到卡组最下面。
function c32995276.initial_effect(c)
	c:EnableReviveLimit()
	-- 为卡片添加连接召唤手续，要求使用1张等级4以下且为电子界族的怪兽作为连接素材
	aux.AddLinkProcedure(c,c32995276.matfilter,1,1)
	-- ①：把这张卡所连接区1只怪兽解放才能发动。自己从卡组抽1张，那之后选1张手卡回到卡组最下面。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(32995276,0))
	e1:SetCategory(CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,32995276)
	e1:SetCost(c32995276.cost)
	e1:SetTarget(c32995276.target)
	e1:SetOperation(c32995276.operation)
	c:RegisterEffect(e1)
end
-- 过滤函数，用于判断连接素材是否满足等级4以下且为电子界族的条件
function c32995276.matfilter(c)
	return c:IsLevelBelow(4) and c:IsLinkRace(RACE_CYBERSE)
end
-- 过滤函数，用于判断所选怪兽是否在连接区中
function c32995276.cfilter(c,g)
	return g:IsContains(c)
end
-- 效果的费用支付处理，检查并选择1只可解放的连接区怪兽进行解放
function c32995276.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	local lg=e:GetHandler():GetLinkedGroup()
	-- 判断是否可以支付费用，检查是否存在满足条件的连接区怪兽
	if chk==0 then return Duel.CheckReleaseGroup(tp,c32995276.cfilter,1,nil,lg) end
	-- 从满足条件的连接区怪兽中选择1只进行解放
	local g=Duel.SelectReleaseGroup(tp,c32995276.cfilter,1,1,nil,lg)
	-- 将选中的怪兽以支付费用的方式进行解放
	Duel.Release(g,REASON_COST)
end
-- 效果的目标设定处理，确认玩家可以抽卡并设置连锁操作信息
function c32995276.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断是否可以抽卡，检查玩家是否可以抽1张卡
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1) end
	-- 设置连锁的目标玩家为效果使用者
	Duel.SetTargetPlayer(tp)
	-- 设置连锁的目标参数为抽卡数量1
	Duel.SetTargetParam(1)
	-- 设置连锁的操作信息为抽卡效果
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
-- 效果的发动处理，执行抽卡并选择手牌返回卡组底端
function c32995276.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取连锁的目标玩家和目标参数（抽卡数量）
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 执行抽卡效果，若未成功则返回
	if Duel.Draw(p,d,REASON_EFFECT)==0 then return end
	-- 提示玩家选择要返回卡组底端的手牌
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 从玩家手牌中选择1张可送回卡组底端的卡
	local g=Duel.SelectMatchingCard(tp,Card.IsAbleToDeck,tp,LOCATION_HAND,0,1,1,nil)
	if g:GetCount()>0 then
		-- 中断当前效果处理，使后续处理视为错时点
		Duel.BreakEffect()
		-- 将选中的手牌以送回卡组底端的方式进行处理
		Duel.SendtoDeck(g,nil,SEQ_DECKBOTTOM,REASON_EFFECT)
	end
end
