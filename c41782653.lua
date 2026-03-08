--オーバーテクス・ゴアトルス
-- 效果：
-- 这张卡不能通常召唤。让除外的5只自己的恐龙族怪兽回到卡组的场合才能特殊召唤。这个卡名的②的效果1回合只能使用1次。
-- ①：1回合1次，对方把魔法·陷阱卡发动时才能发动。选自己的手卡·场上1只恐龙族怪兽破坏，那个发动无效并破坏。
-- ②：这张卡被效果送去墓地的场合才能发动。从卡组把1张「进化药」魔法卡加入手卡。
function c41782653.initial_effect(c)
	c:EnableReviveLimit()
	-- 效果原文：这张卡不能通常召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	c:RegisterEffect(e1)
	-- 效果原文：让除外的5只自己的恐龙族怪兽回到卡组的场合才能特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_SPSUMMON_PROC)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e2:SetRange(LOCATION_HAND)
	e2:SetCondition(c41782653.sprcon)
	e2:SetTarget(c41782653.sprtg)
	e2:SetOperation(c41782653.sprop)
	c:RegisterEffect(e2)
	-- 效果原文：①：1回合1次，对方把魔法·陷阱卡发动时才能发动。选自己的手卡·场上1只恐龙族怪兽破坏，那个发动无效并破坏。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(41782653,0))
	e3:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e3:SetCode(EVENT_CHAINING)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1)
	e3:SetCondition(c41782653.negcon)
	e3:SetTarget(c41782653.negtg)
	e3:SetOperation(c41782653.negop)
	c:RegisterEffect(e3)
	-- 效果原文：②：这张卡被效果送去墓地的场合才能发动。从卡组把1张「进化药」魔法卡加入手卡。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(41782653,1))
	e4:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e4:SetProperty(EFFECT_FLAG_DELAY)
	e4:SetCode(EVENT_TO_GRAVE)
	e4:SetCountLimit(1,41782653)
	e4:SetCondition(c41782653.thcon)
	e4:SetTarget(c41782653.thtg)
	e4:SetOperation(c41782653.thop)
	c:RegisterEffect(e4)
end
-- 检索满足条件的卡片组：除外区5只恐龙族怪兽
function c41782653.sprfilter(c)
	return c:IsFaceup() and c:IsRace(RACE_DINOSAUR) and c:IsAbleToDeckAsCost()
end
-- 判断特殊召唤条件是否满足：场上存在空位且除外区有5只恐龙族怪兽
function c41782653.sprcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 判断场上是否存在空位
	return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 判断除外区是否存在5只恐龙族怪兽
		and Duel.IsExistingMatchingCard(c41782653.sprfilter,tp,LOCATION_REMOVED,0,5,nil)
end
-- 选择要返回卡组的5只恐龙族怪兽
function c41782653.sprtg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	-- 获取除外区所有恐龙族怪兽
	local g=Duel.GetMatchingGroup(c41782653.sprfilter,tp,LOCATION_REMOVED,0,nil)
	-- 提示玩家选择要返回卡组的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	local sg=g:CancelableSelect(tp,5,5,nil)
	if sg then
		sg:KeepAlive()
		e:SetLabelObject(sg)
		return true
	else return false end
end
-- 执行特殊召唤的处理：将选中的怪兽送回卡组
function c41782653.sprop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	-- 显示选中的怪兽被送回卡组的动画
	Duel.HintSelection(g)
	-- 将选中的怪兽送回卡组并洗牌
	Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_SPSUMMON)
	g:DeleteGroup()
end
-- 判断是否可以发动效果：不是战斗破坏且是对方发动的魔法或陷阱
function c41782653.negcon(e,tp,eg,ep,ev,re,r,rp)
	return not e:GetHandler():IsStatus(STATUS_BATTLE_DESTROYED) and ep~=tp
		-- 判断对方发动的是魔法或陷阱卡且可以无效
		and re:IsHasType(EFFECT_TYPE_ACTIVATE) and Duel.IsChainNegatable(ev)
end
-- 检索满足条件的卡片组：手牌或场上的恐龙族怪兽
function c41782653.desfilter(c)
	return (c:IsLocation(LOCATION_HAND) or c:IsFaceup()) and c:IsType(TYPE_MONSTER) and c:IsRace(RACE_DINOSAUR)
end
-- 设置效果处理信息：破坏手牌或场上的恐龙族怪兽并无效对方发动
function c41782653.negtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断是否满足发动条件：手牌或场上存在恐龙族怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c41782653.desfilter,tp,LOCATION_HAND+LOCATION_MZONE,0,1,nil) end
	-- 设置操作信息：破坏手牌或场上的怪兽
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,nil,1,tp,LOCATION_HAND+LOCATION_MZONE)
	-- 设置操作信息：无效对方发动
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	if re:GetHandler():IsDestructable() and re:GetHandler():IsRelateToEffect(re) then
		-- 设置操作信息：破坏对方发动的魔法或陷阱
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
	end
end
-- 执行效果处理：选择并破坏怪兽，无效对方发动，破坏对方发动的魔法或陷阱
function c41782653.negop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择要破坏的恐龙族怪兽
	local g1=Duel.SelectMatchingCard(tp,c41782653.desfilter,tp,LOCATION_HAND+LOCATION_MZONE,0,1,1,nil)
	-- 判断是否成功破坏怪兽
	if g1:GetCount()>0 and Duel.Destroy(g1,REASON_EFFECT)~=0 then
		-- 判断是否可以无效对方发动
		if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) then
			-- 破坏对方发动的魔法或陷阱
			Duel.Destroy(eg,REASON_EFFECT)
		end
	end
end
-- 判断是否满足发动条件：被效果送入墓地
function c41782653.thcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsReason(REASON_EFFECT)
end
-- 检索满足条件的卡片组：卡组中「进化药」魔法卡
function c41782653.thfilter(c)
	return c:IsSetCard(0x10e) and c:IsType(TYPE_SPELL) and c:IsAbleToHand()
end
-- 设置效果处理信息：从卡组检索1张「进化药」魔法卡加入手牌
function c41782653.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断是否满足发动条件：卡组中存在「进化药」魔法卡
	if chk==0 then return Duel.IsExistingMatchingCard(c41782653.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息：将卡组中的魔法卡加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 执行效果处理：选择并加入手牌，确认对方看到卡牌
function c41782653.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择要加入手牌的「进化药」魔法卡
	local g=Duel.SelectMatchingCard(tp,c41782653.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的魔法卡加入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 确认对方看到选中的魔法卡
		Duel.ConfirmCards(1-tp,g)
	end
end
