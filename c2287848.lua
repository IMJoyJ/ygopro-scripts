--ヴェンデット・リバース
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：丢弃1张手卡，以自己墓地1只「复仇死者」怪兽和1张仪式魔法卡为对象才能发动。那只怪兽守备表示特殊召唤，那张仪式魔法卡加入手卡。
-- ②：把墓地的这张卡除外，以除外的5只自己的不死族怪兽为对象才能发动。那些怪兽加入卡组洗切。那之后，自己从卡组抽1张。
function c2287848.initial_effect(c)
	-- ①：丢弃1张手卡，以自己墓地1只「复仇死者」怪兽和1张仪式魔法卡为对象才能发动。那只怪兽守备表示特殊召唤，那张仪式魔法卡加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCountLimit(1,2287848)
	e1:SetCost(c2287848.cost)
	e1:SetTarget(c2287848.target)
	e1:SetOperation(c2287848.activate)
	c:RegisterEffect(e1)
	-- ②：把墓地的这张卡除外，以除外的5只自己的不死族怪兽为对象才能发动。那些怪兽加入卡组洗切。那之后，自己从卡组抽1张。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_TODECK+CATEGORY_DRAW)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetCountLimit(1,2287849)
	-- 将此卡除外作为cost
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(c2287848.drtg)
	e2:SetOperation(c2287848.drop)
	c:RegisterEffect(e2)
end
-- 丢弃1张手卡作为cost
function c2287848.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家手牌是否存在可丢弃的卡
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,nil) end
	-- 执行丢弃1张手卡的操作
	Duel.DiscardHand(tp,Card.IsDiscardable,1,1,REASON_COST+REASON_DISCARD)
end
-- 筛选墓地中的复仇死者怪兽
function c2287848.spfilter(c,e,tp)
	return c:IsSetCard(0x106) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
end
-- 筛选墓地中的仪式魔法卡
function c2287848.thfilter(c)
	return c:GetType()==TYPE_SPELL+TYPE_RITUAL and c:IsAbleToHand()
end
-- 设置效果的发动条件，检查是否满足特殊召唤和加入手牌的条件
function c2287848.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	-- 检查玩家场上是否存在可特殊召唤的空间
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.IsExistingTarget(c2287848.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp)
		-- 检查玩家墓地是否存在满足条件的仪式魔法卡
		and Duel.IsExistingTarget(c2287848.thfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择满足条件的复仇死者怪兽作为目标
	local g1=Duel.SelectTarget(tp,c2287848.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	e:SetLabelObject(g1:GetFirst())
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择满足条件的仪式魔法卡作为目标
	local g2=Duel.SelectTarget(tp,c2287848.thfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 设置操作信息，表示将特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g1,1,0,0)
	-- 设置操作信息，表示将1张卡加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g2,1,0,0)
end
-- 处理效果的发动，执行特殊召唤和加入手牌的操作
function c2287848.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的目标卡
	local tc1,tc2=Duel.GetFirstTarget()
	if tc1~=e:GetLabelObject() then tc1,tc2=tc2,tc1 end
	-- 判断目标卡是否有效并执行特殊召唤和加入手牌
	if tc1:IsRelateToEffect(e) and Duel.SpecialSummon(tc1,0,tp,tp,false,false,POS_FACEUP_DEFENSE)~=0 and tc2:IsRelateToEffect(e) then
		-- 将目标仪式魔法卡加入手牌
		Duel.SendtoHand(tc2,nil,REASON_EFFECT)
	end
end
-- 筛选场上的不死族怪兽
function c2287848.drfilter(c)
	return c:IsFaceup() and c:IsRace(RACE_ZOMBIE) and c:IsAbleToDeck()
end
-- 设置效果的发动条件，检查是否满足将5只不死族怪兽送回卡组的条件
function c2287848.drtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_REMOVED) and chkc:IsControler(tp) and c2287848.drfilter(chkc) end
	-- 检查玩家是否可以抽卡
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1)
		-- 检查玩家墓地是否存在满足条件的不死族怪兽
		and Duel.IsExistingTarget(c2287848.drfilter,tp,LOCATION_REMOVED,0,5,nil) end
	-- 提示玩家选择要返回卡组的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 选择满足条件的5只不死族怪兽作为目标
	local g=Duel.SelectTarget(tp,c2287848.drfilter,tp,LOCATION_REMOVED,0,5,5,nil)
	-- 设置操作信息，表示将5只卡送回卡组
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,5,0,0)
	-- 设置操作信息，表示抽1张卡
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
-- 处理效果的发动，执行送回卡组和抽卡的操作
function c2287848.drop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的目标卡组
	local tg=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	if not tg or tg:FilterCount(Card.IsRelateToEffect,nil,e)<=0 then return end
	-- 将目标卡送回卡组并洗切
	Duel.SendtoDeck(tg,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	-- 获取实际操作的卡组
	local g=Duel.GetOperatedGroup()
	-- 若送回卡组的卡中有卡在卡组，则洗切卡组
	if g:IsExists(Card.IsLocation,1,nil,LOCATION_DECK) then Duel.ShuffleDeck(tp) end
	local ct=g:FilterCount(Card.IsLocation,nil,LOCATION_DECK+LOCATION_EXTRA)
	if ct>0 then
		-- 中断当前效果，使后续效果处理视为不同时处理
		Duel.BreakEffect()
		-- 执行抽1张卡的操作
		Duel.Draw(tp,1,REASON_EFFECT)
	end
end
