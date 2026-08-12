--Kozmo－エメラルドポリス
-- 效果：
-- ①：1回合1次，以除外的1只自己的「星际仙踪」怪兽为对象才能发动。那只怪兽回到手卡，自己失去那只怪兽的原本等级×100基本分。
-- ②：1回合1次，自己主要阶段才能发动。手卡的「星际仙踪」怪兽任意数量给对方观看，回到卡组洗切。那之后，自己从卡组抽出回到卡组的数量。
-- ③：场地区域的这张卡被效果破坏的场合才能发动。从卡组把1张「星际仙踪」卡加入手卡。
function c67237709.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- ①：1回合1次，以除外的1只自己的「星际仙踪」怪兽为对象才能发动。那只怪兽回到手卡，自己失去那只怪兽的原本等级×100基本分。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(67237709,0))  --"除外的「星际仙踪」怪兽回到手卡"
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_FZONE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCountLimit(1)
	e2:SetTarget(c67237709.thtg)
	e2:SetOperation(c67237709.thop)
	c:RegisterEffect(e2)
	-- ②：1回合1次，自己主要阶段才能发动。手卡的「星际仙踪」怪兽任意数量给对方观看，回到卡组洗切。那之后，自己从卡组抽出回到卡组的数量。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(67237709,1))  --"手卡的「星际仙踪」怪兽回到卡组并抽卡"
	e3:SetCategory(CATEGORY_TODECK+CATEGORY_DRAW)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_FZONE)
	e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e3:SetCountLimit(1)
	e3:SetTarget(c67237709.drtg)
	e3:SetOperation(c67237709.drop)
	c:RegisterEffect(e3)
	-- ③：场地区域的这张卡被效果破坏的场合才能发动。从卡组把1张「星际仙踪」卡加入手卡。
	local e4=Effect.CreateEffect(c)
	e4:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_DESTROYED)
	e4:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e4:SetCondition(c67237709.thcon2)
	e4:SetTarget(c67237709.thtg2)
	e4:SetOperation(c67237709.thop2)
	c:RegisterEffect(e4)
end
-- 过滤条件：表侧表示的、除外的、属于「星际仙踪」系列且可以加入手卡的怪兽卡
function c67237709.thfilter(c)
	return c:IsFaceup() and c:IsSetCard(0xd2) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
-- 效果①的发动准备：检查是否存在可作为对象的卡，并选择1只除外的「星际仙踪」怪兽作为对象，设置操作信息为加入手卡
function c67237709.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_REMOVED) and c67237709.thfilter(chkc) end
	-- 检查除外区是否存在至少1只满足条件的「星际仙踪」怪兽
	if chk==0 then return Duel.IsExistingTarget(c67237709.thfilter,tp,LOCATION_REMOVED,0,1,nil) end
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 玩家选择除外的1只「星际仙踪」怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c67237709.thfilter,tp,LOCATION_REMOVED,0,1,1,nil)
	-- 设置连锁的操作信息为：将选中的1张卡加入手卡
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- 效果①的处理：将作为对象的怪兽回到手卡，并使自己失去该怪兽原本等级×100的生命值
function c67237709.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中被选为对象的卡片
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标怪兽因效果送回持有者的手卡
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
		-- 让对方玩家确认加入手卡的卡片
		Duel.ConfirmCards(1-tp,tc)
		local lv=tc:GetOriginalLevel()
		-- 获取发动效果玩家的当前生命值
		local lp=Duel.GetLP(tp)
		-- 扣除发动效果玩家等同于该怪兽原本等级×100的生命值
		Duel.SetLP(tp,lp-lv*100)
	end
end
-- 过滤条件：手卡中属于「星际仙踪」系列、可以回到卡组的怪兽卡
function c67237709.drfilter(c)
	return c:IsSetCard(0xd2) and c:IsType(TYPE_MONSTER) and c:IsAbleToDeck()
end
-- 效果②的发动准备：检查玩家是否可以抽卡以及手卡中是否存在可回到卡组的「星际仙踪」怪兽，并设置操作信息
function c67237709.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家当前是否具有抽卡的效果许可
	if chk==0 then return Duel.IsPlayerCanDraw(tp)
		-- 并且检查手卡中是否存在至少1张可以回到卡组的「星际仙踪」怪兽
		and Duel.IsExistingMatchingCard(c67237709.drfilter,tp,LOCATION_HAND,0,1,nil) end
	-- 将当前连锁的影响对象玩家设置为发动效果的玩家
	Duel.SetTargetPlayer(tp)
	-- 设置连锁的操作信息为：将手卡中的卡片送回卡组
	Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,1,tp,LOCATION_HAND)
end
-- 效果②的处理：让对方确认手卡中任意数量的「星际仙踪」怪兽并送回卡组洗切，之后自己抽出相同数量的卡
function c67237709.drop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的目标玩家（即发动效果的玩家）
	local p=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER)
	-- 提示玩家选择要送回卡组的卡片
	Duel.Hint(HINT_SELECTMSG,p,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 玩家选择手卡中任意数量（1到63张）满足条件的「星际仙踪」怪兽
	local g=Duel.SelectMatchingCard(p,c67237709.drfilter,p,LOCATION_HAND,0,1,63,nil)
	if g:GetCount()>0 then
		-- 将选中的卡片给对方玩家观看确认
		Duel.ConfirmCards(1-p,g)
		-- 将选中的卡片送回卡组并洗切，返回实际送回卡组的卡片数量
		local ct=Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
		-- 手动洗切该玩家的卡组
		Duel.ShuffleDeck(p)
		-- 中断当前效果处理，使后续的抽卡处理与送回卡组不视为同时进行（防止错时点）
		Duel.BreakEffect()
		-- 玩家从卡组抽出与送回卡组数量相同的卡片
		Duel.Draw(p,ct,REASON_EFFECT)
	end
end
-- 效果③的发动条件：这张卡因效果被破坏，且被破坏前存在于场地区域
function c67237709.thcon2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsReason(REASON_EFFECT) and c:IsPreviousLocation(LOCATION_FZONE)
end
-- 过滤条件：卡组中属于「星际仙踪」系列且可以加入手卡的卡片
function c67237709.thfilter2(c)
	return c:IsSetCard(0xd2) and c:IsAbleToHand()
end
-- 效果③的发动准备：检查卡组中是否存在可检索的「星际仙踪」卡，并设置操作信息为检索卡组
function c67237709.thtg2(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在至少1张「星际仙踪」卡片
	if chk==0 then return Duel.IsExistingMatchingCard(c67237709.thfilter2,tp,LOCATION_DECK,0,1,nil) end
	-- 设置连锁的操作信息为：从卡组将1张卡加入手卡
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果③的处理：从卡组选择1张「星际仙踪」卡加入手卡并给对方确认
function c67237709.thop2(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 玩家从卡组中选择1张「星际仙踪」卡片
	local g=Duel.SelectMatchingCard(tp,c67237709.thfilter2,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡片加入玩家手卡
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 让对方玩家确认加入手卡的卡片
		Duel.ConfirmCards(1-tp,g)
	end
end
