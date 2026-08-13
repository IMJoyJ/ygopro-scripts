--青竜の忍者
-- 效果：
-- 1回合1次，从手卡丢弃1只名字带有「忍者」的怪兽和1张名字带有「忍法」的卡，选择对方场上表侧表示存在的1只怪兽才能发动。这个回合，选择的怪兽不能攻击，效果无效化。这个效果在对方回合也能发动。
function c14568951.initial_effect(c)
	-- 1回合1次，从手卡丢弃1只名字带有「忍者」的怪兽和1张名字带有「忍法」的卡，选择对方场上表侧表示存在的1只怪兽才能发动。这个回合，选择的怪兽不能攻击，效果无效化。这个效果在对方回合也能发动。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(14568951,0))  --"效果无效"
	e1:SetCategory(CATEGORY_DISABLE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCost(c14568951.cost)
	e1:SetTarget(c14568951.target)
	e1:SetOperation(c14568951.operation)
	c:RegisterEffect(e1)
end
-- 筛选条件：判断一张手牌是否为名字带有「忍者」的怪兽，并确认其可以被丢弃，用于从手牌中选取需要作为代价丢弃的忍者怪兽。
function c14568951.cfilter1(c)
	return c:IsSetCard(0x2b) and c:IsType(TYPE_MONSTER) and c:IsDiscardable()
end
-- 筛选条件：判断一张手牌是否为名字带有「忍法」的卡，并确认其可以被丢弃，用于从手牌中选取需要作为代价丢弃的忍法卡。
function c14568951.cfilter2(c)
	return c:IsSetCard(0x61) and c:IsDiscardable()
end
-- 代价检查：确认己方手牌中同时存在至少1只符合条件的「忍者」怪兽和至少1张符合条件的「忍法」卡，满足发动所需代价的支付前提。
function c14568951.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查己方手牌中是否存在至少1只可丢弃的名字带有「忍者」的怪兽，作为代价可行性的第一个条件。
	if chk==0 then return Duel.IsExistingMatchingCard(c14568951.cfilter1,tp,LOCATION_HAND,0,1,nil)
		-- 检查己方手牌中是否存在至少1张可丢弃的名字带有「忍法」的卡，与上一条件同时满足才能支付代价。
		and Duel.IsExistingMatchingCard(c14568951.cfilter2,tp,LOCATION_HAND,0,1,nil) end
	-- 给己方玩家显示“请选择要丢弃的手牌”的提示，引导玩家选择第一张要丢弃的代价卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISCARD)  --"请选择要丢弃的手牌"
	-- 让己方玩家从手牌中选择1只满足条件的「忍者」怪兽，作为本次发动要丢弃的代价之一。
	local g1=Duel.SelectMatchingCard(tp,c14568951.cfilter1,tp,LOCATION_HAND,0,1,1,nil)
	-- 再次显示“请选择要丢弃的手牌”的提示，引导玩家选择第二张要丢弃的代价卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISCARD)  --"请选择要丢弃的手牌"
	-- 让己方玩家从手牌中选择1张满足条件的「忍法」卡，作为本次发动要丢弃的代价之一。
	local g2=Duel.SelectMatchingCard(tp,c14568951.cfilter2,tp,LOCATION_HAND,0,1,1,nil)
	g1:Merge(g2)
	-- 将选中的「忍者」怪兽和「忍法」卡合并后送入墓地，作为发动效果所支付的代价；原因标记为代价丢弃（REASON_COST+REASON_DISCARD）。
	Duel.SendtoGrave(g1,REASON_COST+REASON_DISCARD)
end
-- 目标选择阶段：检查对方场上是否存在可成为对象的表侧表示怪兽；若存在，则提示玩家选择1只，并把该对象登记为本连锁的取对象目标，同时设置操作信息为无效化效果。
function c14568951.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(1-tp) and chkc:IsLocation(LOCATION_MZONE) and chkc:IsFaceup() end
	-- 发动合法性检查：确认对方场上有表侧表示且能被本效果选为对象的怪兽存在。
	if chk==0 then return Duel.IsExistingTarget(Card.IsFaceup,tp,0,LOCATION_MZONE,1,nil) end
	-- 给己方玩家显示“请选择表侧表示的卡”的提示，引导选择对象怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 从对方场上选择1只表侧表示怪兽作为本效果的对象，选中的怪兽会自动与当前发动的效果建立关联。
	local g=Duel.SelectTarget(tp,Card.IsFaceup,tp,0,LOCATION_MZONE,1,1,nil)
	-- 设置操作信息：声明本连锁将对目标（g）执行‘无效效果’的处理，并登记目标数量为1，供后续连锁对应时判断。
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,g,1,0,0)
end
-- 效果处理：若目标仍然表侧表示且与本效果有关联，则将与该目标相关的连锁无效化，并给目标附加‘效果无效’、‘效果无效化’和‘不能攻击’的持续效果（持续到回合结束、离场等重置条件触发）。
function c14568951.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取本效果发动时选择的目标怪兽（即唯一的取对象卡片）。
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) then
		-- 使与对象怪兽相关的连锁效果全部无效化；若发生变里侧事件则重置此无效效果。
		Duel.NegateRelatedChain(tc,RESET_TURN_SET)
		-- 效果无效化
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
		-- 效果无效化
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetValue(RESET_TURN_SET)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e2)
		-- 不能攻击
		local e3=Effect.CreateEffect(c)
		e3:SetType(EFFECT_TYPE_SINGLE)
		e3:SetCode(EFFECT_CANNOT_ATTACK)
		e3:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e3)
	end
end
