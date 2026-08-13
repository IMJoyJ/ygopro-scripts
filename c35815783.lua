--魔鍵施解
-- 效果：
-- 这个卡名的卡在1回合只能发动1张，这个卡名的③的效果1回合只能使用1次。
-- ①：作为这张卡的发动时的效果处理，可以从卡组把1只「魔键」怪兽加入手卡。
-- ②：只要这张卡在场地区域存在，衍生物以外的自己场上的通常怪兽在1回合各有1次不会被战斗·效果破坏。
-- ③：自己主要阶段才能发动。从卡组把1张「魔键-马夫提亚」加入手卡。那之后，选1张手卡回到卡组最下面。
function c35815783.initial_effect(c)
	-- 这个卡名的卡在1回合只能发动1张；①：作为这张卡的发动时的效果处理，可以从卡组把1只「魔键」怪兽加入手卡。
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
	-- 这个卡名的③的效果1回合只能使用1次；③：自己主要阶段才能发动。从卡组把1张「魔键-马夫提亚」加入手卡。那之后，选1张手卡回到卡组最下面。
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
-- ①效果的检索筛选：从卡组选出1只「魔键」字段的怪兽且能够加入手卡的卡。
function c35815783.filter(c)
	return c:IsSetCard(0x165) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
-- ①效果处理：若卡组存在符合条件的「魔键」怪兽且玩家选择是，则从卡组选1只「魔键」怪兽加入手卡，并给对方确认。
function c35815783.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取我方卡组中所有满足条件的「魔键」怪兽，用于后续选择。
	local g=Duel.GetMatchingGroup(c35815783.filter,tp,LOCATION_DECK,0,nil)
	-- 若卡组中存在符合条件的「魔键」怪兽，并且发动者选择是，则继续处理检索。
	if g:GetCount()>0 and Duel.SelectYesNo(tp,aux.Stringid(35815783,0)) then  --"是否从卡组把1只「魔键」怪兽加入手卡？"
		-- 显示选择提示：请选择要加入手牌的卡。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
		local sg=g:Select(tp,1,1,nil)
		-- 将选中的卡加入持有者手卡（效果处理）。
		Duel.SendtoHand(sg,nil,REASON_EFFECT)
		-- 将加入手卡的卡展示给对方玩家确认。
		Duel.ConfirmCards(1-tp,sg)
	end
end
-- ②效果的保护对象判定：表侧表示、通常怪兽且非衍生物。
function c35815783.indtg(e,c)
	return c:IsFaceup() and c:IsType(TYPE_NORMAL) and not c:IsType(TYPE_TOKEN)
end
-- ②效果提供破坏抗性的判定：若破坏原因为战斗或效果，则返回1（获得1次不会被破坏的效果），否则返回0。
function c35815783.indct(e,re,r,rp)
	if bit.band(r,REASON_BATTLE+REASON_EFFECT)~=0 then
		return 1
	else return 0 end
end
-- ③效果的检索筛选：卡名必须为「魔键-马夫提亚」（99426088）且能够加入手卡。
function c35815783.thfilter(c)
	return c:IsCode(99426088) and c:IsAbleToHand()
end
-- ③效果发动条件与操作预告：确认卡组存在「魔键-马夫提亚」，并设定将检索到手牌以及将1张手卡放回卡组的操作信息。
function c35815783.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动时检查（chk==0）卡组是否存在1张以上「魔键-马夫提亚」，否则不能发动。
	if chk==0 then return Duel.IsExistingMatchingCard(c35815783.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设定操作信息：从卡组将1张卡加入手牌（用于连锁检测等）。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
	-- 设定操作信息：从手牌将1张卡放回卡组（用于连锁检测等）。
	Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,1,tp,LOCATION_HAND)
end
-- ③效果处理：从卡组将「魔键-马夫提亚」加入手卡并让对方确认，然后选1张手卡放回卡组最下面。
function c35815783.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 从卡组中获取1张符合条件的「魔键-马夫提亚」。
	local tg=Duel.GetFirstMatchingCard(c35815783.thfilter,tp,LOCATION_DECK,0,nil)
	-- 如果成功将「魔键-马夫提亚」加入手卡（处理数量不为0），则继续后续回卡组操作。
	if tg and Duel.SendtoHand(tg,nil,REASON_EFFECT)~=0 then
		-- 将检索到的「魔键-马夫提亚」展示给对方玩家确认。
		Duel.ConfirmCards(1-tp,tg)
		-- 洗切手卡，使手卡顺序随机化。
		Duel.ShuffleHand(tp)
		-- 洗切卡组，使卡组重新随机排列。
		Duel.ShuffleDeck(tp)
		-- 中断当前效果处理，使“从卡组加入手卡”与“选1张手卡回到卡组”视为先后处理（避免作为同时处理）。
		Duel.BreakEffect()
		-- 显示选择提示：请选择要返回卡组的卡。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
		-- 从手卡中选择1张能够放回卡组的卡（玩家自己选择）。
		local sg=Duel.SelectMatchingCard(tp,Card.IsAbleToDeck,tp,LOCATION_HAND,0,1,1,nil)
		-- 将选择的手卡以效果原因放回持有者卡组最下面。
		Duel.SendtoDeck(sg,nil,SEQ_DECKBOTTOM,REASON_EFFECT)
	end
end
