--星遺物の選託
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：可以从以下效果选择1个发动。
-- ●选对方场上1只连接怪兽送去墓地。
-- ●从自己墓地把7张「星遗物」卡除外才能发动。从卡组把1只电子界族怪兽加入手卡。
function c59778096.initial_effect(c)
	-- ①：可以从以下效果选择1个发动。●选对方场上1只连接怪兽送去墓地。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(59778096,0))  --"送去墓地"
	e1:SetCategory(CATEGORY_TOGRAVE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,59778096+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(c59778096.tgtg)
	e1:SetOperation(c59778096.tgop)
	c:RegisterEffect(e1)
	-- ①：可以从以下效果选择1个发动。●从自己墓地把7张「星遗物」卡除外才能发动。从卡组把1只电子界族怪兽加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(59778096,1))  --"卡组检索"
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e2:SetType(EFFECT_TYPE_ACTIVATE)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetCountLimit(1,59778096+EFFECT_COUNT_CODE_OATH)
	e2:SetCost(c59778096.thcost)
	e2:SetTarget(c59778096.thtg)
	e2:SetOperation(c59778096.thop)
	c:RegisterEffect(e2)
end
-- 过滤条件：表侧表示的连接怪兽
function c59778096.tgfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_LINK)
end
-- 效果①（送去墓地）的发动准备与效果处理确认
function c59778096.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动时点，检查对方场上是否存在表侧表示的连接怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c59778096.tgfilter,tp,0,LOCATION_MZONE,1,nil) end
	-- 获取对方场上所有表侧表示的连接怪兽
	local g=Duel.GetMatchingGroup(c59778096.tgfilter,tp,0,LOCATION_MZONE,nil)
	-- 设置连锁信息，表示该效果的处理为将对方场上的卡送去墓地
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,g,1,0,0)
end
-- 效果①（送去墓地）的效果处理
function c59778096.tgop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要送去墓地的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 让玩家从对方场上选择1只表侧表示的连接怪兽
	local g=Duel.SelectMatchingCard(tp,c59778096.tgfilter,tp,0,LOCATION_MZONE,1,1,nil)
	if g:GetCount()>0 then
		-- 为选中的怪兽显示被选为对象的动画效果
		Duel.HintSelection(g)
		-- 将选中的怪兽送去墓地
		Duel.SendtoGrave(g,REASON_EFFECT)
	end
end
-- 过滤条件：自己墓地可以除外的「星遗物」卡
function c59778096.rmfilter(c)
	return c:IsSetCard(0xfe) and c:IsAbleToRemoveAsCost()
end
-- 效果②（检索）的发动代价处理
function c59778096.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动时代价检查，确认自己墓地是否存在至少7张「星遗物」卡
	if chk==0 then return Duel.IsExistingMatchingCard(c59778096.rmfilter,tp,LOCATION_GRAVE,0,7,nil) end
	-- 提示玩家选择要除外的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 让玩家从自己墓地选择7张「星遗物」卡
	local g=Duel.SelectMatchingCard(tp,c59778096.rmfilter,tp,LOCATION_GRAVE,0,7,7,nil)
	-- 将选中的卡表侧表示除外作为发动代价
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
-- 过滤条件：卡组中可以加入手牌的电子界族怪兽
function c59778096.thfilter(c)
	return c:IsRace(RACE_CYBERSE) and c:IsAbleToHand()
end
-- 效果②（检索）的发动准备与效果处理确认
function c59778096.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动时点，检查自己卡组是否存在可以加入手牌的电子界族怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c59778096.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置连锁信息，表示该效果的处理为从卡组将卡片加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果②（检索）的效果处理
function c59778096.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从卡组选择1只电子界族怪兽
	local g=Duel.SelectMatchingCard(tp,c59778096.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的怪兽加入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方展示加入手牌的卡片
		Duel.ConfirmCards(1-tp,g)
	end
end
