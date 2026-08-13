--無尽機関アルギロ・システム
-- 效果：
-- 这个卡名的①②的效果1回合只能有1次使用其中任意1个。
-- ①：从卡组把1张「兽带斗神」卡送去墓地。
-- ②：这张卡在墓地存在的场合，以自己墓地1张「兽带斗神」卡为对象才能发动。那张卡和这张卡之内1张加入手卡，另1张回到卡组最下面。
function c21887075.initial_effect(c)
	-- 这个卡名的①②的效果1回合只能有1次使用其中任意1个。①：从卡组把1张「兽带斗神」卡送去墓地。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(21887075,0))  --"送去墓地"
	e1:SetCategory(CATEGORY_TOGRAVE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,21887075)
	e1:SetTarget(c21887075.target)
	e1:SetOperation(c21887075.activate)
	c:RegisterEffect(e1)
	-- 这个卡名的①②的效果1回合只能有1次使用其中任意1个。②：这张卡在墓地存在的场合，以自己墓地1张「兽带斗神」卡为对象才能发动。那张卡和这张卡之内1张加入手卡，另1张回到卡组最下面。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(21887075,1))  --"墓地回收"
	e2:SetCategory(CATEGORY_TODECK+CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCountLimit(1,21887075)
	e2:SetTarget(c21887075.tg)
	e2:SetOperation(c21887075.op)
	c:RegisterEffect(e2)
end
-- 定义①效果中从卡组送墓的筛选条件：卡名含「兽带斗神」字段且可以送去墓地的卡。
function c21887075.tgfilter(c)
	return c:IsSetCard(0x179) and c:IsAbleToGrave()
end
-- ①效果发动前的合法性检查与操作信息登记：若卡组中存在符合条件的「兽带斗神」卡，则允许发动，并登记从卡组送墓1张卡的处理信息。
function c21887075.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动条件判定：只在卡组中存在至少1张满足「兽带斗神」字段且能送去墓地的卡时，才允许发动①效果。
	if chk==0 then return Duel.IsExistingMatchingCard(c21887075.tgfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 登记①效果处理时将进行的“从卡组把1张卡送去墓地”的操作信息，使相关效果（如星尘龙等）能正确互动。
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end
-- ①效果的实际处理：玩家从卡组选择1张符合条件的「兽带斗神」卡，并将其送去墓地。
function c21887075.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家进行选择，提示内容为“请选择要送去墓地的卡”。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 玩家从自己卡组选择1张满足 tgfilter 的「兽带斗神」卡（效果处理时选择，不取对象）。
	local g=Duel.SelectMatchingCard(tp,c21887075.tgfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡以效果原因送去墓地。
		Duel.SendtoGrave(g,REASON_EFFECT)
	end
end
-- 定义②效果对象的筛选条件：卡名含「兽带斗神」字段，且根据自身能否回卡组/加入手牌，至少能够进行其中一种操作。
function c21887075.filter(c,b1,b2)
	return c:IsSetCard(0x179) and ((b1 and c:IsAbleToHand()) or (b2 and c:IsAbleToDeck()))
end
-- ②效果的发动判定、取对象与操作信息登记：检查自身回卡组/手牌的可用性，选择墓地1张「兽带斗神」卡为对象，并登记1张加入手牌、1张回卡组的处理信息。
function c21887075.tg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	local b1,b2=c:IsAbleToDeck(),c:IsAbleToHand()
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c21887075.filter(chkc,b1,b2) end
	-- 发动合法性判定：仅当自己墓地存在至少1张满足 filter 条件（「兽带斗神」字段且可加入手牌或回卡组）的卡时，才允许发动②效果。
	if chk==0 then return Duel.IsExistingTarget(c21887075.filter,tp,LOCATION_GRAVE,0,1,nil,b1,b2) end
	-- 提示玩家选择对象，提示内容为“请选择效果的对象”。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 玩家从自己墓地选择1张符合条件的「兽带斗神」卡作为效果对象，并将其设为当前连锁对象（取对象效果）。
	local g=Duel.SelectTarget(tp,c21887075.filter,tp,LOCATION_GRAVE,0,1,1,nil,b1,b2)
	-- 登记②效果处理时将会有1张卡从墓地加入手牌的操作信息。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_GRAVE)
	-- 登记②效果处理时将会有1张卡从墓地回到卡组的操作信息。
	Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,1,tp,LOCATION_GRAVE)
end
-- ②效果的实际处理：将对象卡与自身（均在墓地）组成一组，由玩家选择1张加入手牌，另一张回到持有者卡组最下面。
function c21887075.op(e,tp,eg,ep,ev,re,r,rp)
	-- 取得②效果发动时选择的对象卡（墓地的那1张「兽带斗神」卡）。
	local tc=Duel.GetFirstTarget()
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and tc:IsRelateToEffect(e) then
		local g=Group.FromCards(tc,c)
		-- 提示玩家选择要加入手牌的卡，提示内容为“请选择要加入手牌的卡”。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
		local tg=g:FilterSelect(tp,Card.IsAbleToHand,1,1,nil)
		g:Sub(tg)
		-- 将玩家选择加入手牌的那张卡以效果原因加入其持有者手牌。
		Duel.SendtoHand(tg,nil,REASON_EFFECT)
		-- 向对方玩家展示确认加入手牌的那张卡。
		Duel.ConfirmCards(1-tp,tg:GetFirst())
		-- 将另一张未加入手牌的卡以效果原因送回持有者卡组最下面。
		Duel.SendtoDeck(g,nil,SEQ_DECKBOTTOM,REASON_EFFECT)
	end
end
