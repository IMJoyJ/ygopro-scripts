--ネイビィロイド
-- 效果：
-- 对方以自己场上的魔法·陷阱卡为对象把持有使场上的魔法·陷阱卡破坏效果的卡发动时，可以丢弃1张手卡，那张卡的发动和效果无效并破坏。
function c46848859.initial_effect(c)
	-- 对方以自己场上的魔法·陷阱卡为对象把持有使场上的魔法·陷阱卡破坏效果的卡发动时，可以丢弃1张手卡，那张卡的发动和效果无效并破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(46848859,0))  --"无效并破坏"
	e1:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_CHAINING)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(c46848859.condition)
	e1:SetCost(c46848859.cost)
	e1:SetTarget(c46848859.target)
	e1:SetOperation(c46848859.operation)
	c:RegisterEffect(e1)
end
-- 筛选出场上存在的魔法·陷阱卡，用于统计对方效果可能破坏的魔陷数量。
function c46848859.cfilter(c)
	return c:IsOnField() and c:IsType(TYPE_SPELL+TYPE_TRAP)
end
-- 筛选出对象卡中由我方控制且在场上的魔法·陷阱卡，用于判断对方效果是否以我方魔陷为对象。
function c46848859.tgfilter(c,tp)
	return c:IsOnField() and c:IsControler(tp) and c:IsType(TYPE_SPELL+TYPE_TRAP)
end
-- 发动条件的前置判断：本卡未被战斗破坏且当前连锁可被无效；对方连锁效果必须为取对象效果，且其对象中存在我方场上的魔法·陷阱卡；若对方效果带有无效分类且其前一连锁为魔法/陷阱卡的发动，则本效果不能发动。
function c46848859.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 若本卡已处于战斗破坏确定状态，或当前连锁不能被无效，则不满足发动条件。
	if e:GetHandler():IsStatus(STATUS_BATTLE_DESTROYED) or not Duel.IsChainNegatable(ev) then return false end
	if not re:IsHasProperty(EFFECT_FLAG_CARD_TARGET) then return false end
	-- 取得对方发动的效果在连锁中所选择的取对象卡片组。
	local g=Duel.GetChainInfo(ev,CHAININFO_TARGET_CARDS)
	if not g or not g:IsExists(c46848859.tgfilter,1,nil,tp) then return false end
	if re:IsHasCategory(CATEGORY_NEGATE)
		-- 若对方效果具有无效分类，且其前一连锁是魔法/陷阱卡的发动，则本效果不能发动，避免对应魔陷的发动无效效果。
		and Duel.GetChainInfo(ev-1,CHAININFO_TRIGGERING_EFFECT):IsHasType(EFFECT_TYPE_ACTIVATE) then return false end
	-- 查询对方效果在操作信息中是否含有破坏分类，并取得预计破坏数量与取对象目标，用于判断其是否包含破坏场上魔陷的效果。
	local ex,tg,tc=Duel.GetOperationInfo(ev,CATEGORY_DESTROY)
	return ex and tg~=nil and tc+tg:FilterCount(c46848859.cfilter,nil)-tg:GetCount()>0
end
-- 发动代价：丢弃1张手牌。
function c46848859.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查手牌中是否有至少1张可以丢弃的卡。
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,nil) end
	-- 实际丢弃1张手牌，丢弃原因记为代价并视为丢弃。
	Duel.DiscardHand(tp,Card.IsDiscardable,1,1,REASON_COST+REASON_DISCARD)
end
-- 设定效果处理时的操作信息：将无效对象设为对方发动的卡；若该卡可被破坏且仍与效果关联，则同时设定破坏该卡。
function c46848859.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设定本次效果处理包含使发动无效的分类，对象为当前连锁的对方发动卡。
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	if re:GetHandler():IsDestructable() and re:GetHandler():IsRelateToEffect(re) then
		-- 设定本次效果处理包含破坏分类，对象为当前连锁的对方发动卡。
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
	end
end
-- 效果处理：若成功无效对方卡的发动，则将那张卡破坏。
function c46848859.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 仅在无效发动成功，且对方发动的那张卡仍与该效果处于关联状态时，才执行破坏。
	if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) then
		-- 将对方发动的卡以效果破坏送入墓地。
		Duel.Destroy(eg,REASON_EFFECT)
	end
end
