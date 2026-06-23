--魔鍵施解
-- 效果：
-- 这个卡名的卡在1回合只能发动1张，这个卡名的③的效果1回合只能使用1次。
-- ①：作为这张卡的发动时的效果处理，可以从卡组把1只「魔键」怪兽加入手卡。
-- ②：只要这张卡在场地区域存在，衍生物以外的自己场上的通常怪兽在1回合各有1次不会被战斗·效果破坏。
-- ③：自己主要阶段才能发动。从卡组把1张「魔键-马夫提亚」加入手卡。那之后，选1张手卡回到卡组最下面。
function c35815783.initial_effect(c)
	-- ①：作为这张卡的发动时的效果处理，可以从卡组把1只「魔键」怪兽加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,35815783+EFFECT_COUNT_CODE_OATH)
	e1:SetOperation(c35815783.activate)
	c:RegisterEffect(e1)
	-- ②：只要这张卡在场地区域存在，衍生物以外的自己场上的通常怪兽在1回合各有1次不会被战斗·效果破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_INDESTRUCTABLE_COUNT)
	e2:SetRange(LOCATION_FZONE)
	e2:SetTargetRange(LOCATION_MZONE,0)
	e2:SetTarget(c35815783.indtg)
	e2:SetValue(c35815783.indct)
	c:RegisterEffect(e2)
	-- ③：自己主要阶段才能发动。从卡组把1张「魔键-马夫提亚」加入手卡。那之后，选1张手卡回到卡组最下面。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(35815783,1))
	e3:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_TODECK)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_FZONE)
	e3:SetCountLimit(1,35815784)
	e3:SetTarget(c35815783.thtg)
	e3:SetOperation(c35815783.thop)
	c:RegisterEffect(e3)
end
-- 检索满足条件的「魔键」怪兽卡片组
function c35815783.filter(c)
	return c:IsSetCard(0x165) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
-- 效果处理：从卡组检索1只「魔键」怪兽加入手牌
function c35815783.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取满足条件的「魔键」怪兽卡片组
	local g=Duel.GetMatchingGroup(c35815783.filter,tp,LOCATION_DECK,0,nil)
	-- 判断是否满足检索条件并由玩家选择是否发动
	if g:GetCount()>0 and Duel.SelectYesNo(tp,aux.Stringid(35815783,0)) then  --"是否从卡组把1只「魔键」怪兽加入手卡？"
		-- 提示玩家选择要加入手牌的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
		local sg=g:Select(tp,1,1,nil)
		-- 将选中的卡加入手牌
		Duel.SendtoHand(sg,nil,REASON_EFFECT)
		-- 向对方确认加入手牌的卡
		Duel.ConfirmCards(1-tp,sg)
	end
end
-- 判断目标怪兽是否为通常怪兽且非衍生物
function c35815783.indtg(e,c)
	return c:IsFaceup() and c:IsType(TYPE_NORMAL) and not c:IsType(TYPE_TOKEN)
end
-- 设定怪兽在1回合内不会被战斗或效果破坏
function c35815783.indct(e,re,r,rp)
	if bit.band(r,REASON_BATTLE+REASON_EFFECT)~=0 then
		return 1
	else return 0 end
end
-- 检索「魔键-马夫提亚」卡片组
function c35815783.thfilter(c)
	return c:IsCode(99426088) and c:IsAbleToHand()
end
-- 设置效果处理时的连锁操作信息
function c35815783.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断卡组中是否存在「魔键-马夫提亚」
	if chk==0 then return Duel.IsExistingMatchingCard(c35815783.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置将「魔键-马夫提亚」加入手牌的操作信息
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
	-- 设置将1张手卡送回卡组的操作信息
	Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,1,tp,LOCATION_HAND)
end
-- 效果处理：从卡组检索「魔键-马夫提亚」加入手牌，并将1张手卡送回卡组最底端
function c35815783.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取卡组中第一张「魔键-马夫提亚」
	local tg=Duel.GetFirstMatchingCard(c35815783.thfilter,tp,LOCATION_DECK,0,nil)
	-- 判断是否成功将「魔键-马夫提亚」加入手牌
	if tg and Duel.SendtoHand(tg,nil,REASON_EFFECT)~=0 then
		-- 向对方确认加入手牌的「魔键-马夫提亚」
		Duel.ConfirmCards(1-tp,tg)
		-- 洗切玩家手牌
		Duel.ShuffleHand(tp)
		-- 洗切玩家卡组
		Duel.ShuffleDeck(tp)
		-- 中断当前效果处理
		Duel.BreakEffect()
		-- 提示玩家选择要返回卡组的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
		-- 选择1张手卡送回卡组最底端
		local sg=Duel.SelectMatchingCard(tp,Card.IsAbleToDeck,tp,LOCATION_HAND,0,1,1,nil)
		-- 将选中的手卡送回卡组最底端
		Duel.SendtoDeck(sg,nil,SEQ_DECKBOTTOM,REASON_EFFECT)
	end
end
