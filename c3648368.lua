--A・O・J リサーチャー
-- 效果：
-- 丢弃1张手卡发动。对方场上里侧守备表示存在的1只怪兽变成表侧攻击表示。这个时候，反转效果怪兽的效果不发动。这个效果1回合只能使用1次。
function c3648368.initial_effect(c)
	-- 创建效果，设置效果描述为“改变表示形式”，分类为改变表示形式，类型为起动效果，取对象，生效位置为主怪兽区，限制每回合只能使用1次，设置费用函数为cost，目标函数为target，处理函数为operation
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
-- 费用函数，检查是否可以丢弃1张手卡作为费用
function c3648368.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家手牌中是否存在至少1张可丢弃的卡
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,nil) end
	-- 执行丢弃1张手卡的操作，丢弃原因包括费用和丢弃
	Duel.DiscardHand(tp,Card.IsDiscardable,1,1,REASON_COST+REASON_DISCARD,nil)
end
-- 过滤函数，判断目标怪兽是否为里侧表示且为守备表示
function c3648368.filter(c)
	return c:IsFacedown() and c:IsDefensePos()
end
-- 目标选择函数，检查对方场上是否存在里侧守备表示的怪兽，选择目标怪兽并设置操作信息
function c3648368.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and c3648368.filter(chkc) end
	-- 检查对方场上是否存在至少1只里侧守备表示的怪兽
	if chk==0 then return Duel.IsExistingTarget(c3648368.filter,tp,0,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择对方场上的里侧守备表示怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEDOWNDEFENSE)  --"请选择里侧守备表示的怪兽"
	-- 选择对方场上1只里侧守备表示的怪兽作为目标
	local g=Duel.SelectTarget(tp,c3648368.filter,tp,0,LOCATION_MZONE,1,1,nil)
	-- 设置操作信息，表示将要改变目标怪兽的表示形式
	Duel.SetOperationInfo(0,CATEGORY_POSITION,g,1,0,0)
end
-- 效果处理函数，获取目标怪兽并将其变为表侧攻击表示，且不触发反转效果
function c3648368.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and c3648368.filter(tc) then
		-- 将目标怪兽变为表侧攻击表示，且不触发反转效果
		Duel.ChangePosition(tc,0,0,0,POS_FACEUP_ATTACK,true)
	end
end
