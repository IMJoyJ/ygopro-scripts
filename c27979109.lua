--武装鍛錬
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：自己抽卡阶段作为进行通常抽卡的代替才能发动。从自己的卡组·墓地选1张装备魔法卡加入手卡。
-- ②：自己场上有装备魔法卡存在的场合，从自己墓地让1只战士族·炎属性怪兽或者二重怪兽回到卡组最下面才能发动。自己从卡组抽1张。
function c27979109.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- 这个卡名的①②的效果1回合各能使用1次。①：自己抽卡阶段作为进行通常抽卡的代替才能发动。从自己的卡组·墓地选1张装备魔法卡加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(27979109,0))
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_PREDRAW)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1,27979109)
	e2:SetCondition(c27979109.thcon)
	e2:SetTarget(c27979109.thtg)
	e2:SetOperation(c27979109.thop)
	c:RegisterEffect(e2)
	-- ②：自己场上有装备魔法卡存在的场合，从自己墓地让1只战士族·炎属性怪兽或者二重怪兽回到卡组最下面才能发动。自己从卡组抽1张。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(27979109,1))
	e3:SetCategory(CATEGORY_DRAW)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCountLimit(1,27979110)
	e3:SetCondition(c27979109.drcon)
	e3:SetCost(c27979109.drcost)
	e3:SetTarget(c27979109.drtg)
	e3:SetOperation(c27979109.drop)
	c:RegisterEffect(e3)
end
c27979109.has_text_type=TYPE_DUAL
-- ①效果的发动条件：仅在己方抽卡阶段才能发动，即效果发动者必须是当前回合玩家。
function c27979109.thcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判定tp是否为当前回合玩家，确保该效果只在自己回合的抽卡阶段满足发动条件。
	return tp==Duel.GetTurnPlayer()
end
-- ①的检索对象过滤条件：装备魔法卡且能够加入手牌。
function c27979109.thfilter(c)
	return c:IsType(TYPE_EQUIP) and c:IsAbleToHand()
end
-- ①效果发动时处理：先检查能否通常抽卡以及卡组·墓地是否有符合条件的装备魔法卡；若可发动，则放弃本次通常抽卡，并设置从卡组·墓地选1张加入手牌的操作信息。
function c27979109.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 合法性检查：自己本回合可进行通常抽卡，且卡组或墓地存在至少1张符合条件的装备魔法卡。
	if chk==0 then return aux.IsPlayerCanNormalDraw(tp) and Duel.IsExistingMatchingCard(c27979109.thfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil) end
	-- 放弃本次通常抽卡，作为代替抽卡效果的发动代价，并将常规抽卡数设为0且注册不可抽卡限制。
	aux.GiveUpNormalDraw(e,tp)
	-- 设置操作信息：本次效果为把1张卡从卡组或墓地加入手牌，count为1（处理时选择具体卡片）。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,0,LOCATION_DECK+LOCATION_GRAVE)
end
-- ①效果处理：从自己卡组或墓地选择1张不受王家长眠之谷影响的装备魔法卡加入手牌；加入成功则给对方确认。
function c27979109.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 显示选择提示：请选择要加入手牌的卡（HINTMSG_ATOHAND）。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从自己的卡组或墓地中选择1张符合条件的装备魔法卡（使用不受王家长眠之谷影响的过滤条件；不取对象，在处理时选择）。
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c27979109.thfilter),tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选择的装备魔法卡加入其持有者的手牌，原因为效果（REASON_EFFECT）。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方玩家展示加入手牌的卡，以确认检索结果。
		Duel.ConfirmCards(1-tp,g)
	end
end
-- ②的条件过滤：表侧表示的装备魔法卡，用于判断自己场上是否存在装备魔法卡。
function c27979109.cfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_EQUIP)
end
-- ②效果的发动条件：自己场上有表侧表示的装备魔法卡存在。
function c27979109.drcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己魔陷区是否存在至少1张表侧表示的装备魔法卡。
	return Duel.IsExistingMatchingCard(c27979109.cfilter,tp,LOCATION_SZONE,0,1,nil)
end
-- ②的cost对象过滤：从墓地选择1只战士族·炎属性怪兽或者二重怪兽，且能够作为cost返回卡组。
function c27979109.costfilter(c)
	return ((c:IsAttribute(ATTRIBUTE_FIRE) and c:IsRace(RACE_WARRIOR)) or c:IsType(TYPE_DUAL)) and c:IsAbleToDeckAsCost()
end
-- ②发动cost：从自己墓地选择1只战士族·炎属性怪兽或二重怪兽，将其返回持有者卡组最下面。
function c27979109.drcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- cost合法性检查：自己墓地是否存在至少1只符合条件的怪兽可作为返回卡组的cost。
	if chk==0 then return Duel.IsExistingMatchingCard(c27979109.costfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 显示选择提示：请选择要返回卡组的卡（HINTMSG_TODECK）。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 从自己墓地选择1只符合条件的怪兽（战士族·炎属性或二重）作为cost。
	local g=Duel.SelectMatchingCard(tp,c27979109.costfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 将作为cost的卡返回持有者卡组最下面（SEQ_DECKBOTTOM），原因为cost（REASON_COST）。
	Duel.SendtoDeck(g,nil,SEQ_DECKBOTTOM,REASON_COST)
end
-- ②效果发动前处理：检查能否抽1张卡；设置抽卡对象为自己、抽卡数为1，并登记操作信息。
function c27979109.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 合法性检查：玩家tp能否通过效果抽1张卡（不受不能抽卡限制等）。
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1) end
	-- 设置连锁的对象玩家为自己（tp），供后续抽卡处理使用。
	Duel.SetTargetPlayer(tp)
	-- 设置连锁的对象参数为1，表示抽卡数量为1张。
	Duel.SetTargetParam(1)
	-- 设置操作信息：本次效果为抽卡效果，目标玩家为自己，抽卡数量为1。
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
-- ②效果处理：从连锁信息中取出目标玩家和抽卡数量，执行抽卡。
function c27979109.drop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁信息中的目标玩家（p）和对象参数（d），即抽牌玩家与抽卡数。
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 让玩家p以效果原因（REASON_EFFECT）抽d张卡。
	Duel.Draw(p,d,REASON_EFFECT)
end
