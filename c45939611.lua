--リトル・フェアリー
-- 效果：
-- 自己的主要阶段时把1张手卡送去墓地才能发动。这张卡的等级上升1星。这个效果1回合可以使用最多2次。
function c45939611.initial_effect(c)
	-- 自己的主要阶段时把1张手卡送去墓地才能发动。这张卡的等级上升1星。这个效果1回合可以使用最多2次。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(45939611,0))  --"等级上升"
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(2)
	e1:SetCost(c45939611.cost)
	e1:SetOperation(c45939611.operation)
	c:RegisterEffect(e1)
end
-- 定义发动代价函数：在效果发动时确认并执行从手卡丢弃1张卡送去墓地作为代价。
function c45939611.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 合法性检查：确认自己手卡中是否存在1张能够作为代价送去墓地的卡，存在才允许发动。
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsAbleToGraveAsCost,tp,LOCATION_HAND,0,1,nil) end
	-- 支付代价：从手卡选择并丢弃1张卡送去墓地（作为发动代价）。
	Duel.DiscardHand(tp,Card.IsAbleToGraveAsCost,1,1,REASON_COST)
end
-- 定义效果处理函数：效果处理时，若此卡仍表侧表示且与效果关联，则生成一个等级上升1星的效果并注册给此卡。
function c45939611.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsFaceup() and c:IsRelateToEffect(e) then
		-- 这张卡的等级上升1星。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_LEVEL)
		e1:SetValue(1)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE)
		c:RegisterEffect(e1)
	end
end
