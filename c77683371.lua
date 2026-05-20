--ディメンション・コンジュラー
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡召唤·特殊召唤成功的场合才能发动。从自己的卡组·墓地选1张「次元魔法」加入手卡。
-- ②：这张卡从怪兽区域送去墓地的场合才能发动。自己从卡组抽出自己场上的魔法师族怪兽的数量。那之后，选抽出数量的手卡用喜欢的顺序回到卡组上面。
function c77683371.initial_effect(c)
	-- ①：这张卡召唤·特殊召唤成功的场合才能发动。从自己的卡组·墓地选1张「次元魔法」加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(77683371,0))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,77683371)
	e1:SetTarget(c77683371.thtg)
	e1:SetOperation(c77683371.thop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
	-- ②：这张卡从怪兽区域送去墓地的场合才能发动。自己从卡组抽出自己场上的魔法师族怪兽的数量。那之后，选抽出数量的手卡用喜欢的顺序回到卡组上面。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(77683371,1))
	e3:SetCategory(CATEGORY_DRAW+CATEGORY_TODECK)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_PLAYER_TARGET)
	e3:SetCode(EVENT_TO_GRAVE)
	e3:SetCountLimit(1,77683372)
	e3:SetCondition(c77683371.drcon)
	e3:SetTarget(c77683371.drtg)
	e3:SetOperation(c77683371.drop)
	c:RegisterEffect(e3)
end
-- 过滤卡组或墓地中卡名为「次元魔法」且可以加入手牌的卡
function c77683371.thfilter(c)
	return c:IsCode(28553439) and c:IsAbleToHand()
end
-- ①号效果的发动准备（检查卡组或墓地是否存在「次元魔法」并设置操作信息）
function c77683371.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组或墓地是否存在至少1张可以加入手牌的「次元魔法」
	if chk==0 then return Duel.IsExistingMatchingCard(c77683371.thfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil) end
	-- 设置连锁的操作信息为：从卡组或墓地将1张卡加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK+LOCATION_GRAVE)
end
-- ①号效果的实际处理（从卡组或墓地选择1张「次元魔法」加入手牌并给对方确认）
function c77683371.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从卡组或墓地选择1张满足条件的「次元魔法」（受王家长眠之谷影响）
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c77683371.thfilter),tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选择的卡加入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 给对方玩家确认加入手牌的卡
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 检查这张卡是否是从怪兽区域送去墓地
function c77683371.drcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousLocation(LOCATION_MZONE)
end
-- 过滤场上表侧表示的魔法师族怪兽
function c77683371.drfilter(c)
	return c:IsFaceup() and c:IsRace(RACE_SPELLCASTER)
end
-- ②号效果的发动准备（计算场上魔法师族怪兽数量，检查是否能抽卡，并设置目标玩家、参数及操作信息）
function c77683371.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取自己场上表侧表示的魔法师族怪兽的数量
	local ct=Duel.GetMatchingGroupCount(c77683371.drfilter,tp,LOCATION_MZONE,0,nil)
	-- 检查自己场上是否存在魔法师族怪兽，且玩家是否可以进行对应数量的抽卡
	if chk==0 then return ct>0 and Duel.IsPlayerCanDraw(tp,ct) end
	-- 设置当前连锁的目标玩家为自己
	Duel.SetTargetPlayer(tp)
	-- 设置当前连锁的目标参数为抽卡数量（魔法师族怪兽数量）
	Duel.SetTargetParam(ct)
	-- 设置连锁的操作信息为：玩家抽对应数量的卡
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,ct)
	-- 设置连锁的操作信息为：玩家将对应数量的卡送回卡组
	Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,0,tp,ct)
end
-- ②号效果的实际处理（抽卡，然后将相同数量的手牌以喜欢的顺序放回卡组最上方）
function c77683371.drop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的目标玩家
	local p=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER)
	-- 重新计算当前自己场上表侧表示的魔法师族怪兽的数量
	local ct=Duel.GetMatchingGroupCount(c77683371.drfilter,p,LOCATION_MZONE,0,nil)
	-- 如果场上存在魔法师族怪兽，则让目标玩家抽出对应数量的卡，并检查是否成功抽出了相同数量的卡
	if ct>0 and Duel.Draw(p,ct,REASON_EFFECT)==ct then
		-- 获取玩家手牌中可以送回卡组的卡片组
		local tg=Duel.GetMatchingGroup(Card.IsAbleToDeck,p,LOCATION_HAND,0,nil)
		if tg:GetCount()==0 then return end
		-- 洗切玩家的手牌
		Duel.ShuffleHand(p)
		-- 中断当前效果，使后续的放回卡组处理与抽卡不视为同时处理
		Duel.BreakEffect()
		-- 提示玩家选择要返回卡组的卡
		Duel.Hint(HINT_SELECTMSG,p,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
		local sg=tg:Select(p,ct,ct,nil)
		-- 将选择的卡片以玩家喜欢的顺序放回卡组最上方
		aux.PlaceCardsOnDeckTop(p,sg)
	end
end
