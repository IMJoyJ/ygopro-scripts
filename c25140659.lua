--未界域調査報告
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：以自己场上1只「未界域」怪兽和场上1只怪兽为对象才能发动。那些怪兽回到持有者手卡。
-- ②：这张卡在墓地存在的场合，从手卡丢弃1只「未界域」怪兽才能发动。这张卡回到卡组最下面。那之后，自己从卡组抽1张。
function c25140659.initial_effect(c)
	-- 对应①效果：以自己场上1只「未界域」怪兽和场上1只怪兽为对象才能发动。那些怪兽回到持有者手卡。
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
	-- 对应②效果：这张卡在墓地存在的场合，从手卡丢弃1只「未界域」怪兽才能发动。这张卡回到卡组最下面。那之后，自己从卡组抽1张。
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
-- 判断作为第1个对象的「未界域」怪兽是否满足：表侧表示、属于「未界域」字段、可以回手牌，并且场上还存在另一只可以作为第2个对象（可回手牌）的怪兽。
function c25140659.filter1(c,tp)
	return c:IsFaceup() and c:IsSetCard(0x11e) and c:IsAbleToHand()
		-- 追加检查：场上（双方主要怪兽区）存在至少1只除了候选怪兽自身以外的、满足filter2（即可回手牌）的怪兽。
		and Duel.IsExistingTarget(c25140659.filter2,tp,LOCATION_MZONE,LOCATION_MZONE,1,c)
end
-- 判断怪兽是否可以被送回持有者手卡（用于筛选第2个对象）。
function c25140659.filter2(c)
	return c:IsAbleToHand()
end
-- ①效果的发动条件判定和取对象处理：先确认可以选取我方场上的未界域怪兽，然后依次选择“自己场上1只「未界域」怪兽”和“场上1只怪兽”作为对象，合并后设置回手牌的操作信息。
function c25140659.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	-- 发动条件检查：确认我方主要怪兽区存在至少1只满足filter1（即可以作为第1个对象且同时存在第2个对象）的未界域怪兽。
	if chk==0 then return Duel.IsExistingTarget(c25140659.filter1,tp,LOCATION_MZONE,0,1,nil,tp) end
	-- 弹出选择提示，提示玩家选择要返回手牌的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)  --"请选择要返回手牌的卡"
	-- 选择1只我方场上的「未界域」怪兽作为第1个对象。
	local g1=Duel.SelectTarget(tp,c25140659.filter1,tp,LOCATION_MZONE,0,1,1,nil,tp)
	-- 再次弹出选择提示，提示玩家选择要返回手牌的第2张卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)  --"请选择要返回手牌的卡"
	-- 选择场上（双方主要怪兽区）1只除第1个对象以外的、可回手牌的怪兽作为第2个对象。
	local g2=Duel.SelectTarget(tp,c25140659.filter2,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,g1:GetFirst())
	g1:Merge(g2)
	-- 设置本次连锁的处理信息：将对象组g1（共2张卡）作为回手牌效果的处理对象，数量为2。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g1,2,0,0)
end
-- ①效果处理：取回当前连锁的对象卡，过滤出仍与效果相关的卡，将它们返回持有者手卡。
function c25140659.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁登记的对象卡组，并仅保留仍然与效果e有联系的卡（即对象仍合法且未被移走等情况）。
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e)
	if g:GetCount()>0 then
		-- 将过滤后的对象卡返回其持有者手卡，送回原因视为效果。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
	end
end
-- cost筛选：判断手卡中的怪兽能否作为②效果的代价丢弃，条件是：属于「未界域」字段、是怪兽卡、并且可以被丢弃。
function c25140659.costfilter(c)
	return c:IsSetCard(0x11e) and c:IsType(TYPE_MONSTER) and c:IsDiscardable()
end
-- ②效果的代价处理：先检查手牌是否存在可丢弃的「未界域」怪兽，若有则从中选择1张丢弃作为发动代价。
function c25140659.tdcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 代价判定：检查手牌中是否存在至少1张满足costfilter的「未界域」怪兽，以决定能否支付代价。
	if chk==0 then return Duel.IsExistingMatchingCard(c25140659.costfilter,tp,LOCATION_HAND,0,1,nil) end
	-- 实际支付代价：从手牌选择并丢弃1张满足costfilter的「未界域」怪兽，丢弃原因记为“代价+丢弃”。
	Duel.DiscardHand(tp,c25140659.costfilter,1,1,REASON_COST+REASON_DISCARD,nil)
end
-- ②效果的目标与发动条件判定：确认墓地的这张卡能回到卡组且自己可以抽1张卡，并设置后续“回卡组”和“抽卡”的操作信息。
function c25140659.tdtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动条件检查：这张卡自身能够回到卡组，并且自己当前可以进行1张抽卡。
	if chk==0 then return e:GetHandler():IsAbleToDeck() and Duel.IsPlayerCanDraw(tp,1) end
	-- 设置操作信息：将这张卡（墓地中的这张卡）返回卡组，数量为1。
	Duel.SetOperationInfo(0,CATEGORY_TODECK,e:GetHandler(),1,0,0)
	-- 设置操作信息：自己抽1张卡，抽卡对象暂不确定。
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
-- ②效果处理：若这张卡仍与效果相关，将其送回卡组最下面；成功回到卡组后，中断效果处理，然后自己抽1张卡。
function c25140659.tdop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 判断条件：这张卡仍与效果关联，且成功以效果送回卡组最下面（返回值非0），并且确实处于卡组区域。
	if c:IsRelateToEffect(e) and Duel.SendtoDeck(c,nil,SEQ_DECKBOTTOM,REASON_EFFECT)~=0 and c:IsLocation(LOCATION_DECK) then
		-- 中断当前效果的处理，使后续的抽卡效果视为不同时进行处理，以避开原有连锁的时点。
		Duel.BreakEffect()
		-- 自己抽1张卡，抽卡原因视为效果。
		Duel.Draw(tp,1,REASON_EFFECT)
	end
end
