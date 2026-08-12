--無垢なる祈りの獄神使
-- 效果：
-- 连接怪兽以外的怪兽2只
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡连接召唤的场合，若自己墓地有「狱神」怪兽存在则能发动。从卡组把1张「预幻」卡加入手卡。
-- ②：自己·对方的主要阶段，自己场上有其他的天使族·暗属性怪兽存在的场合才能发动。用包含这张卡的自己场上的怪兽为素材进行连接召唤。
local s,id,o=GetID()
-- 注册卡片效果及连接召唤手续的初始化函数。
function s.initial_effect(c)
	-- 注册需要2只连接怪兽以外的怪兽作为素材的连接召唤手续。
	aux.AddLinkProcedure(c,aux.NOT(aux.FilterBoolFunction(Card.IsLinkType,TYPE_LINK)),2,2)
	c:EnableReviveLimit()
	-- ①：这张卡连接召唤的场合，若自己墓地有「狱神」怪兽存在则能发动。从卡组把1张「预幻」卡加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"检索"
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.thcon)
	e1:SetTarget(s.thtg)
	e1:SetOperation(s.thop)
	c:RegisterEffect(e1)
	-- ②：自己·对方的主要阶段，自己场上有其他的天使族·暗属性怪兽存在的场合才能发动。用包含这张卡的自己场上的怪兽为素材进行连接召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"连接召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_MAIN_END)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,id+o)
	e2:SetCondition(s.lkcon)
	e2:SetTarget(s.lktg)
	e2:SetOperation(s.lkop)
	c:RegisterEffect(e2)
end
-- 检索效果的发动条件：本卡成功进行连接召唤。
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_LINK)
end
-- 检索卡片的过滤条件：属于「预幻」字段且可以加入手牌。
function s.thfilter(c)
	return c:IsSetCard(0x1e0) and c:IsAbleToHand()
end
-- 墓地卡片的过滤条件：属于「狱神」字段的怪兽卡。
function s.cfilter(c)
	return c:IsSetCard(0x1ce) and c:IsType(TYPE_MONSTER)
end
-- 检索效果的Target处理函数：检查卡组是否存在「预幻」卡、自己墓地是否存在「狱神」怪兽，并设置检索操作信息。
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查己方卡组中是否存在可以加入手牌的「预幻」卡。
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil)
		-- 并确认己方墓地中存在至少1只「狱神」怪兽。
		and Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 向对方玩家提示己方发动了本效果。
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
	-- 设置当前连锁的操作信息为：从卡组将1张卡加入手牌。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 检索效果的Operation处理函数：从卡组选择1张「预幻」卡加入手牌并给对方确认。
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡片。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让己方玩家从卡组选择1张满足过滤条件的「预幻」卡。
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选择的卡片因效果加入玩家手牌。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 给对方确认加入手牌的卡片。
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 怪兽过滤条件：场上表侧表示存在的暗属性天使族怪兽。
function s.cfilter2(c)
	return c:IsFaceupEx() and c:IsAttribute(ATTRIBUTE_DARK) and c:IsRace(RACE_FAIRY)
end
-- 连接召唤效果的发动条件：处于双方的主要阶段，且自己场上存在除本卡以外的暗属性天使族怪兽。
function s.lkcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查当前是否为主要阶段，且自己场上是否存在除本卡以外表侧表示的暗属性天使族怪兽。
	return Duel.IsMainPhase() and Duel.IsExistingMatchingCard(s.cfilter2,tp,LOCATION_MZONE,0,1,e:GetHandler())
end
-- 连接召唤效果的Target处理函数：检查额外卡组中是否存在可以以包含本卡在内的场上怪兽为素材进行连接召唤的连接怪兽，并设置特殊召唤操作信息。
function s.lktg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查额外卡组中是否存在能够以包含本卡在内的怪兽为素材进行连接召唤的怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsLinkSummonable,tp,LOCATION_EXTRA,0,1,nil,nil,e:GetHandler()) end
	-- 向对方玩家提示自己发动的连接召唤效果。
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
	-- 设置当前连锁的操作信息为：从额外卡组特殊召唤1只怪兽。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- 连接召唤效果的Operation处理函数：选择额外卡组的一只连接怪兽，用包含此卡的场上怪兽作为连接素材将其连接召唤。
function s.lkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsControler(1-tp) or not c:IsRelateToEffect(e) or c:IsFacedown() then return end
	-- 获取额外卡组中能够以包含本卡在内的己方场上怪兽为素材进行连接召唤的所有连接怪兽。
	local g=Duel.GetMatchingGroup(Card.IsLinkSummonable,tp,LOCATION_EXTRA,0,nil,nil,c)
	if g:GetCount()>0 then
		-- 提示玩家选择要进行特殊召唤的卡片。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		local sg=g:Select(tp,1,1,nil)
		-- 让玩家以包含此卡在内的素材进行连接召唤。
		Duel.LinkSummon(tp,sg:GetFirst(),nil,c)
	end
end
