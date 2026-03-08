--ファイヤー・バック
-- 效果：
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：以自己墓地1只炎属性怪兽为对象才能发动。选自己1张手卡送去墓地，作为对象的怪兽特殊召唤。
-- ②：把墓地的这张卡除外，以自己的墓地·除外状态的3只炎属性怪兽为对象才能发动。那些怪兽回到卡组。那之后，自己抽1张。
local s,id,o=GetID()
-- 注册两个效果：①效果（发动时处理）和②效果（墓地的炎属性怪兽除外才能发动）
function s.initial_effect(c)
	-- ①：以自己墓地1只炎属性怪兽为对象才能发动。选自己1张手卡送去墓地，作为对象的怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_HANDES+CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	-- ②：把墓地的这张卡除外，以自己的墓地·除外状态的3只炎属性怪兽为对象才能发动。那些怪兽回到卡组。那之后，自己抽1张。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_TODECK+CATEGORY_DRAW)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,id)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	-- 将此卡除外作为费用
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(s.drtg)
	e2:SetOperation(s.drop)
	c:RegisterEffect(e2)
end
-- 过滤满足条件的怪兽（炎属性且可特殊召唤）
function s.filter(c,e,tp)
	return c:IsAttribute(ATTRIBUTE_FIRE) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 判断①效果是否可以发动，检查手牌是否有可送去墓地的卡、场上是否有空位、墓地是否有符合条件的怪兽
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and s.filter(chkc,e,tp) end
	-- 检查手牌是否有至少一张可送去墓地的卡
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsAbleToGrave,tp,LOCATION_HAND,0,1,e:GetHandler())
		-- 检查场上是否有空位
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查墓地是否有至少一张符合条件的怪兽
		and Duel.IsExistingTarget(s.filter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 提示玩家选择要特殊召唤的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择目标怪兽
	local g=Duel.SelectTarget(tp,s.filter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置操作信息：特殊召唤目标怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- ①效果的处理函数：选择手牌送去墓地并特殊召唤目标怪兽
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要送去墓地的手卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 丢弃一张手牌到墓地
	if Duel.DiscardHand(tp,Card.IsAbleToGrave,1,1,REASON_EFFECT)<1 then return end
	-- 获取实际操作的卡组
	local gc=Duel.GetOperatedGroup():GetFirst()
	if not gc:IsLocation(LOCATION_GRAVE) then return end
	-- 获取当前连锁的目标怪兽
	local tc=Duel.GetFirstTarget()
	-- 若目标怪兽仍有效，则特殊召唤该怪兽
	if tc:IsRelateToEffect(e) then Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP) end
end
-- 过滤满足条件的怪兽（表侧表示、炎属性、可回到卡组）
function s.cfilter(c)
	return c:IsFaceupEx() and c:IsAttribute(ATTRIBUTE_FIRE) and c:IsAbleToDeck()
end
-- 判断②效果是否可以发动，检查墓地和除外状态是否有至少3张符合条件的怪兽、玩家是否可以抽卡
function s.drtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	-- 检查墓地和除外状态是否有至少3张符合条件的怪兽
	if chk==0 then return Duel.IsExistingTarget(s.cfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,3,nil)
		-- 检查玩家是否可以抽卡
		and Duel.IsPlayerCanDraw(tp,1) end
	-- 提示玩家选择要返回卡组的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 选择3张目标怪兽
	local g=Duel.SelectTarget(tp,s.cfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,3,3,nil)
	-- 设置操作信息：将目标怪兽送回卡组
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,3,0,0)
	-- 设置操作信息：抽1张卡
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
-- ②效果的处理函数：将目标怪兽送回卡组并抽卡
function s.drop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中与效果相关的怪兽组
	local g=Duel.GetTargetsRelateToChain()
	-- 将怪兽组送回卡组
	if Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)<1
		or not g:IsExists(Card.IsLocation,1,nil,LOCATION_DECK+LOCATION_EXTRA) then return end
	-- 若送回卡组的怪兽中有在卡组的，则洗切卡组
	if g:IsExists(Card.IsLocation,1,nil,LOCATION_DECK) then Duel.ShuffleDeck(tp) end
	-- 中断当前效果处理
	Duel.BreakEffect()
	-- 抽1张卡
	Duel.Draw(tp,1,REASON_EFFECT)
end
