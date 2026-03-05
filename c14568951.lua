--青竜の忍者
-- 效果：
-- 1回合1次，从手卡丢弃1只名字带有「忍者」的怪兽和1张名字带有「忍法」的卡，选择对方场上表侧表示存在的1只怪兽才能发动。这个回合，选择的怪兽不能攻击，效果无效化。这个效果在对方回合也能发动。
function c14568951.initial_effect(c)
	-- 创建一个诱发即时效果，效果描述为“效果无效”，分类为无效化，具有取对象属性，类型为二速，时点为自由时点，生效区域为主怪兽区，限制每回合发动一次，需要支付丢弃1只名字带有「忍者」的怪兽和1张名字带有「忍法」的卡作为代价，选择对方场上表侧表示存在的1只怪兽作为对象，发动时处理效果
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
-- 定义用于过滤手卡中名字带有「忍者」的怪兽的条件函数
function c14568951.cfilter1(c)
	return c:IsSetCard(0x2b) and c:IsType(TYPE_MONSTER) and c:IsDiscardable()
end
-- 定义用于过滤手卡中名字带有「忍法」的卡的条件函数
function c14568951.cfilter2(c)
	return c:IsSetCard(0x61) and c:IsDiscardable()
end
-- 定义效果发动时的支付代价函数，检查是否满足丢弃条件
function c14568951.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查在手卡中是否存在至少1只名字带有「忍者」的怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c14568951.cfilter1,tp,LOCATION_HAND,0,1,nil)
		-- 检查在手卡中是否存在至少1张名字带有「忍法」的卡
		and Duel.IsExistingMatchingCard(c14568951.cfilter2,tp,LOCATION_HAND,0,1,nil) end
	-- 向玩家提示选择要丢弃的手牌
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISCARD)
	-- 选择满足条件的1只名字带有「忍者」的怪兽
	local g1=Duel.SelectMatchingCard(tp,c14568951.cfilter1,tp,LOCATION_HAND,0,1,1,nil)
	-- 向玩家提示选择要丢弃的手牌
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISCARD)
	-- 选择满足条件的1张名字带有「忍法」的卡
	local g2=Duel.SelectMatchingCard(tp,c14568951.cfilter2,tp,LOCATION_HAND,0,1,1,nil)
	g1:Merge(g2)
	-- 将选择的怪兽和卡送去墓地作为发动代价
	Duel.SendtoGrave(g1,REASON_COST+REASON_DISCARD)
end
-- 定义效果发动时的选择对象函数
function c14568951.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(1-tp) and chkc:IsLocation(LOCATION_MZONE) and chkc:IsFaceup() end
	-- 检查对方场上是否存在至少1只表侧表示的怪兽
	if chk==0 then return Duel.IsExistingTarget(Card.IsFaceup,tp,0,LOCATION_MZONE,1,nil) end
	-- 向玩家提示选择表侧表示的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	-- 选择对方场上表侧表示存在的1只怪兽作为对象
	local g=Duel.SelectTarget(tp,Card.IsFaceup,tp,0,LOCATION_MZONE,1,1,nil)
	-- 设置当前处理的连锁的操作信息，将选择的怪兽作为无效化对象
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,g,1,0,0)
end
-- 定义效果发动时的处理函数
function c14568951.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前连锁选择的对象怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) then
		-- 使与该对象怪兽相关的连锁无效化
		Duel.NegateRelatedChain(tc,RESET_TURN_SET)
		-- 给对象怪兽添加效果无效化效果，使其在结束阶段重置
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
		-- 给对象怪兽添加效果无效化效果，使其在结束阶段重置
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetValue(RESET_TURN_SET)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e2)
		-- 给对象怪兽添加不能攻击效果，使其在结束阶段重置
		local e3=Effect.CreateEffect(c)
		e3:SetType(EFFECT_TYPE_SINGLE)
		e3:SetCode(EFFECT_CANNOT_ATTACK)
		e3:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e3)
	end
end
