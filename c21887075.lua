--無尽機関アルギロ・システム
-- 效果：
-- 这个卡名的①②的效果1回合只能有1次使用其中任意1个。
-- ①：从卡组把1张「兽带斗神」卡送去墓地。
-- ②：这张卡在墓地存在的场合，以自己墓地1张「兽带斗神」卡为对象才能发动。那张卡和这张卡之内1张加入手卡，另1张回到卡组最下面。
function c21887075.initial_effect(c)
	-- ①：从卡组把1张「兽带斗神」卡送去墓地。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(21887075,0))  --"送去墓地"
	e1:SetCategory(CATEGORY_TOGRAVE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,21887075)
	e1:SetTarget(c21887075.target)
	e1:SetOperation(c21887075.activate)
	c:RegisterEffect(e1)
	-- ②：这张卡在墓地存在的场合，以自己墓地1张「兽带斗神」卡为对象才能发动。那张卡和这张卡之内1张加入手卡，另1张回到卡组最下面。
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
-- 过滤函数，用于检测卡组中是否存在可送去墓地的「兽带斗神」卡。
function c21887075.tgfilter(c)
	return c:IsSetCard(0x179) and c:IsAbleToGrave()
end
-- 效果处理时的判断函数，检查是否满足发动条件并设置操作信息。
function c21887075.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断在卡组中是否存在至少1张满足条件的「兽带斗神」卡。
	if chk==0 then return Duel.IsExistingMatchingCard(c21887075.tgfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置连锁操作信息，表示将有1张卡从卡组送去墓地。
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end
-- 发动效果时执行的操作函数，用于选择并把卡送去墓地。
function c21887075.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要送去墓地的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 从卡组中选择1张满足条件的「兽带斗神」卡。
	local g=Duel.SelectMatchingCard(tp,c21887075.tgfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡送去墓地。
		Duel.SendtoGrave(g,REASON_EFFECT)
	end
end
-- 过滤函数，用于检测墓地中可被选为对象的「兽带斗神」卡。
function c21887075.filter(c,b1,b2)
	return c:IsSetCard(0x179) and ((b1 and c:IsAbleToHand()) or (b2 and c:IsAbleToDeck()))
end
-- 效果处理时的判断函数，检查是否满足发动条件并设置操作信息。
function c21887075.tg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	local b1,b2=c:IsAbleToDeck(),c:IsAbleToHand()
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c21887075.filter(chkc,b1,b2) end
	-- 判断在墓地中是否存在至少1张满足条件的「兽带斗神」卡。
	if chk==0 then return Duel.IsExistingTarget(c21887075.filter,tp,LOCATION_GRAVE,0,1,nil,b1,b2) end
	-- 提示玩家选择效果的对象。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 从墓地中选择1张满足条件的「兽带斗神」卡作为对象。
	local g=Duel.SelectTarget(tp,c21887075.filter,tp,LOCATION_GRAVE,0,1,1,nil,b1,b2)
	-- 设置连锁操作信息，表示将有1张卡从墓地加入手牌。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_GRAVE)
	-- 设置连锁操作信息，表示将有1张卡从墓地回到卡组最下面。
	Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,1,tp,LOCATION_GRAVE)
end
-- 发动效果时执行的操作函数，用于选择卡并进行处理。
function c21887075.op(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁效果的目标卡。
	local tc=Duel.GetFirstTarget()
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and tc:IsRelateToEffect(e) then
		local g=Group.FromCards(tc,c)
		-- 提示玩家选择要加入手牌的卡。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
		local tg=g:FilterSelect(tp,Card.IsAbleToHand,1,1,nil)
		g:Sub(tg)
		-- 将选中的卡加入手牌。
		Duel.SendtoHand(tg,nil,REASON_EFFECT)
		-- 向对方确认加入手牌的卡。
		Duel.ConfirmCards(1-tp,tg:GetFirst())
		-- 将剩余的卡回到卡组最下面。
		Duel.SendtoDeck(g,nil,SEQ_DECKBOTTOM,REASON_EFFECT)
	end
end
