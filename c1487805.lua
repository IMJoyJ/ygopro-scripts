--宇宙鋏ゼロオル
-- 效果：
-- 爬虫类族怪兽2只以上
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡连接召唤成功的场合才能发动。把持有把A指示物放置效果的1张卡从卡组加入手卡。
-- ②：把自己·对方场上2个A指示物取除才能发动。把1只爬虫类族怪兽召唤。
-- ③：只要这张卡在怪兽区域存在，有A指示物放置的对方怪兽变成守备表示，不能把效果发动。
function c1487805.initial_effect(c)
	-- 添加连接召唤手续，要求使用至少2只爬虫类族怪兽作为连接素材
	aux.AddLinkProcedure(c,aux.FilterBoolFunction(Card.IsLinkRace,RACE_REPTILE),2)
	c:EnableReviveLimit()
	-- ①：这张卡连接召唤成功的场合才能发动。把持有把A指示物放置效果的1张卡从卡组加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(1487805,0))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_TRIGGER_O+EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCountLimit(1,1487805)
	e1:SetCondition(c1487805.thcon)
	e1:SetTarget(c1487805.thtg)
	e1:SetOperation(c1487805.thop)
	c:RegisterEffect(e1)
	-- ②：把自己·对方场上2个A指示物取除才能发动。把1只爬虫类族怪兽召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(1487805,1))
	e2:SetCategory(CATEGORY_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,1487806)
	e2:SetCost(c1487805.sumcost)
	e2:SetTarget(c1487805.sumtg)
	e2:SetOperation(c1487805.sumop)
	c:RegisterEffect(e2)
	-- ③：只要这张卡在怪兽区域存在，有A指示物放置的对方怪兽变成守备表示，不能把效果发动。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_SET_POSITION)
	e3:SetRange(LOCATION_MZONE)
	e3:SetTargetRange(0,LOCATION_MZONE)
	e3:SetTarget(c1487805.actg)
	e3:SetValue(POS_FACEUP_DEFENSE)
	c:RegisterEffect(e3)
	local e4=e3:Clone()
	e4:SetCode(EFFECT_CANNOT_TRIGGER)
	e4:SetValue(1)
	c:RegisterEffect(e4)
end
-- 效果发动的条件：这张卡是通过连接召唤方式特殊召唤成功的
function c1487805.thcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_LINK)
end
-- 检索过滤器：满足条件的卡必须具有放置A指示物的效果且可以加入手牌
function c1487805.thfilter(c)
	-- 判断卡片是否具有放置A指示物的效果并且可以送去手牌
	return aux.IsCounterAdded(c,0x100e) and c:IsAbleToHand()
end
-- 设置效果的发动目标：从卡组检索满足条件的卡片
function c1487805.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否满足发动条件：卡组中是否存在至少1张满足过滤条件的卡
	if chk==0 then return Duel.IsExistingMatchingCard(c1487805.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置连锁操作信息：将1张卡从卡组加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果的处理函数：执行将卡加入手牌的操作
function c1487805.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	-- 从卡组中选择满足条件的1张卡
	local g=Duel.SelectMatchingCard(tp,c1487805.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡送入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方确认送入手牌的卡
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 召唤效果的费用处理函数：移除场上2个A指示物作为费用
function c1487805.sumcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否满足费用支付条件：是否能移除场上2个A指示物
	if chk==0 then return Duel.IsCanRemoveCounter(tp,1,1,0x100e,2,REASON_COST) end
	-- 执行移除场上2个A指示物的操作
	Duel.RemoveCounter(tp,1,1,0x100e,2,REASON_COST)
end
-- 召唤过滤器：满足条件的卡必须是爬虫类族且可以通常召唤
function c1487805.sumfilter(c)
	return c:IsRace(RACE_REPTILE) and c:IsSummonable(true,nil)
end
-- 设置召唤效果的目标：选择1只爬虫类族怪兽进行召唤
function c1487805.sumtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否满足发动条件：手牌或场上是否存在至少1只满足条件的怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c1487805.sumfilter,tp,LOCATION_HAND+LOCATION_MZONE,0,1,nil) end
	-- 设置连锁操作信息：进行1只怪兽的通常召唤
	Duel.SetOperationInfo(0,CATEGORY_SUMMON,nil,1,0,0)
end
-- 效果的处理函数：执行通常召唤的操作
function c1487805.sumop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要召唤的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SUMMON)
	-- 选择满足条件的1只怪兽
	local g=Duel.SelectMatchingCard(tp,c1487805.sumfilter,tp,LOCATION_HAND+LOCATION_MZONE,0,1,1,nil)
	local tc=g:GetFirst()
	if tc then
		-- 执行通常召唤操作
		Duel.Summon(tp,tc,true,nil)
	end
end
-- 效果适用目标的过滤器：满足条件的怪兽必须是表侧表示且有A指示物
function c1487805.actg(e,c)
	return c:IsFaceup() and c:GetCounter(0x100e)>0
end
