--クリアー・ファントム
-- 效果：
-- 这个卡名的①的效果1回合只能使用1次。
-- ①：把包含这张卡的2张手卡丢弃才能发动。把「清透世界」或者有那个卡名记述的魔法·陷阱卡合计2张从卡组加入手卡。
-- ②：只要这张卡在怪兽区域存在，「清透世界」的效果对自己不适用。
-- ③：这张卡被破坏的场合，以对方场上1只怪兽为对象才能发动。那只怪兽破坏，从对方卡组上面把3张卡送去墓地。
local s,id,o=GetID()
-- 初始化卡片效果（注册效果1、效果2、效果3）
function s.initial_effect(c)
	-- 注册该卡片记述了「清透世界」（卡号33900648）
	aux.AddCodeList(c,33900648)
	-- ①：把包含这张卡的2张手卡丢弃才能发动。把「清透世界」或者有那个卡名记述的魔法·陷阱卡合计2张从卡组加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id)
	e1:SetCost(s.thcost)
	e1:SetTarget(s.thtg)
	e1:SetOperation(s.thop)
	c:RegisterEffect(e1)
	-- ②：只要这张卡在怪兽区域存在，「清透世界」的效果对自己不适用。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(1,0)
	e2:SetCode(97811903)
	c:RegisterEffect(e2)
	-- ③：这张卡被破坏的场合，以对方场上1只怪兽为对象才能发动。那只怪兽破坏，从对方卡组上面把3张卡送去墓地。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetCategory(CATEGORY_DESTROY+CATEGORY_DECKDES)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_DESTROYED)
	e3:SetTarget(s.destg)
	e3:SetOperation(s.desop)
	c:RegisterEffect(e3)
end
-- 过滤可以丢弃的手牌的条件函数
function s.costfilter(c)
	return c:IsDiscardable()
end
-- 效果①的发动代价（Cost）处理函数
function s.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 检查手牌中是否存在除这张卡以外的至少1张可以丢弃的卡，且这张卡自身也能丢弃
	if chk==0 then return Duel.IsExistingMatchingCard(s.costfilter,tp,LOCATION_HAND,0,1,c) and c:IsDiscardable() end
	-- 提示玩家选择要丢弃的手牌
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISCARD)  --"请选择要丢弃的手牌"
	-- 让玩家从手牌选择1张除自身以外的卡
	local g=Duel.SelectMatchingCard(tp,s.costfilter,tp,LOCATION_HAND,0,1,1,c)
	g:AddCard(c)
	-- 将选中的卡和这张卡一起作为发动代价丢弃送去墓地
	Duel.SendtoGrave(g,REASON_COST+REASON_DISCARD)
end
-- 过滤「清透世界」或记述了其卡名的魔法·陷阱卡的条件函数
function s.filter(c)
	-- 检查卡片是否为「清透世界」或记述了其卡名的魔法·陷阱卡，且能加入手牌
	return (c:IsCode(33900648) or aux.IsCodeListed(c,33900648) and c:IsType(TYPE_SPELL+TYPE_TRAP)) and c:IsAbleToHand()
end
-- 效果①的发动条件与效果分类（Target）处理函数
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在至少2张满足条件的卡
	if chk==0 then return Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_DECK,0,2,nil) end
	-- 设置连锁信息，表示该效果包含从卡组将卡加入手牌的操作
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果①的效果处理（Operation）函数
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取卡组中所有满足条件的卡片组
	local rg=Duel.GetMatchingGroup(s.filter,tp,LOCATION_DECK,0,nil)
	if rg:GetCount()<2 then return end
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	local g=rg:Select(tp,2,2,nil)
	if g:GetCount()==2 then
		-- 将选中的2张卡加入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 让对方玩家确认加入手牌的卡
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 效果③的发动条件、对象选择与效果分类（Target）处理函数
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) end
	-- 检查对方场上是否存在可以作为对象的怪兽，且对方是否能从卡组上面将3张卡送去墓地
	if chk==0 then return Duel.IsExistingTarget(aux.TRUE,tp,0,LOCATION_MZONE,1,nil) and Duel.IsPlayerCanDiscardDeck(1-tp,3) end
	-- 提示玩家选择要破坏的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择对方场上1只怪兽作为效果对象
	local g=Duel.SelectTarget(tp,aux.TRUE,tp,0,LOCATION_MZONE,1,1,nil)
	-- 设置连锁信息，表示该效果包含破坏选定怪兽的操作
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
	-- 设置连锁信息，表示该效果包含将对方卡组顶端3张卡送去墓地的操作
	Duel.SetOperationInfo(0,CATEGORY_DECKDES,nil,0,1-tp,3)
end
-- 效果③的效果处理（Operation）函数
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中被选择的对象怪兽
	local tc=Duel.GetFirstTarget()
	-- 若对象怪兽仍适用效果且为怪兽，则将其破坏，并在破坏成功且对方卡组有卡时继续处理
	if tc:IsRelateToEffect(e) and tc:IsType(TYPE_MONSTER) and Duel.Destroy(tc,REASON_EFFECT)~=0 and Duel.IsPlayerCanDiscardDeck(1-tp,1) then
		-- 从对方卡组上面把3张卡送去墓地
		Duel.DiscardDeck(1-tp,3,REASON_EFFECT)
	end
end
