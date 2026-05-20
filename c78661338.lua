--幻創龍ファンタズメイ
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：对方把连接怪兽特殊召唤的场合才能发动。这张卡从手卡特殊召唤。那之后，自己抽出对方场上的连接怪兽的数量＋1张。那之后，选对方场上的连接怪兽数量的自己手卡回到卡组。
-- ②：自己场上的怪兽为对象的魔法·陷阱·怪兽的效果由对方发动时，丢弃1张手卡才能发动。那个发动无效并破坏。
function c78661338.initial_effect(c)
	-- ①：对方把连接怪兽特殊召唤的场合才能发动。这张卡从手卡特殊召唤。那之后，自己抽出对方场上的连接怪兽的数量＋1张。那之后，选对方场上的连接怪兽数量的自己手卡回到卡组。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(78661338,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_DRAW+CATEGORY_TODECK)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetRange(LOCATION_HAND)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,78661338)
	e1:SetCondition(c78661338.spcon)
	e1:SetTarget(c78661338.sptg)
	e1:SetOperation(c78661338.spop)
	c:RegisterEffect(e1)
	-- ②：自己场上的怪兽为对象的魔法·陷阱·怪兽的效果由对方发动时，丢弃1张手卡才能发动。那个发动无效并破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(78661338,0))
	e2:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_CHAINING)
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,78661339)
	e2:SetCondition(c78661338.discon)
	e2:SetCost(c78661338.discost)
	e2:SetTarget(c78661338.distg)
	e2:SetOperation(c78661338.disop)
	c:RegisterEffect(e2)
end
-- 过滤对方特殊召唤的连接怪兽
function c78661338.spfilter(c,sp)
	return c:IsSummonPlayer(sp) and c:IsType(TYPE_LINK)
end
-- 检查对方是否特殊召唤了连接怪兽
function c78661338.spcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c78661338.spfilter,1,nil,1-tp)
end
-- 效果①的发动准备与可行性检测
function c78661338.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取对方场上连接怪兽的数量
	local ct=Duel.GetMatchingGroupCount(Card.IsType,tp,0,LOCATION_MZONE,nil,TYPE_LINK)
	-- 检查自身怪兽区域是否有空位、玩家是否能抽卡（数量为对方场上连接怪兽数+1）以及手卡中的这张卡是否能特殊召唤
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.IsPlayerCanDraw(tp,ct+1)
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置特殊召唤的操作信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 效果①的处理：特殊召唤此卡，抽卡，并让手卡回到卡组
function c78661338.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 检查此卡是否仍与效果相关，并成功将此卡特殊召唤
	if c:IsRelateToEffect(e) and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)>0 then
		-- 阶段性中断效果，使后续的抽卡处理不与特殊召唤同时进行
		Duel.BreakEffect()
		-- 重新获取对方场上连接怪兽的数量
		local ct=Duel.GetMatchingGroupCount(Card.IsType,tp,0,LOCATION_MZONE,nil,TYPE_LINK)
		-- 玩家抽出对方场上连接怪兽数量+1张卡，若未能成功抽卡则结束处理
		if Duel.Draw(tp,ct+1,REASON_EFFECT)==0 then return end
		-- 洗切玩家手卡
		Duel.ShuffleHand(tp)
		-- 提示玩家选择要送回卡组的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
		-- 让玩家选择与对方场上连接怪兽数量相同的手卡
		local g=Duel.SelectMatchingCard(tp,Card.IsAbleToDeck,tp,LOCATION_HAND,0,ct,ct,nil)
		if ct>0 then
			-- 阶段性中断效果，使后续的送回卡组处理不与抽卡同时进行
			Duel.BreakEffect()
			if g:GetCount()>0 then
				-- 将选中的手卡送回卡组并洗卡
				Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
			end
		end
	end
end
-- 过滤自己场上的怪兽
function c78661338.tfilter(c,tp)
	return c:IsLocation(LOCATION_MZONE) and c:IsControler(tp)
end
-- 检查对方发动的效果是否以自己场上的怪兽为对象，且该发动可以被无效
function c78661338.discon(e,tp,eg,ep,ev,re,r,rp)
	if rp==tp or e:GetHandler():IsStatus(STATUS_BATTLE_DESTROYED) then return false end
	if not re:IsHasProperty(EFFECT_FLAG_CARD_TARGET) then return false end
	-- 获取当前连锁的对象卡片组
	local tg=Duel.GetChainInfo(ev,CHAININFO_TARGET_CARDS)
	-- 确认对象卡片组中存在自己场上的怪兽，且该发动可以被无效
	return tg and tg:IsExists(c78661338.tfilter,1,nil,tp) and Duel.IsChainNegatable(ev)
end
-- 过滤在对象卡片组中且未被战斗破坏的卡
function c78661338.cfilter(c,g)
	return g:IsContains(c) and not c:IsStatus(STATUS_BATTLE_DESTROYED)
end
-- 效果②的消耗：丢弃1张手卡
function c78661338.discost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查手卡中是否存在可以丢弃的卡
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,nil) end
	-- 丢弃1张手卡
	Duel.DiscardHand(tp,Card.IsDiscardable,1,1,REASON_COST+REASON_DISCARD)
end
-- 效果②的发动准备与可行性检测
function c78661338.distg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置使发动无效的操作信息
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	if re:GetHandler():IsDestructable() and re:GetHandler():IsRelateToEffect(re) then
		-- 设置破坏该卡的操作信息
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
	end
end
-- 效果②的处理：使发动无效并破坏
function c78661338.disop(e,tp,eg,ep,ev,re,r,rp)
	-- 尝试使该效果的发动无效，并确认该卡仍与效果相关
	if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) then
		-- 破坏该卡
		Duel.Destroy(eg,REASON_EFFECT)
	end
end
