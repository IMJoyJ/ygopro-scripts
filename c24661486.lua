--コールド・エンチャンター
-- 效果：
-- 丢弃1张手卡才能发动。选择场上表侧表示存在的1只怪兽放置1个冰指示物。只要这张卡在场上表侧表示存在，这张卡的攻击力上升场上的冰指示物数量×300的数值。
function c24661486.initial_effect(c)
	-- 选择场上表侧表示存在的1只怪兽放置1个冰指示物。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(24661486,0))  --"放置指示物"
	e1:SetCategory(CATEGORY_COUNTER)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCost(c24661486.cost)
	e1:SetTarget(c24661486.target)
	e1:SetOperation(c24661486.operation)
	c:RegisterEffect(e1)
	-- 只要这张卡在场上表侧表示存在，这张卡的攻击力上升场上的冰指示物数量×300的数值。
	local e2=Effect.CreateEffect(c)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetRange(LOCATION_MZONE)
	e2:SetValue(c24661486.atkval)
	c:RegisterEffect(e2)
end
-- 检查玩家手牌是否存在可丢弃的卡片，若存在则丢弃1张手卡作为效果的发动代价。
function c24661486.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家手牌是否存在可丢弃的卡片。
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,e:GetHandler()) end
	-- 丢弃1张手卡作为效果的发动代价。
	Duel.DiscardHand(tp,Card.IsDiscardable,1,1,REASON_COST+REASON_DISCARD)
end
-- 选择场上表侧表示存在的1只怪兽作为效果的对象。
function c24661486.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsCanAddCounter(0x1015,1) end
	-- 检查场上是否存在可放置冰指示物的怪兽。
	if chk==0 then return Duel.IsExistingTarget(Card.IsCanAddCounter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil,0x1015,1) end
	-- 提示玩家选择表侧表示的怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择场上表侧表示存在的1只怪兽作为效果的对象。
	local g=Duel.SelectTarget(tp,Card.IsCanAddCounter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil,0x1015,1)
	-- 设置效果处理信息，表示将要放置1个冰指示物。
	Duel.SetOperationInfo(0,CATEGORY_COUNTER,nil,1,0,0)
end
-- 将选中的目标怪兽放置1个冰指示物。
function c24661486.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁效果所选择的目标怪兽。
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) and tc:IsCanAddCounter(0x1015,1) then
		tc:AddCounter(0x1015,1)
	end
end
-- 计算并返回冰指示物数量乘以300作为攻击力提升值。
function c24661486.atkval(e,c)
	-- 获取场上冰指示物的总数量并乘以300作为攻击力提升值。
	return Duel.GetCounter(0,1,1,0x1015)*300
end
