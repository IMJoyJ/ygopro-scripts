--ふわんだりぃずと旅じたく
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：从手卡以及自己场上的表侧表示怪兽之中把1只鸟兽族怪兽除外才能发动。从卡组把1只「随风旅鸟」怪兽或者1张「随风旅鸟」场地魔法卡加入手卡。那之后，自己回复500基本分。
function c69087397.initial_effect(c)
	-- 这个卡名的卡在1回合只能发动1张。①：从手卡以及自己场上的表侧表示怪兽之中把1只鸟兽族怪兽除外才能发动。从卡组把1只「随风旅鸟」怪兽或者1张「随风旅鸟」场地魔法卡加入手卡。那之后，自己回复500基本分。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_RECOVER)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,69087397+EFFECT_COUNT_CODE_OATH)
	e1:SetHintTiming(0,TIMING_END_PHASE)
	e1:SetCost(c69087397.cost)
	e1:SetTarget(c69087397.target)
	e1:SetOperation(c69087397.activate)
	c:RegisterEffect(e1)
end
-- 过滤条件：手卡或自己场上表侧表示的、可以作为代价除外的鸟兽族怪兽
function c69087397.cfilter(c)
	return c:IsRace(RACE_WINDBEAST) and (c:IsFaceup() or c:IsLocation(LOCATION_HAND)) and c:IsAbleToRemoveAsCost()
end
-- 发动代价（Cost）处理：从手卡或自己场上表侧表示怪兽中将1只鸟兽族怪兽除外
function c69087397.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查手卡或自己场上是否存在至少1只满足条件的鸟兽族怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c69087397.cfilter,tp,LOCATION_HAND+LOCATION_MZONE,0,1,nil) end
	-- 提示玩家选择要除外的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 让玩家选择1只手卡或自己场上表侧表示的鸟兽族怪兽
	local g=Duel.SelectMatchingCard(tp,c69087397.cfilter,tp,LOCATION_HAND+LOCATION_MZONE,0,1,1,nil)
	-- 将选择的怪兽表侧表示除外作为发动代价
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
-- 过滤条件：卡组中可以加入手卡的「随风旅鸟」怪兽或「随风旅鸟」场地魔法卡
function c69087397.thfilter(c)
	return (c:IsSetCard(0x16d) and c:IsType(TYPE_MONSTER) or c:IsSetCard(0x16d) and c:IsType(TYPE_FIELD)) and c:IsAbleToHand()
end
-- 效果的目标处理：检查卡组中是否存在可检索的卡，并设置操作信息（检索和回复基本分）
function c69087397.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在可检索的「随风旅鸟」怪兽或场地魔法卡
	if chk==0 then return Duel.IsExistingMatchingCard(c69087397.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置当前连锁的目标玩家为自己（用于后续回复基本分）
	Duel.SetTargetPlayer(tp)
	-- 设置当前连锁的目标参数为500（用于后续回复基本分）
	Duel.SetTargetParam(500)
	-- 设置操作信息：从卡组将1张卡加入手卡
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
	-- 设置操作信息：自己回复500基本分
	Duel.SetOperationInfo(0,CATEGORY_RECOVER,nil,0,tp,500)
end
-- 效果的发动处理：从卡组将「随风旅鸟」怪兽或场地魔法加入手卡，之后回复500基本分
function c69087397.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从卡组中选择1张满足条件的「随风旅鸟」怪兽或场地魔法卡
	local g=Duel.SelectMatchingCard(tp,c69087397.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选择的卡加入手卡
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 给对方玩家确认加入手卡的卡
		Duel.ConfirmCards(1-tp,g)
		-- 中断当前效果，使后续的回复基本分处理视为不同时处理
		Duel.BreakEffect()
		-- 自己回复500基本分
		Duel.Recover(tp,500,REASON_EFFECT)
	end
end
