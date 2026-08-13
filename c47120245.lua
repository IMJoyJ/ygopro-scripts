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
	-- ●这张卡等级上升1星并变成暗属性。
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
-- 判定该卡是否没有装备「圣剑」装备魔法卡：若其装备区不存在卡名含有「圣剑」的卡则返回true，用于使①的『当作通常怪兽』效果生效。
function c47120245.eqcon1(e)
	return not e:GetHandler():GetEquipGroup():IsExists(Card.IsSetCard,1,nil,0x207a)
end
-- 判定该卡是否装备有「圣剑」装备魔法卡：若其装备区存在卡名含有「圣剑」的卡则返回true，用于②的『变成当作效果怪兽使用』及其追加效果的生效条件。
function c47120245.eqcon2(e)
	return e:GetHandler():GetEquipGroup():IsExists(Card.IsSetCard,1,nil,0x207a)
end
-- 检索效果的发动条件：直接复用eqcon2，即只有这张卡装备着「圣剑」时，才能发动『自己主要阶段才能发动』的检索效果。
function c47120245.thcon(e,tp,eg,ep,ev,re,r,rp)
	return c47120245.eqcon2(e)
end
-- 检索的筛选条件：卡名含有「圣剑」字段并且能够加入手卡（不受『不能加入手卡』效果限制）。
function c47120245.thfilter(c)
	return c:IsSetCard(0x207a) and c:IsAbleToHand()
end
-- 检索效果的目标/合法性判定：在chk==0时，要求玩家可以把卡组顶1张卡送去墓地，且卡组中存在至少3张满足检索条件的「圣剑」卡，否则不能发动。
function c47120245.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 作为合法发动条件之一：确认玩家可以将卡组顶1张卡送去墓地（用于后续未被选中的卡送去墓地）。
	if chk==0 then return Duel.IsPlayerCanDiscardDeck(tp,1)
		-- 作为合法发动条件之一：卡组中存在至少3张满足thfilter筛选条件的「圣剑」卡（可加入手卡的「圣剑」卡）。
		and Duel.IsExistingMatchingCard(c47120245.thfilter,tp,LOCATION_DECK,0,3,nil) end
	-- 设置连锁操作信息：本次效果涉及从卡组把1张卡加入手卡（CATEGORY_TOHAND），因最终加入手卡的卡由对方随机选择而不确定，targets设为nil，数量记为1，位置为卡组，以便其他卡正确连锁响应。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,0,LOCATION_DECK)
end
-- 效果处理：若不能把卡组中的卡送去墓地则直接终止；从卡组中取出所有「圣剑」卡，若数量≥3，则操作者从中选3张展示给对方，洗切卡组；由对方随机选1张，该卡加入持有者手卡（并标记为无需确认），其余卡送去墓地。
function c47120245.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 效果处理开始时，若玩家不能把卡组中的卡送去墓地（因为剩余卡需要送墓），则本效果不处理。
	if not Duel.IsPlayerCanDiscardDeck(tp,1) then return end
	-- 获取我方卡组中所有卡名含有「圣剑」字段的卡（不要求能否加入手卡，后续会单独判断）。
	local g=Duel.GetMatchingGroup(Card.IsSetCard,tp,LOCATION_DECK,0,nil,0x207a)
	if g:GetCount()>=3 then
		-- 向操作玩家发出‘请选择要加入手牌的卡’的选择提示，用于从卡组选出3张要展示的「圣剑」卡。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
		local sg=g:Select(tp,3,3,nil)
		-- 将选出的3张「圣剑」卡展示给对方玩家确认。
		Duel.ConfirmCards(1-tp,sg)
		-- 洗切我方卡组，因为从卡组中取出了卡片，需要重新洗牌以保证后续随机选择的随机性。
		Duel.ShuffleDeck(tp)
		local tg=sg:RandomSelect(1-tp,1)
		local tc=tg:GetFirst()
		if tc:IsAbleToHand() then
			tc:SetStatus(STATUS_TO_HAND_WITHOUT_CONFIRM,true)
			-- 将对方随机选中的那张「圣剑」卡加入其持有者的手卡，原因记为效果（REASON_EFFECT）。
			Duel.SendtoHand(tc,nil,REASON_EFFECT)
			sg:RemoveCard(tc)
		end
		-- 将剩余未被选中的「圣剑」卡全部送去墓地，原因记为效果（REASON_EFFECT）。
		Duel.SendtoGrave(sg,REASON_EFFECT)
	end
end
