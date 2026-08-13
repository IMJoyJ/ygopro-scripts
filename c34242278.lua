--聖騎士の盾持ち
-- 效果：
-- 这个卡名的①②的效果1回合只能有1次使用其中任意1个。
-- ①：这张卡召唤·特殊召唤成功的场合，从自己墓地把1只光属性怪兽除外才能发动。自己从卡组抽1张。
-- ②：把手卡·场上的这张卡除外才能发动。从卡组把1只6星以下的兽族·风属性怪兽加入手卡。
function c34242278.initial_effect(c)
	-- ①：这张卡召唤·特殊召唤成功的场合，从自己墓地把1只光属性怪兽除外才能发动。自己从卡组抽1张。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(34242278,0))
	e1:SetCategory(CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetCountLimit(1,34242278)
	e1:SetCost(c34242278.drcost)
	e1:SetTarget(c34242278.drtg)
	e1:SetOperation(c34242278.drop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
	-- ②：把手卡·场上的这张卡除外才能发动。从卡组把1只6星以下的兽族·风属性怪兽加入手卡。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(34242278,1))
	e3:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_MZONE+LOCATION_HAND)
	e3:SetCountLimit(1,34242278)
	-- 设置②效果的发动代价：把手卡·场上的这张卡自身除外（通过aux.bfgcost实现）。
	e3:SetCost(aux.bfgcost)
	e3:SetTarget(c34242278.thtg)
	e3:SetOperation(c34242278.thop)
	c:RegisterEffect(e3)
end
-- 定义过滤器：筛选出光属性且可以作为代价除外的怪兽卡（用于从自己墓地选择）。
function c34242278.cfilter(c)
	return c:IsAttribute(ATTRIBUTE_LIGHT) and c:IsAbleToRemoveAsCost()
end
-- 定义①效果的发动代价函数：检查墓地是否存在光属性怪兽可作为代价，存在则让玩家选择1张并除外。
function c34242278.drcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 代价合法性检查（chk==0）：确认自己墓地存在至少1只满足条件的光属性怪兽可作为代价。
	if chk==0 then return Duel.IsExistingMatchingCard(c34242278.cfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 向玩家发出选择提示，提示信息为“请选择要除外的卡”。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 让玩家从自己墓地的光属性怪兽中选择1张（满足cfilter）作为发动代价。
	local g=Duel.SelectMatchingCard(tp,c34242278.cfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 将选中的卡片以表侧表示除外，作为发动代价。
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
-- 定义①效果的发动目标检测与操作信息登记：检查自己能否抽卡，并设置抽卡玩家为自己、抽卡数量为1，登记抽卡操作信息。
function c34242278.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动合法性检查（chk==0）：确认自己可以抽1张卡（未受不能抽卡限制）。
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1) end
	-- 将当前连锁的对象玩家设为自己，表示由自己抽卡。
	Duel.SetTargetPlayer(tp)
	-- 将当前连锁的对象参数设为1，表示抽卡数量为1。
	Duel.SetTargetParam(1)
	-- 登记操作信息：本次连锁为抽卡效果，抽卡玩家为自己，抽卡数量为1。
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
-- 定义①效果的处理函数：根据连锁中登记的抽卡玩家和数量执行抽卡。
function c34242278.drop(e,tp,eg,ep,ev,re,r,rp)
	-- 从当前连锁信息中取出对象玩家p（抽卡玩家）和对象参数d（抽卡数量）。
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 让玩家p以效果原因抽d张卡。
	Duel.Draw(p,d,REASON_EFFECT)
end
-- 定义过滤器：筛选出等级6以下、风属性、兽族且可以加入手卡的怪兽卡，用于②效果的卡组检索。
function c34242278.thfilter(c)
	return c:IsLevelBelow(6) and c:IsAttribute(ATTRIBUTE_WIND) and c:IsRace(RACE_BEAST) and c:IsAbleToHand()
end
-- 定义②效果的发动目标检测与操作信息登记：确认卡组存在符合条件的怪兽，并登记从卡组将1张加入手卡的操作信息。
function c34242278.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动合法性检查（chk==0）：确认卡组中存在至少1只满足条件的6星以下风属性兽族怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(c34242278.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 登记操作信息：本次连锁为回手牌/检索效果，处理时从自己卡组选择1张卡加入手卡。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 定义②效果的处理函数：提示玩家选择符合条件的怪兽加入手卡，若选择则加入持有者手卡并让对方确认。
function c34242278.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 向玩家发出选择提示，提示内容为“请选择要加入手牌的卡”。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从卡组中选择1只满足条件的6星以下风属性兽族怪兽（thfilter）加入手卡。
	local g=Duel.SelectMatchingCard(tp,c34242278.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡片加入其持有者的手卡（nil表示送回持有者手卡），原因是效果。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 让对方玩家确认这些加入手卡的卡片。
		Duel.ConfirmCards(1-tp,g)
	end
end
