--氷結界の風水師
-- 效果：
-- ①：只在这张卡表侧表示存在才有1次，丢弃1张手卡，宣言1个属性才能发动。宣言的属性的怪兽不能选择表侧表示的这张卡作为攻击对象。
function c56704140.initial_effect(c)
	-- ①：只在这张卡表侧表示存在才有1次，丢弃1张手卡，宣言1个属性才能发动。宣言的属性的怪兽不能选择表侧表示的这张卡作为攻击对象。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(56704140,0))  --"不能成为攻击对象"
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetProperty(EFFECT_FLAG_NO_TURN_RESET)
	e1:SetCountLimit(1)
	e1:SetCost(c56704140.cost)
	e1:SetTarget(c56704140.target)
	e1:SetOperation(c56704140.operation)
	c:RegisterEffect(e1)
end
-- 过滤发动代价的卡片（手牌中可丢弃的卡，或墓地中可适用代替效果除外的「冰结界」卡片）
function c56704140.costfilter(c,e,tp)
	if c:IsLocation(LOCATION_HAND) then
		return c:IsDiscardable()
	else
		return e:GetHandler():IsSetCard(0x2f) and c:IsAbleToRemove() and c:IsHasEffect(18319762,tp)
	end
end
-- 执行发动代价的处理（丢弃1张手牌，或适用墓地「冰结界」怪兽的代替效果将其除外）
function c56704140.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否存在可用于支付发动代价的卡片
	if chk==0 then return Duel.IsExistingMatchingCard(c56704140.costfilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 提示玩家选择要丢弃的手牌
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISCARD)  --"请选择要丢弃的手牌"
	-- 选择1张用于支付代价的手牌（或墓地中可代替除外的卡片）
	local g=Duel.SelectMatchingCard(tp,c56704140.costfilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,1,nil,e,tp)
	local tc=g:GetFirst()
	local te=tc:IsHasEffect(18319762,tp)
	if te then
		te:UseCountLimit(tp)
		-- 将墓地中作为代替的卡片表侧表示除外
		Duel.Remove(tc,POS_FACEUP,REASON_EFFECT+REASON_REPLACE)
	else
		-- 将作为代价的手牌送去墓地（丢弃）
		Duel.SendtoGrave(tc,REASON_COST+REASON_DISCARD)
	end
end
-- 效果的发动准备，让玩家宣言1个属性并记录
function c56704140.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 提示玩家选择要宣言的属性
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATTRIBUTE)  --"请选择要宣言的属性"
	-- 让玩家从所有属性中宣言1个属性
	local aat=Duel.AnnounceAttribute(tp,1,ATTRIBUTE_ALL)
	e:SetLabel(aat)
end
-- 效果处理，若自身表侧表示存在，则为自身添加不能成为宣言属性怪兽攻击对象的效果
function c56704140.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsFacedown() or not c:IsRelateToEffect(e) then return end
	-- 宣言的属性的怪兽不能选择表侧表示的这张卡作为攻击对象。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetCode(EFFECT_CANNOT_BE_BATTLE_TARGET)
	e1:SetLabel(e:GetLabel())
	e1:SetValue(c56704140.tgval)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD)
	c:RegisterEffect(e1)
end
-- 判断攻击怪兽是否为宣言的属性且未免疫该效果
function c56704140.tgval(e,c)
	return c:IsAttribute(e:GetLabel()) and not c:IsImmuneToEffect(e)
end
