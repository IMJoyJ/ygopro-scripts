--聖騎士ボールス
-- 效果：
-- ①：这张卡只要在怪兽区域存在，当作通常怪兽使用。
-- ②：只要这张卡有「圣剑」装备魔法卡装备，这张卡变成当作效果怪兽使用并得到以下效果。
-- ●这张卡等级上升1星并变成暗属性。
-- ●自己主要阶段才能发动。从卡组把3张「圣剑」卡给对方观看，对方从那之中随机选1张。那1张卡加入自己手卡，剩余送去墓地。这个卡名的这个效果1回合只能使用1次。
function c47120245.initial_effect(c)
	-- ①：这张卡只要在怪兽区域存在，当作通常怪兽使用。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetCode(EFFECT_ADD_TYPE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(c47120245.eqcon1)
	e1:SetValue(TYPE_NORMAL)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_REMOVE_TYPE)
	e2:SetValue(TYPE_EFFECT)
	c:RegisterEffect(e2)
	-- ②：只要这张卡有「圣剑」装备魔法卡装备，这张卡变成当作效果怪兽使用并得到以下效果。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e3:SetCode(EFFECT_CHANGE_ATTRIBUTE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCondition(c47120245.eqcon2)
	e3:SetValue(ATTRIBUTE_DARK)
	c:RegisterEffect(e3)
	local e4=e3:Clone()
	e4:SetCode(EFFECT_UPDATE_LEVEL)
	e4:SetValue(1)
	c:RegisterEffect(e4)
	-- ●自己主要阶段才能发动。从卡组把3张「圣剑」卡给对方观看，对方从那之中随机选1张。那1张卡加入自己手卡，剩余送去墓地。这个卡名的这个效果1回合只能使用1次。
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(47120245,0))  --"检索"
	e5:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e5:SetType(EFFECT_TYPE_IGNITION)
	e5:SetRange(LOCATION_MZONE)
	e5:SetCountLimit(1,47120245)
	e5:SetCondition(c47120245.thcon)
	e5:SetTarget(c47120245.thtg)
	e5:SetOperation(c47120245.thop)
	c:RegisterEffect(e5)
end
-- 当此卡没有装备「圣剑」装备魔法卡时，视为通常怪兽
function c47120245.eqcon1(e)
	return not e:GetHandler():GetEquipGroup():IsExists(Card.IsSetCard,1,nil,0x207a)
end
-- 当此卡有装备「圣剑」装备魔法卡时，视为效果怪兽
function c47120245.eqcon2(e)
	return e:GetHandler():GetEquipGroup():IsExists(Card.IsSetCard,1,nil,0x207a)
end
-- 效果发动条件：此卡有装备「圣剑」装备魔法卡
function c47120245.thcon(e,tp,eg,ep,ev,re,r,rp)
	return c47120245.eqcon2(e)
end
-- 检索过滤器：卡片为「圣剑」系列且可以加入手牌
function c47120245.thfilter(c)
	return c:IsSetCard(0x207a) and c:IsAbleToHand()
end
-- 效果发动时的确认处理：确认玩家是否能从卡组丢弃1张卡，以及卡组中是否存在至少3张「圣剑」卡
function c47120245.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家是否可以将卡组顶端1张卡送去墓地
	if chk==0 then return Duel.IsPlayerCanDiscardDeck(tp,1)
		-- 检查卡组中是否存在至少3张「圣剑」卡
		and Duel.IsExistingMatchingCard(c47120245.thfilter,tp,LOCATION_DECK,0,3,nil) end
	-- 设置效果处理信息：准备从卡组检索1张「圣剑」卡加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,0,LOCATION_DECK)
end
-- 效果处理函数：执行检索并选择1张加入手牌，其余送去墓地
function c47120245.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查玩家是否可以将卡组顶端1张卡送去墓地
	if not Duel.IsPlayerCanDiscardDeck(tp,1) then return end
	-- 获取卡组中所有「圣剑」卡的集合
	local g=Duel.GetMatchingGroup(Card.IsSetCard,tp,LOCATION_DECK,0,nil,0x207a)
	if g:GetCount()>=3 then
		-- 提示玩家选择要加入手牌的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
		local sg=g:Select(tp,3,3,nil)
		-- 向对方确认所选的3张「圣剑」卡
		Duel.ConfirmCards(1-tp,sg)
		-- 将卡组洗切
		Duel.ShuffleDeck(tp)
		local tg=sg:RandomSelect(1-tp,1)
		local tc=tg:GetFirst()
		if tc:IsAbleToHand() then
			tc:SetStatus(STATUS_TO_HAND_WITHOUT_CONFIRM,true)
			-- 将选定的卡加入玩家手牌
			Duel.SendtoHand(tc,nil,REASON_EFFECT)
			sg:RemoveCard(tc)
		end
		-- 将剩余的卡送去墓地
		Duel.SendtoGrave(sg,REASON_EFFECT)
	end
end
