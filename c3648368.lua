--A・O・J リサーチャー
-- 效果：
-- 丢弃1张手卡发动。对方场上里侧守备表示存在的1只怪兽变成表侧攻击表示。这个时候，反转效果怪兽的效果不发动。这个效果1回合只能使用1次。
function c3648368.initial_effect(c)
	-- 丢弃1张手卡发动。对方场上里侧守备表示存在的1只怪兽变成表侧攻击表示。这个时候，反转效果怪兽的效果不发动。这个效果1回合只能使用1次。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(3648368,0))  --"改变表示形式"
	e1:SetCategory(CATEGORY_POSITION)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCost(c3648368.cost)
	e1:SetTarget(c3648368.target)
	e1:SetOperation(c3648368.operation)
	c:RegisterEffect(e1)
end
-- 定义发动代价函数：效果发动前需要丢弃1张手卡，先检查手牌是否有可丢弃的卡，然后实际丢弃1张手卡作为代价。
function c3648368.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 代价检测阶段：确认自己手牌中存在至少1张可以丢弃的手卡，否则无法发动。
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,nil) end
	-- 实际支付代价：从手牌选择1张可以丢弃的手卡丢弃，丢弃原因同时标记为“代价”和“丢弃”。
	Duel.DiscardHand(tp,Card.IsDiscardable,1,1,REASON_COST+REASON_DISCARD,nil)
end
-- 定义对象筛选条件：选择对方场上里侧表示且守备表示的怪兽。
function c3648368.filter(c)
	return c:IsFacedown() and c:IsDefensePos()
end
-- 定义效果发动时的目标选择：检查并选择对方场上1只里侧守备表示怪兽作为效果对象，并设置改变表示形式的操作信息。
function c3648368.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and c3648368.filter(chkc) end
	-- 目标检测阶段：确认对方场上存在至少1只满足条件且可成为对象的里侧守备表示怪兽。
	if chk==0 then return Duel.IsExistingTarget(c3648368.filter,tp,0,LOCATION_MZONE,1,nil) end
	-- 向玩家显示“请选择里侧守备表示的怪兽”的选择提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEDOWNDEFENSE)  --"请选择里侧守备表示的怪兽"
	-- 让玩家选择对方场上1只里侧守备表示怪兽，并将其登记为这个效果的对象。
	local g=Duel.SelectTarget(tp,c3648368.filter,tp,0,LOCATION_MZONE,1,1,nil)
	-- 设置操作信息：声明本连锁将处理“改变表示形式”，对象为已选择的那1只怪兽。
	Duel.SetOperationInfo(0,CATEGORY_POSITION,g,1,0,0)
end
-- 定义效果处理函数：效果处理时取得对象，若对象仍与效果相关且仍为里侧守备表示，则将其变为表侧攻击表示，且不触发反转效果。
function c3648368.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 取得这个效果发动时所选择的对象卡。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and c3648368.filter(tc) then
		-- 将对象怪兽从里侧守备表示变为表侧攻击表示，并指定不触发反转效果怪兽的反转效果。
		Duel.ChangePosition(tc,0,0,0,POS_FACEUP_ATTACK,true)
	end
end
