--宇宙鋏ゼロオル
-- 效果：
-- 爬虫类族怪兽2只以上
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡连接召唤成功的场合才能发动。把持有把A指示物放置效果的1张卡从卡组加入手卡。
-- ②：把自己·对方场上2个A指示物取除才能发动。把1只爬虫类族怪兽召唤。
-- ③：只要这张卡在怪兽区域存在，有A指示物放置的对方怪兽变成守备表示，不能把效果发动。
function c1487805.initial_effect(c)
	-- 为这张卡添加连接召唤手续，要求至少使用2只爬虫类族怪兽作为素材。
	aux.AddLinkProcedure(c,aux.FilterBoolFunction(Card.IsLinkRace,RACE_REPTILE),2)
	c:EnableReviveLimit()
	-- 对应效果原文："①：这张卡连接召唤成功的场合才能发动。把持有把A指示物放置效果的1张卡从卡组加入手卡。"
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
	-- 对应效果原文："②：把自己·对方场上2个A指示物取除才能发动。把1只爬虫类族怪兽召唤。"
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
	-- 对应效果原文："③：只要这张卡在怪兽区域存在，有A指示物放置的对方怪兽变成守备表示，不能把效果发动。"
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
-- 判断当前怪兽是否为通过连接召唤方式特殊召唤成功的卡片。
function c1487805.thcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_LINK)
end
-- 定义Effect ①的目标筛选函数，包含判断卡片是否持有A指示物且能送入手牌的逻辑。
function c1487805.thfilter(c)
	-- 检查当前目标卡片是否符合检索条件的具体返回值逻辑：即持有A指示物且能送入手牌。
	return aux.IsCounterAdded(c,0x100e) and c:IsAbleToHand()
end
-- 定义Effect ①的发动目标检测逻辑：确认卡组中存在至少一张符合条件的卡片后设置回手牌的操作信息。
function c1487805.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 执行目标检测的具体逻辑，确认卡组中是否存在至少1张符合筛选条件的卡片。
	if chk==0 then return Duel.IsExistingMatchingCard(c1487805.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 向引擎注册当前连锁的操作分类为'回手牌'，并设定相关目标位置与数量信息。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 定义Effect ①的实际效果执行逻辑：提示玩家选择卡片并送入手牌后向对方确认。
function c1487805.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 向当前操作方玩家发送'请选择要加入手牌的卡'的交互提示消息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 调用引擎API从卡组中选出最多1张符合Effect ①检索条件的卡片并存储到变量g中。
	local g=Duel.SelectMatchingCard(tp,c1487805.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 执行将选定卡片组送入指定玩家手牌的引擎操作。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 通知对手玩家查看刚被检索到的卡片，完成效果处理的交互流程。
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 定义Effect ②的启动代价检测与执行：先检查能否移除2个A指示物，再执行移除操作。
function c1487805.sumcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断当前连锁是否满足启动效果的代价要求：确认能移除2个A指示物。
	if chk==0 then return Duel.IsCanRemoveCounter(tp,1,1,0x100e,2,REASON_COST) end
	-- 调用引擎API实际从怪兽区或手牌等区域移除指定的A指示物数量。
	Duel.RemoveCounter(tp,1,1,0x100e,2,REASON_COST)
end
-- 定义Effect ②的目标筛选条件逻辑：判断卡片是否为爬虫类族且具备通常/特殊召唤能力。
function c1487805.sumfilter(c)
	return c:IsRace(RACE_REPTILE) and c:IsSummonable(true,nil)
end
-- 定义Effect ②的发动目标检测函数，确认场上或手牌中存在至少一只符合条件的怪兽后设置召唤的操作信息。
function c1487805.sumtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 执行目标检测的具体逻辑，检查是否存在满足条件的怪兽数量大于等于所需数量的具体条件语句。
	if chk==0 then return Duel.IsExistingMatchingCard(c1487805.sumfilter,tp,LOCATION_HAND+LOCATION_MZONE,0,1,nil) end
	-- 向引擎注册当前连锁的操作分类为'通常/特殊召唤'，并设定相关目标位置与数量信息。
	Duel.SetOperationInfo(0,CATEGORY_SUMMON,nil,1,0,0)
end
-- 定义Effect ②的实际效果执行逻辑：提示玩家选择怪兽并进行召唤操作（忽略通常召唤次数限制）。
function c1487805.sumop(e,tp,eg,ep,ev,re,r,rp)
	-- 向当前操作方玩家发送'请选择要召唤的卡'的交互提示消息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SUMMON)  --"请选择要召唤的卡"
	-- 调用引擎API从手牌和怪兽区域中选出最多1张符合Effect ②召唤条件的怪兽并存储到变量g中。
	local g=Duel.SelectMatchingCard(tp,c1487805.sumfilter,tp,LOCATION_HAND+LOCATION_MZONE,0,1,1,nil)
	local tc=g:GetFirst()
	if tc then
		-- 调用引擎API对选定怪兽执行召唤动作，此处设置为忽略每回合的通常召唤次数限制。
		Duel.Summon(tp,tc,true,nil)
	end
end
-- 定义Effect ③的目标筛选条件逻辑：判断怪兽是否表侧表示且持有A指示物的具体返回值逻辑，用于后续效果判定。
function c1487805.actg(e,c)
	return c:IsFaceup() and c:GetCounter(0x100e)>0
end
