--宇宙鋏ゼロオル
-- 效果：
-- 爬虫类族怪兽2只以上
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡连接召唤成功的场合才能发动。把持有把A指示物放置效果的1张卡从卡组加入手卡。
-- ②：把自己·对方场上2个A指示物取除才能发动。把1只爬虫类族怪兽召唤。
-- ③：只要这张卡在怪兽区域存在，有A指示物放置的对方怪兽变成守备表示，不能把效果发动。
function c1487805.initial_effect(c)
	-- 设定这张卡的连接召唤手续：以2只以上爬虫类族怪兽作为连接素材
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
c1487805.mentioned_counter={
	[0x100e]=true,
}
-- 效果①的发动条件：这张卡是连接召唤成功的场合
function c1487805.thcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_LINK)
end
-- 检索过滤器：筛选持有把A指示物（0x100e）放置效果且可以加入手卡的卡
function c1487805.thfilter(c)
	-- 检查该卡是否被记述了可以放置A指示物的效果，并且可以加入手卡
	return aux.IsCounterAdded(c,0x100e) and c:IsAbleToHand()
end
-- 效果①的目标处理：确认卡组存在可检索的卡，并设置回手牌的操作信息
function c1487805.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动时检查：自己卡组是否存在至少1张满足条件的可检索卡
	if chk==0 then return Duel.IsExistingMatchingCard(c1487805.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息：预计从卡组把1张卡加入手卡
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果①的处理：让玩家从卡组选择1张持有A指示物放置效果的卡加入手卡，并让对方确认
function c1487805.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 向玩家发送提示消息：请选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从自己卡组选择1张持有把A指示物放置效果的卡
	local g=Duel.SelectMatchingCard(tp,c1487805.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 以效果原因把选择的卡送去持有者的手卡
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 让对方玩家确认加入手卡的卡
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 效果②的发动代价：取除自己·对方场上2个A指示物
function c1487805.sumcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动时检查：自己场上和对方场上合计是否能取除2个A指示物作为代价
	if chk==0 then return Duel.IsCanRemoveCounter(tp,1,1,0x100e,2,REASON_COST) end
	-- 作为发动代价取除自己·对方场上2个A指示物
	Duel.RemoveCounter(tp,1,1,0x100e,2,REASON_COST)
end
-- 召唤对象过滤器：筛选爬虫类族且可以进行通常召唤的怪兽
function c1487805.sumfilter(c)
	return c:IsRace(RACE_REPTILE) and c:IsSummonable(true,nil)
end
-- 效果②的目标处理：确认存在可召唤的爬虫类族怪兽，并设置召唤的操作信息
function c1487805.sumtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动时检查：自己的手卡·怪兽区域是否存在至少1只可以召唤的爬虫类族怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c1487805.sumfilter,tp,LOCATION_HAND+LOCATION_MZONE,0,1,nil) end
	-- 设置操作信息：预计进行1次召唤
	Duel.SetOperationInfo(0,CATEGORY_SUMMON,nil,1,0,0)
end
-- 效果②的处理：让玩家选择1只爬虫类族怪兽并将其召唤
function c1487805.sumop(e,tp,eg,ep,ev,re,r,rp)
	-- 向玩家发送提示消息：请选择要召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SUMMON)  --"请选择要召唤的卡"
	-- 让玩家从自己的手卡·怪兽区域选择1只可以召唤的爬虫类族怪兽
	local g=Duel.SelectMatchingCard(tp,c1487805.sumfilter,tp,LOCATION_HAND+LOCATION_MZONE,0,1,1,nil)
	local tc=g:GetFirst()
	if tc then
		-- 无视通常召唤次数限制，把选择的怪兽通常召唤
		Duel.Summon(tp,tc,true,nil)
	end
end
-- 永续效果的对象过滤器：筛选对方场上表侧表示且放置有A指示物的怪兽
function c1487805.actg(e,c)
	return c:IsFaceup() and c:GetCounter(0x100e)>0
end
