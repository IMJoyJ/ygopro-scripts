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
-- 过滤函数，用于筛选场上正面表示的「空牙团」怪兽（不包括拉法尔自身）
function c38916526.ctfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x114) and not c:IsCode(38916526)
end
-- 效果的发动时点处理函数，用于判断是否满足发动条件
function c38916526.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		-- 计算场上正面表示的「空牙团」怪兽种类数量
		local ct=Duel.GetMatchingGroup(c38916526.ctfilter,tp,LOCATION_MZONE,0,nil):GetClassCount(Card.GetCode)
		-- 检查卡组是否足够翻开指定数量的卡
		if Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)<ct then return false end
		-- 获取卡组最上方的指定数量的卡
		local g=Duel.GetDecktopGroup(tp,ct)
		return g:FilterCount(Card.IsAbleToHand,nil)>0
	end
	-- 设置连锁操作信息，表示将要从卡组检索1张卡加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,0,LOCATION_DECK)
end
-- 效果的处理函数，执行检索并选择加入手牌的卡
function c38916526.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 计算场上正面表示的「空牙团」怪兽种类数量
	local ct=Duel.GetMatchingGroup(c38916526.ctfilter,tp,LOCATION_MZONE,0,nil):GetClassCount(Card.GetCode)
	-- 翻开卡组最上方的指定数量的卡
	Duel.ConfirmDecktop(tp,ct)
	-- 获取卡组最上方的指定数量的卡
	local g=Duel.GetDecktopGroup(tp,ct)
	if g:GetCount()>0 then
		local tg=g:Filter(Card.IsAbleToHand,nil)
		if tg:GetCount()>0 then
			-- 提示玩家选择要加入手牌的卡
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
			local sg=tg:Select(tp,1,1,nil)
			-- 将选中的卡加入手牌
			Duel.SendtoHand(sg,nil,REASON_EFFECT)
			-- 向对方确认加入手牌的卡
			Duel.ConfirmCards(1-tp,sg)
		end
		-- 将卡组洗牌
		Duel.ShuffleDeck(tp)
	end
end
-- 效果发动条件函数，判断是否满足无效对方怪兽效果的条件
function c38916526.negcon(e,tp,eg,ep,ev,re,r,rp)
	return not e:GetHandler():IsStatus(STATUS_BATTLE_DESTROYED)
		-- 判断对方发动的是否为怪兽效果且可以被无效
		and ep~=tp and re:IsActiveType(TYPE_MONSTER) and Duel.IsChainNegatable(ev)
end
-- 过滤函数，用于筛选可以作为代价丢弃的「空牙团」卡
function c38916526.cfilter(c,e,tp)
	if c:IsLocation(LOCATION_HAND) then
		return c:IsSetCard(0x114) and c:IsDiscardable()
	else
		return e:GetHandler():IsSetCard(0x114) and c:IsAbleToRemoveAsCost() and c:IsHasEffect(53557529,tp)
	end
end
-- 效果的发动时点处理函数，用于支付代价
function c38916526.negcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否有满足条件的「空牙团」卡可以作为代价丢弃
	if chk==0 then return Duel.IsExistingMatchingCard(c38916526.cfilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 提示玩家选择要丢弃的手牌
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISCARD)  --"请选择要丢弃的手牌"
	-- 选择满足条件的「空牙团」卡作为代价丢弃
	local g=Duel.SelectMatchingCard(tp,c38916526.cfilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,1,nil,e,tp)
	local tc=g:GetFirst()
	local te=tc:IsHasEffect(53557529,tp)
	if te then
		te:UseCountLimit(tp)
		-- 将选中的卡从游戏中除外（替换效果）
		Duel.Remove(tc,POS_FACEUP,REASON_EFFECT+REASON_REPLACE)
	else
		-- 将选中的卡送去墓地（普通丢弃）
		Duel.SendtoGrave(tc,REASON_COST+REASON_DISCARD)
	end
end
-- 效果的发动时点处理函数，用于设置连锁操作信息
function c38916526.negtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置连锁操作信息，表示将要使对方发动无效
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
end
-- 效果的处理函数，执行使对方发动无效的操作
function c38916526.negop(e,tp,eg,ep,ev,re,r,rp)
	-- 使对方的发动无效
	Duel.NegateActivation(ev)
end
