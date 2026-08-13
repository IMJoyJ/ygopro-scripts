--空牙団の英雄 ラファール
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡特殊召唤的场合才能发动。把「空牙团的英雄 拉法尔」以外的自己场上的「空牙团」怪兽种类数量的卡从自己卡组上面翻开，从那之中选1张加入手卡，剩余回到卡组。
-- ②：对方把怪兽的效果发动时，从手卡丢弃1张「空牙团」卡才能发动。那个发动无效。
function c38916526.initial_effect(c)
	-- ①：这张卡特殊召唤的场合才能发动。把「空牙团的英雄 拉法尔」以外的自己场上的「空牙团」怪兽种类数量的卡从自己卡组上面翻开，从那之中选1张加入手卡，剩余回到卡组。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(38916526,0))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCountLimit(1,38916526)
	e1:SetTarget(c38916526.thtg)
	e1:SetOperation(c38916526.thop)
	c:RegisterEffect(e1)
	-- ②：对方把怪兽的效果发动时，从手卡丢弃1张「空牙团」卡才能发动。那个发动无效。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(38916526,1))
	e2:SetCategory(CATEGORY_NEGATE)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e2:SetCode(EVENT_CHAINING)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,38916527)
	e2:SetCondition(c38916526.negcon)
	e2:SetCost(c38916526.negcost)
	e2:SetTarget(c38916526.negtg)
	e2:SetOperation(c38916526.negop)
	c:RegisterEffect(e2)
end
-- 筛选自己场上表侧表示、属于「空牙团」且不是本卡（空牙团的英雄 拉法尔）的怪兽，用于计算种类数量。
function c38916526.ctfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x114) and not c:IsCode(38916526)
end
-- ①效果发动时的条件/对象判定：计算符合条件的「空牙团」怪兽种类数ct，确认卡组数量足够且翻开后至少有1张能加入手卡，满足则返回true并设定从卡组检索1张卡的效果信息。
function c38916526.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		-- 取得自己场上符合条件的「空牙团」怪兽的不同卡名数量，作为要翻开的卡组张数。
		local ct=Duel.GetMatchingGroup(c38916526.ctfilter,tp,LOCATION_MZONE,0,nil):GetClassCount(Card.GetCode)
		-- 若卡组剩余张数不足ct，则不能发动，返回false。
		if Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)<ct then return false end
		-- 获取卡组最上方ct张卡作为将要翻开的卡组。
		local g=Duel.GetDecktopGroup(tp,ct)
		return g:FilterCount(Card.IsAbleToHand,nil)>0
	end
	-- 设置操作信息：本次效果包含将1张卡从卡组加入手卡（CATEGORY_TOHAND），供连锁判定等使用。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,0,LOCATION_DECK)
end
-- ①效果处理：重新计算种类数ct，确认并翻开卡组顶部ct张，从中选1张加入手牌，其余洗回卡组。
function c38916526.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 效果处理时重新取得当前符合条件的「空牙团」怪兽种类数，按最新数量翻卡。
	local ct=Duel.GetMatchingGroup(c38916526.ctfilter,tp,LOCATION_MZONE,0,nil):GetClassCount(Card.GetCode)
	-- 向双方玩家公开（确认）卡组最上方ct张卡，即翻开。
	Duel.ConfirmDecktop(tp,ct)
	-- 取得已公开的卡组上方ct张卡作为选择对象。
	local g=Duel.GetDecktopGroup(tp,ct)
	if g:GetCount()>0 then
		local tg=g:Filter(Card.IsAbleToHand,nil)
		if tg:GetCount()>0 then
			-- 显示选择提示，让发动者选择要加入手卡的卡。
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
			local sg=tg:Select(tp,1,1,nil)
			-- 将选择的卡加入其持有者手牌，原因为效果。
			Duel.SendtoHand(sg,nil,REASON_EFFECT)
			-- 向对方玩家展示被加入手牌的那张卡。
			Duel.ConfirmCards(1-tp,sg)
		end
		-- 将剩余翻开的卡放回卡组并洗切。
		Duel.ShuffleDeck(tp)
	end
end
-- ②效果发动条件：本卡未被战斗破坏确定、对方发动怪兽效果、且该连锁可以被无效。
function c38916526.negcon(e,tp,eg,ep,ev,re,r,rp)
	return not e:GetHandler():IsStatus(STATUS_BATTLE_DESTROYED)
		-- 判定效果发动者为对方、发动的是怪兽效果、且连锁可被无效，三者同时满足。
		and ep~=tp and re:IsActiveType(TYPE_MONSTER) and Duel.IsChainNegatable(ev)
end
-- 用于选择丢弃代价的过滤器：手牌中的卡需为「空牙团」且可丢弃；墓地中的卡需本卡为「空牙团」且该卡可被除外作为代替代价（对应特殊卡片的替代cost）。
function c38916526.cfilter(c,e,tp)
	if c:IsLocation(LOCATION_HAND) then
		return c:IsSetCard(0x114) and c:IsDiscardable()
	else
		return e:GetHandler():IsSetCard(0x114) and c:IsAbleToRemoveAsCost() and c:IsHasEffect(53557529,tp)
	end
end
-- ②效果cost：从手牌或墓地中选择1张满足条件的「空牙团」卡作为代价，手牌卡正常丢弃，若有特殊代替效果则除外。
function c38916526.negcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- cost检查：确认存在至少1张符合条件的卡（手牌/墓地），否则不能发动。
	if chk==0 then return Duel.IsExistingMatchingCard(c38916526.cfilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 显示选择提示，让发动者选择要丢弃的手牌（或代替卡）。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISCARD)  --"请选择要丢弃的手牌"
	-- 从手牌/墓地选择1张符合条件的卡作为本次发动的cost。
	local g=Duel.SelectMatchingCard(tp,c38916526.cfilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,1,nil,e,tp)
	local tc=g:GetFirst()
	local te=tc:IsHasEffect(53557529,tp)
	if te then
		te:UseCountLimit(tp)
		-- 若选择的卡带有特殊代替效果（卡号53557529），则将其除外作为cost，而不是丢弃。
		Duel.Remove(tc,POS_FACEUP,REASON_EFFECT+REASON_REPLACE)
	else
		-- 否则将选择的卡从手牌丢弃到墓地，作为cost。
		Duel.SendtoGrave(tc,REASON_COST+REASON_DISCARD)
	end
end
-- ②效果的目标判定：不取对象，只需返回true，并设定无效对方发动的操作信息。
function c38916526.negtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置操作信息：本效果将无效连锁中的那个怪兽效果（eg为对方发动的效果）。
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
end
-- ②效果处理：执行无效发动的操作。
function c38916526.negop(e,tp,eg,ep,ev,re,r,rp)
	-- 将当前连锁编号ev对应的那个发动无效。
	Duel.NegateActivation(ev)
end
