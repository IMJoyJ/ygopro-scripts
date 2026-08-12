--王墓の石壁
-- 效果：
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：这张卡只要在场地区域存在，卡名当作「王之棺」使用。
-- ②：自己主要阶段才能发动。从卡组把1只「荷鲁斯」怪兽加入手卡。那之后，选自己1张手卡回到卡组最下面。
-- ③：自己把「荷鲁斯之黑炎神」的效果发动的场合才能发动。自己抽1张。
local s,id,o=GetID()
-- 初始化卡片效果，注册场地魔法卡的发动条件和两个效果
function s.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- 使该卡在场地区域时卡号视为「王之棺」
	aux.EnableChangeCode(c,16528181,LOCATION_FZONE)
	-- ②：自己主要阶段才能发动。从卡组把1只「荷鲁斯」怪兽加入手卡。那之后，选自己1张手卡回到卡组最下面。
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
-- 检索满足条件的「荷鲁斯」怪兽的过滤函数
function s.schfilter(c)
	return c:IsSetCard(0x19d) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
-- 设置②效果的发动条件，检查是否能从卡组检索1只「荷鲁斯」怪兽
function s.schtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否能从卡组检索1只「荷鲁斯」怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(s.schfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置②效果的发动信息，表示将从卡组检索1只怪兽加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
	-- 设置②效果的发动信息，表示将从手牌选择1张卡返回卡组
	Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,1,tp,LOCATION_HAND)
end
-- 执行②效果的操作，选择卡组中的「荷鲁斯」怪兽加入手牌，并选择手牌中的1张卡返回卡组底部
function s.schop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择满足条件的卡组中的「荷鲁斯」怪兽
	local g=Duel.SelectMatchingCard(tp,s.schfilter,tp,LOCATION_DECK,0,1,1,nil)
	-- 判断是否成功将卡加入手牌
	if g:GetCount()>0 and Duel.SendtoHand(g,nil,REASON_EFFECT)~=0 then
		-- 确认对方查看加入手牌的卡
		Duel.ConfirmCards(1-tp,g)
		-- 洗切自己的手牌
		Duel.ShuffleHand(tp)
		-- 洗切自己的卡组
		Duel.ShuffleDeck(tp)
		-- 提示玩家选择要返回卡组的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
		-- 选择满足条件的手牌中的卡
		local g2=Duel.SelectMatchingCard(tp,Card.IsAbleToDeck,tp,LOCATION_HAND,0,1,1,nil)
		if #g2>0 then
			-- 中断当前效果，使之后的效果处理视为不同时处理
			Duel.BreakEffect()
			-- 将选择的手牌返回卡组底部
			Duel.SendtoDeck(g2,nil,SEQ_DECKBOTTOM,REASON_EFFECT)
		end
	end
end
-- 判断是否为己方发动「荷鲁斯之黑炎神」的效果
function s.drcon(e,tp,eg,ep,ev,re,r,rp)
	return rp==tp and re:GetHandler():IsCode(99307040)
end
-- 设置③效果的发动条件，检查是否可以抽1张卡
function s.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否可以抽1张卡
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1) end
	-- 设置③效果的目标玩家为当前玩家
	Duel.SetTargetPlayer(tp)
	-- 设置③效果的目标参数为抽1张卡
	Duel.SetTargetParam(1)
	-- 设置③效果的发动信息，表示将抽1张卡
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
-- 执行③效果的操作，抽1张卡
function s.drop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取连锁的目标玩家和目标参数
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 执行抽卡操作
	Duel.Draw(p,d,REASON_EFFECT)
end
