--リトル・フェアリー
-- 效果：
-- 自己的主要阶段时把1张手卡送去墓地才能发动。这张卡的等级上升1星。这个效果1回合可以使用最多2次。
function c45939611.initial_effect(c)
	-- 自己主要阶段时把1张手卡送去墓地才能发动。这张卡的等级上升1星。这个效果1回合可以使用最多2次。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(45939611,0))  --"等级上升"
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(2)
	e1:SetCost(c45939611.cost)
	e1:SetOperation(c45939611.operation)
	c:RegisterEffect(e1)
end
-- 检索满足条件的卡片组并丢弃1张手卡作为cost
function c45939611.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查以自己来看手牌区是否存在至少1张满足条件的卡
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsAbleToGraveAsCost,tp,LOCATION_HAND,0,1,nil) end
	-- 选择并丢弃1张手卡作为代价
	Duel.DiscardHand(tp,Card.IsAbleToGraveAsCost,1,1,REASON_COST)
end
-- 将该怪兽的等级上升1星
function c45939611.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsFaceup() and c:IsRelateToEffect(e) then
		-- 等级上升
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_LEVEL)
		e1:SetValue(1)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE)
		c:RegisterEffect(e1)
	end
end
