--未界域調査報告
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：以自己场上1只「未界域」怪兽和场上1只怪兽为对象才能发动。那些怪兽回到持有者手卡。
-- ②：这张卡在墓地存在的场合，从手卡丢弃1只「未界域」怪兽才能发动。这张卡回到卡组最下面。那之后，自己从卡组抽1张。
function c25140659.initial_effect(c)
	-- ①：以自己场上1只「未界域」怪兽和场上1只怪兽为对象才能发动。那些怪兽回到持有者手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(25140659,0))
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCountLimit(1,25140659)
	e1:SetTarget(c25140659.target)
	e1:SetOperation(c25140659.activate)
	c:RegisterEffect(e1)
	-- ②：这张卡在墓地存在的场合，从手卡丢弃1只「未界域」怪兽才能发动。这张卡回到卡组最下面。那之后，自己从卡组抽1张。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(25140659,1))
	e2:SetCategory(CATEGORY_TODECK+CATEGORY_DRAW)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,25140660)
	e2:SetCost(c25140659.tdcost)
	e2:SetTarget(c25140659.tdtg)
	e2:SetOperation(c25140659.tdop)
	c:RegisterEffect(e2)
end
-- 过滤函数，用于判断场上是否存在满足条件的「未界域」怪兽（必须表侧表示、能回到手牌，并且场上存在至少一只其他怪兽）
function c25140659.filter1(c,tp)
	return c:IsFaceup() and c:IsSetCard(0x11e) and c:IsAbleToHand()
		-- 检查场上是否存在至少一只可以被选为对象的怪兽（即能回到手牌）
		and Duel.IsExistingTarget(c25140659.filter2,tp,LOCATION_MZONE,LOCATION_MZONE,1,c)
end
-- 过滤函数，用于判断场上是否存在可以被选为对象的怪兽（即能回到手牌）
function c25140659.filter2(c)
	return c:IsAbleToHand()
end
-- 设置效果处理时需要选择的两个对象：一只「未界域」怪兽和一只其他怪兽，并设置操作信息为将这两只怪兽送回手牌
function c25140659.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	-- 检查是否满足发动条件：场上是否存在至少一只「未界域」怪兽可以作为对象
	if chk==0 then return Duel.IsExistingTarget(c25140659.filter1,tp,LOCATION_MZONE,0,1,nil,tp) end
	-- 提示玩家选择要返回手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)  --"请选择要返回手牌的卡"
	-- 选择一只「未界域」怪兽作为对象
	local g1=Duel.SelectTarget(tp,c25140659.filter1,tp,LOCATION_MZONE,0,1,1,nil,tp)
	-- 提示玩家选择要返回手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)  --"请选择要返回手牌的卡"
	-- 选择一只其他怪兽作为对象
	local g2=Duel.SelectTarget(tp,c25140659.filter2,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,g1:GetFirst())
	g1:Merge(g2)
	-- 设置操作信息：将选中的两只怪兽送回手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g1,2,0,0)
end
-- 效果处理函数，将选中的怪兽送回手牌
function c25140659.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取连锁中被选中的对象卡组，并筛选出与当前效果相关的卡
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e)
	if g:GetCount()>0 then
		-- 将符合条件的卡送回手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
	end
end
-- 过滤函数，用于判断手牌中是否存在可以丢弃的「未界域」怪兽
function c25140659.costfilter(c)
	return c:IsSetCard(0x11e) and c:IsType(TYPE_MONSTER) and c:IsDiscardable()
end
-- 效果发动时的费用处理函数，丢弃一张「未界域」怪兽到墓地
function c25140659.tdcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否满足发动条件：手牌中是否存在至少一张「未界域」怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c25140659.costfilter,tp,LOCATION_HAND,0,1,nil) end
	-- 从手牌中丢弃一张「未界域」怪兽作为发动费用
	Duel.DiscardHand(tp,c25140659.costfilter,1,1,REASON_COST+REASON_DISCARD,nil)
end
-- 设置效果处理时的发动信息：将此卡送回卡组并抽一张卡
function c25140659.tdtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否满足发动条件：此卡能送回卡组且玩家可以抽卡
	if chk==0 then return e:GetHandler():IsAbleToDeck() and Duel.IsPlayerCanDraw(tp,1) end
	-- 设置操作信息：将此卡送回卡组
	Duel.SetOperationInfo(0,CATEGORY_TODECK,e:GetHandler(),1,0,0)
	-- 设置操作信息：自己抽一张卡
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
-- 效果处理函数，将此卡送回卡组最底端并抽一张卡
function c25140659.tdop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 检查此卡是否能正常送回卡组并确认其已进入卡组
	if c:IsRelateToEffect(e) and Duel.SendtoDeck(c,nil,SEQ_DECKBOTTOM,REASON_EFFECT)~=0 and c:IsLocation(LOCATION_DECK) then
		-- 中断当前效果，使后续效果处理视为不同时处理
		Duel.BreakEffect()
		-- 自己从卡组抽一张卡
		Duel.Draw(tp,1,REASON_EFFECT)
	end
end
