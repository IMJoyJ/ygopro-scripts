--機巧牙－御神尊真神
-- 效果：
-- 这个卡名的②③的效果1回合各能使用1次。
-- ①：除外的自己的卡是6张以上的场合，这张卡可以不用解放作召唤。
-- ②：这张卡召唤·特殊召唤成功的场合，从手卡丢弃1只怪兽才能发动。从卡组把「机巧牙-御神尊真神」以外的1只攻击力和守备力的数值相同的怪兽加入手卡。
-- ③：怪兽区域的这张卡被破坏的场合才能发动。选除外的6张自己的卡回到卡组。
function c46809548.initial_effect(c)
	-- ①：除外的自己的卡是6张以上的场合，这张卡可以不用解放作召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(46809548,0))  --"不用解放作召唤"
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SUMMON_PROC)
	e1:SetCondition(c46809548.ntcon)
	c:RegisterEffect(e1)
	-- ②：这张卡召唤·特殊召唤成功的场合，从手卡丢弃1只怪兽才能发动。从卡组把「机巧牙-御神尊真神」以外的1只攻击力和守备力的数值相同的怪兽加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(46809548,1))
	e2:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCountLimit(1,46809548)
	e2:SetCost(c46809548.thcost)
	e2:SetTarget(c46809548.thtg)
	e2:SetOperation(c46809548.thop)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e3)
	-- ③：怪兽区域的这张卡被破坏的场合才能发动。选除外的6张自己的卡回到卡组。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(46809548,2))
	e4:SetCategory(CATEGORY_TODECK)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_DESTROYED)
	e4:SetProperty(EFFECT_FLAG_DELAY)
	e4:SetCountLimit(1,46809549)
	e4:SetCondition(c46809548.tdcon)
	e4:SetTarget(c46809548.tdtg)
	e4:SetOperation(c46809548.tdop)
	c:RegisterEffect(e4)
end
-- 判断是否满足不用解放作召唤的条件，即除外区有至少6张卡且等级不低于5级且场上存在空位。
function c46809548.ntcon(e,c,minc)
	if c==nil then return true end
	-- 检查等级是否不低于5且场上是否有空位。
	return minc==0 and c:IsLevelAbove(5) and Duel.GetLocationCount(c:GetControler(),LOCATION_MZONE)>0
		-- 检查除外区是否存在至少6张卡。
		and Duel.IsExistingMatchingCard(nil,c:GetControler(),LOCATION_REMOVED,0,6,nil)
end
-- 用于筛选手牌中可丢弃的怪兽卡片。
function c46809548.costfilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsDiscardable()
end
-- 发动效果时，从手牌中丢弃1只怪兽作为代价。
function c46809548.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断是否满足丢弃1只怪兽的条件。
	if chk==0 then return Duel.IsExistingMatchingCard(c46809548.costfilter,tp,LOCATION_HAND,0,1,nil) end
	-- 执行丢弃1只怪兽的操作。
	Duel.DiscardHand(tp,c46809548.costfilter,1,1,REASON_COST+REASON_DISCARD,nil)
end
-- 用于筛选攻击力等于守备力且不是自身编号的怪兽卡片。
function c46809548.thfilter(c)
	-- 检查卡片的攻击与守备力是否相等且不是本卡编号。
	return aux.AtkEqualsDef(c) and not c:IsCode(46809548) and c:IsAbleToHand()
end
-- 设置效果处理时的目标信息，准备从卡组检索符合条件的怪兽加入手牌。
function c46809548.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断卡组中是否存在满足条件的怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(c46809548.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息，表示将要从卡组把一张怪兽加入手牌。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 执行效果处理，选择并把符合条件的怪兽加入手牌。
function c46809548.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 根据筛选条件从卡组中选择一张怪兽。
	local g=Duel.SelectMatchingCard(tp,c46809548.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		-- 将选中的怪兽送入手牌。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方确认被送入手牌的怪兽。
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 判断该卡是否在破坏前处于主要怪兽区域。
function c46809548.tdcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousLocation(LOCATION_MZONE)
end
-- 设置效果处理时的目标信息，准备从除外区选择6张卡返回卡组。
function c46809548.tdtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断除外区是否存在至少6张可返回卡组的卡。
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsAbleToDeck,tp,LOCATION_REMOVED,0,6,nil) end
	-- 设置操作信息，表示将要从除外区把6张卡返回卡组。
	Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,6,tp,LOCATION_REMOVED)
end
-- 执行效果处理，选择并把6张除外的卡返回卡组。
function c46809548.tdop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要返回卡组的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 根据筛选条件从除外区选择6张卡。
	local g=Duel.SelectMatchingCard(tp,Card.IsAbleToDeck,tp,LOCATION_REMOVED,0,6,6,nil)
	if #g==6 then
		-- 将选中的6张卡送回卡组并洗牌。
		Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	end
end
