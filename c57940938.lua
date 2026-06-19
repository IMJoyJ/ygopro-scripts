--ファイアウォール・ファントム
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡作为电子界族连接怪兽的连接素材送去墓地的场合才能发动。从卡组把1张「电脑网」魔法·陷阱卡加入手卡。那之后，选自己1张手卡丢弃。
-- ②：把墓地的这张卡除外才能发动。这个回合的结束阶段，从自己墓地让1只电子界族怪兽回到卡组。
function c57940938.initial_effect(c)
	-- ①：这张卡作为电子界族连接怪兽的连接素材送去墓地的场合才能发动。从卡组把1张「电脑网」魔法·陷阱卡加入手卡。那之后，选自己1张手卡丢弃。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND+CATEGORY_HANDES_SELF)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_BE_MATERIAL)
	e1:SetCountLimit(1,57940938)
	e1:SetCondition(c57940938.thcon)
	e1:SetTarget(c57940938.thtg)
	e1:SetOperation(c57940938.thop)
	c:RegisterEffect(e1)
	-- ②：把墓地的这张卡除外才能发动。这个回合的结束阶段，从自己墓地让1只电子界族怪兽回到卡组。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_GRAVE_ACTION)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,57940939)
	-- 把墓地的这张卡除外作为发动成本（Cost）
	e2:SetCost(aux.bfgcost)
	e2:SetOperation(c57940938.op)
	c:RegisterEffect(e2)
end
-- 检查这张卡是否作为电子界族连接怪兽的连接素材送去墓地
function c57940938.thcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local rc=c:GetReasonCard()
	return c:IsLocation(LOCATION_GRAVE) and r==REASON_LINK and rc:IsRace(RACE_CYBERSE)
end
-- 过滤卡组中可加入手牌的「电脑网」魔法·陷阱卡
function c57940938.thfilter(c)
	return c:IsSetCard(0x118) and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsAbleToHand()
end
-- 效果①的发动准备，检查卡组中是否存在可检索的卡，并设置检索和丢弃手牌的操作信息
function c57940938.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在至少1张满足条件的「电脑网」魔法·陷阱卡
	if chk==0 then return Duel.IsExistingMatchingCard(c57940938.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息，表示此效果包含从卡组将1张卡加入手牌的处理
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
	Duel.SetOperationInfo(0,CATEGORY_HANDES_SELF,nil,0,tp,1)
end
-- 效果①的处理，从卡组检索1张「电脑网」魔陷加入手牌，之后丢弃1张手牌
function c57940938.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从卡组选择1张满足条件的「电脑网」魔法·陷阱卡
	local g=Duel.SelectMatchingCard(tp,c57940938.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	-- 如果成功将选中的卡加入手牌
	if g:GetCount()>0 and Duel.SendtoHand(g,nil,REASON_EFFECT)~=0 and g:GetFirst():IsLocation(LOCATION_HAND) then
		-- 给对方玩家确认加入手牌的卡
		Duel.ConfirmCards(1-tp,g)
		-- 中断当前效果处理，使后续的丢弃手牌处理不与检索同时进行
		Duel.BreakEffect()
		-- 洗切玩家的手牌
		Duel.ShuffleHand(tp)
		-- 让玩家选择并丢弃1张手牌
		Duel.DiscardHand(tp,aux.TRUE,1,1,REASON_EFFECT+REASON_DISCARD,nil)
	end
end
-- 效果②的发动处理，注册一个在回合结束阶段触发的延迟效果
function c57940938.op(e,tp,eg,ep,ev,re,r,rp)
	-- 这个回合的结束阶段，从自己墓地让1只电子界族怪兽回到卡组。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_PHASE+PHASE_END)
	e1:SetCountLimit(1)
	e1:SetCondition(c57940938.tdcon)
	e1:SetOperation(c57940938.tdop)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将该结束阶段触发的效果注册给玩家
	Duel.RegisterEffect(e1,tp)
end
-- 过滤自己墓地中可以回到卡组的电子界族怪兽
function c57940938.tdfilter(c)
	return c:IsRace(RACE_CYBERSE) and c:IsAbleToDeck()
end
-- 检查自己墓地是否存在可以回到卡组的电子界族怪兽
function c57940938.tdcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己墓地中是否存在至少1只满足条件的电子界族怪兽
	return Duel.IsExistingMatchingCard(c57940938.tdfilter,tp,LOCATION_GRAVE,0,1,nil)
end
-- 结束阶段效果的具体处理，选择自己墓地1只电子界族怪兽回到卡组
function c57940938.tdop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示发动该卡的效果（显示卡片发动动画）
	Duel.Hint(HINT_CARD,0,57940938)
	-- 提示玩家选择要返回卡组的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 让玩家从墓地选择1只满足条件且不受王家长眠之谷影响的电子界族怪兽
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c57940938.tdfilter),tp,LOCATION_GRAVE,0,1,1,nil)
	if g:GetCount()>0 then
		-- 选中该卡并显示被选为对象的动画效果
		Duel.HintSelection(g)
		-- 将选中的怪兽送回卡组并洗牌
		Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	end
end
