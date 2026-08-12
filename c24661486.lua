--コールド・エンチャンター
-- 效果：
-- 丢弃1张手卡才能发动。选择场上表侧表示存在的1只怪兽放置1个冰指示物。只要这张卡在场上表侧表示存在，这张卡的攻击力上升场上的冰指示物数量×300的数值。
function c24661486.initial_effect(c)
	-- 丢弃1张手卡才能发动。选择场上表侧表示存在的1只怪兽放置1个冰指示物。
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
c24661486.mentioned_counter={
	[0x1015]=true,
}
-- 发动代价：确认手卡存在可丢弃的卡后，丢弃1张手卡作为效果的发动代价
function c24661486.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己手卡是否存在至少1张可以丢弃的卡（自身除外），确认能否支付发动代价
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,e:GetHandler()) end
	-- 让发动玩家选择并丢弃1张手卡，作为效果的发动代价
	Duel.DiscardHand(tp,Card.IsDiscardable,1,1,REASON_COST+REASON_DISCARD)
end
-- 选择场上1只可以放置冰指示物的表侧表示怪兽作为效果对象，并设置放置指示物的操作信息
function c24661486.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsCanAddCounter(0x1015,1) end
	-- 检查双方场上是否存在至少1只能放置冰指示物且可以成为当前效果对象的表侧表示怪兽
	if chk==0 then return Duel.IsExistingTarget(Card.IsCanAddCounter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil,0x1015,1) end
	-- 向发动玩家发出选卡提示：请选择表侧表示的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 让发动玩家从双方场上选择1只能放置冰指示物的表侧表示怪兽作为本效果的对象
	local g=Duel.SelectTarget(tp,Card.IsCanAddCounter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil,0x1015,1)
	-- 设置当前连锁的操作信息为放置1个指示物（CATEGORY_COUNTER），供其他效果的发动检测使用
	Duel.SetOperationInfo(0,CATEGORY_COUNTER,nil,1,0,0)
end
-- 取得效果对象，若对象仍与本效果相关且能放置冰指示物，则在其上放置1个冰指示物
function c24661486.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 取得当前连锁处理的效果对象卡
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) and tc:IsCanAddCounter(0x1015,1) then
		tc:AddCounter(0x1015,1)
	end
end
-- 永续效果值函数：根据场上的冰指示物数量计算这张卡的攻击力上升数值
function c24661486.atkval(e,c)
	-- 返回场上冰指示物数量×300，作为这张卡的攻击力上升数值
	return Duel.GetCounter(0,1,1,0x1015)*300
end
