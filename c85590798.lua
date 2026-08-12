--聖なる降誕
-- 效果：
-- 这个卡名的①②的效果1回合只能有1次使用其中任意1个。
-- ①：自己主要阶段才能发动。手卡1只天使族·光属性怪兽给对方观看，从卡组把1只龙族·光属性·7星怪兽加入手卡。那之后，给人观看的怪兽回到卡组最下面。
-- ②：对方把魔法·陷阱·怪兽的效果发动的场合才能发动。从手卡把1只龙族·光属性·7星怪兽特殊召唤。
function c85590798.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- ①：自己主要阶段才能发动。手卡1只天使族·光属性怪兽给对方观看，从卡组把1只龙族·光属性·7星怪兽加入手卡。那之后，给人观看的怪兽回到卡组最下面。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(85590798,0))
	e2:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND+CATEGORY_TODECK)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1,85590798)
	e2:SetTarget(c85590798.thtg)
	e2:SetOperation(c85590798.thop)
	c:RegisterEffect(e2)
	-- ②：对方把魔法·陷阱·怪兽的效果发动的场合才能发动。从手卡把1只龙族·光属性·7星怪兽特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(85590798,1))  --"从手卡特殊召唤"
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_CHAINING)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCountLimit(1,85590798)
	e3:SetCondition(c85590798.spcon)
	e3:SetTarget(c85590798.sptg)
	e3:SetOperation(c85590798.spop)
	c:RegisterEffect(e3)
end
-- 过滤手卡中未公开、可回到卡组的光属性天使族怪兽
function c85590798.cfilter(c)
	return c:IsAttribute(ATTRIBUTE_LIGHT) and c:IsRace(RACE_FAIRY) and c:IsAbleToDeck() and not c:IsPublic()
end
-- 过滤卡组中可加入手卡的光属性7星龙族怪兽
function c85590798.thfilter(c)
	return c:IsAttribute(ATTRIBUTE_LIGHT) and c:IsLevel(7) and c:IsRace(RACE_DRAGON) and c:IsAbleToHand()
end
-- 效果①的发动准备与合法性检测函数
function c85590798.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查手卡中是否存在至少1只满足条件（光属性天使族且未公开）的怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c85590798.cfilter,tp,LOCATION_HAND,0,1,nil)
		-- 并且检查卡组中是否存在至少1只满足条件（光属性7星龙族）的怪兽
		and Duel.IsExistingMatchingCard(c85590798.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息：预计将手卡的1张卡送回卡组
	Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,1,tp,LOCATION_HAND)
	-- 设置操作信息：预计从卡组将1张卡加入手卡
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果①的效果处理函数
function c85590798.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要送回卡组的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 玩家选择手卡中1只满足条件的光属性天使族怪兽
	local g1=Duel.SelectMatchingCard(tp,c85590798.cfilter,tp,LOCATION_HAND,0,1,1,nil)
	if g1:GetCount()==0 then return end
	-- 给对方玩家确认展示所选择的怪兽
	Duel.ConfirmCards(1-tp,g1)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 玩家从卡组选择1只满足条件的光属性7星龙族怪兽
	local g2=Duel.SelectMatchingCard(tp,c85590798.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	-- 如果成功将选中的卡组怪兽加入手卡
	if g2:GetCount()>0 and Duel.SendtoHand(g2,nil,REASON_EFFECT)~=0 then
		-- 给对方玩家确认加入手卡的怪兽
		Duel.ConfirmCards(1-tp,g2)
		-- 洗切自身卡组
		Duel.ShuffleDeck(tp)
		-- 中断当前效果，使后续的“回到卡组最下面”处理视为不同时处理
		Duel.BreakEffect()
		-- 将最初展示的怪兽送回持有者卡组的最下面
		Duel.SendtoDeck(g1,nil,SEQ_DECKBOTTOM,REASON_EFFECT)
	end
end
-- 效果②的发动条件：对方把魔法·陷阱·怪兽的效果发动
function c85590798.spcon(e,tp,eg,ep,ev,re,r,rp)
	return rp==1-tp
end
-- 过滤手卡中可以特殊召唤的光属性7星龙族怪兽
function c85590798.spfilter(c,e,tp)
	return c:IsAttribute(ATTRIBUTE_LIGHT) and c:IsRace(RACE_DRAGON)
		and c:IsLevel(7) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果②的发动准备与合法性检测函数
function c85590798.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自身场上是否有可用的怪兽区域空格
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 并且检查手卡中是否存在至少1只满足条件（光属性7星龙族且可特召）的怪兽
		and Duel.IsExistingMatchingCard(c85590798.spfilter,tp,LOCATION_HAND,0,1,nil,e,tp) end
	-- 设置操作信息：预计从手卡特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
-- 效果②的效果处理函数
function c85590798.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 如果此时场上没有可用的怪兽区域空格，则不处理
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 玩家选择手卡中1只满足条件的光属性7星龙族怪兽
	local g=Duel.SelectMatchingCard(tp,c85590798.spfilter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的怪兽以表侧表示特殊召唤到自身场上
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
