--王墓の石壁
-- 效果：
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：这张卡只要在场地区域存在，卡名当作「王之棺」使用。
-- ②：自己主要阶段才能发动。从卡组把1只「荷鲁斯」怪兽加入手卡。那之后，选自己1张手卡回到卡组最下面。
-- ③：自己把「荷鲁斯之黑炎神」的效果发动的场合才能发动。自己抽1张。
local s,id,o=GetID()
-- 为「王墓的石壁」注册各效果：e1作为场地魔法允许发动；aux.EnableChangeCode实现①卡名当作「王之棺」；e2实现②检索「荷鲁斯」怪兽并选1张手卡回卡组底；e3实现③当「荷鲁斯之黑炎神」效果发动时抽1张。
function s.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- 为这张卡在场地区域注册卡名变更效果，使其卡名当作「王之棺」（卡号16528181）使用，对应①效果。
	aux.EnableChangeCode(c,16528181,LOCATION_FZONE)
	-- 这个卡名的②的效果1回合只能使用1次。②：自己主要阶段才能发动。从卡组把1只「荷鲁斯」怪兽加入手卡。那之后，选自己1张手卡回到卡组最下面。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))  --"检索"
	e2:SetCategory(CATEGORY_TODECK+CATEGORY_TOHAND+CATEGORY_SEARCH)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_FZONE)
	e2:SetCountLimit(1,id)
	e2:SetTarget(s.schtg)
	e2:SetOperation(s.schop)
	c:RegisterEffect(e2)
	-- ③：自己把「荷鲁斯之黑炎神」的效果发动的场合才能发动。自己抽1张。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))  --"抽卡"
	e3:SetCategory(CATEGORY_DRAW)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_CHAINING)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetRange(LOCATION_FZONE)
	e3:SetCondition(s.drcon)
	e3:SetTarget(s.drtg)
	e3:SetOperation(s.drop)
	c:RegisterEffect(e3)
end
-- 定义检索过滤条件：卡组中的卡必须是「荷鲁斯」系列怪兽（0x19d）且能够加入手卡。
function s.schfilter(c)
	return c:IsSetCard(0x19d) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
-- ②的发动条件与操作信息设置：检查卡组存在符合条件的「荷鲁斯」怪兽，并设定效果处理时将进行加入手卡和把手卡回卡组的操作。
function s.schtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 效果发动合法性检查：仅在卡组中存在至少1只满足条件的「荷鲁斯」怪兽时，该效果才可发动。
	if chk==0 then return Duel.IsExistingMatchingCard(s.schfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息，告知系统本次效果处理将把1张卡从卡组加入手卡（用于连锁判定等）。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
	-- 设置操作信息，告知系统本次效果处理将把1张手卡回到卡组（用于连锁判定等）。
	Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,1,tp,LOCATION_HAND)
end
-- ②的效果处理：从卡组选1只「荷鲁斯」怪兽加入手卡，向对方确认并洗切手牌和卡组；然后再选自己1张手卡回到卡组最下面。
function s.schop(e,tp,eg,ep,ev,re,r,rp)
	-- 弹出选择提示，要求玩家选择要加入手卡的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从卡组中选择1张满足条件的「荷鲁斯」怪兽并保存到临时变量g。
	local g=Duel.SelectMatchingCard(tp,s.schfilter,tp,LOCATION_DECK,0,1,1,nil)
	-- 如果成功选择了卡且该卡成功加入手卡，则继续执行后续把手卡回卡组的处理。
	if g:GetCount()>0 and Duel.SendtoHand(g,nil,REASON_EFFECT)~=0 then
		-- 将加入手卡的卡展示给对方玩家确认。
		Duel.ConfirmCards(1-tp,g)
		-- 洗切自己的手卡，使手牌顺序随机化，避免因检索确认暴露手牌信息。
		Duel.ShuffleHand(tp)
		-- 洗切自己的卡组，因为从卡组检索了卡。
		Duel.ShuffleDeck(tp)
		-- 弹出选择提示，要求玩家选择要返回卡组的卡。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
		-- 从自己手卡中选择1张可以回到卡组的卡，用于后续放回卡组最下面。
		local g2=Duel.SelectMatchingCard(tp,Card.IsAbleToDeck,tp,LOCATION_HAND,0,1,1,nil)
		if #g2>0 then
			-- 中断当前效果链，使后续的“回卡组”处理与之前的检索处理视为不同时处理，以符合“那之后”的时点关系。
			Duel.BreakEffect()
			-- 将选中的手卡以效果原因送回持有者卡组最下面。
			Duel.SendtoDeck(g2,nil,SEQ_DECKBOTTOM,REASON_EFFECT)
		end
	end
end
-- ③的发动条件：自己发动「荷鲁斯之黑炎神」（卡号99307040）的效果的场合，此效果可发动。
function s.drcon(e,tp,eg,ep,ev,re,r,rp)
	return rp==tp and re:GetHandler():IsCode(99307040)
end
-- ③的发动判定与操作信息：确认自己可以抽1张卡，并指定抽卡玩家为自己、抽卡数量为1。
function s.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动合法性检查：确认自己是否可以抽1张卡。
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1) end
	-- 将当前连锁的对象玩家设为自己，表示抽卡玩家是自己。
	Duel.SetTargetPlayer(tp)
	-- 将当前连锁的对象参数设为1，表示抽卡数量为1。
	Duel.SetTargetParam(1)
	-- 设置操作信息，告知系统本次效果处理将让tp抽1张卡。
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
-- ③的效果处理：根据设定的目标玩家和参数执行抽卡，让自己抽1张卡。
function s.drop(e,tp,eg,ep,ev,re,r,rp)
	-- 从当前连锁信息中取出之前设定的目标玩家和参数（抽卡玩家与抽卡数量）。
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 让目标玩家p抽d张卡（d=1），以效果原因执行抽卡。
	Duel.Draw(p,d,REASON_EFFECT)
end
