--アビス・ソルジャー
-- 效果：
-- ①：1回合1次，从手卡把1只水属性怪兽丢弃去墓地，以场上1张卡为对象才能发动。那张卡回到持有者手卡。
function c18318842.initial_effect(c)
	-- ①：1回合1次，从手卡把1只水属性怪兽丢弃去墓地，以场上1张卡为对象才能发动。那张卡回到持有者手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(18318842,0))  --"返回手牌"
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCost(c18318842.cost)
	e1:SetTarget(c18318842.target)
	e1:SetOperation(c18318842.operation)
	c:RegisterEffect(e1)
end
-- 过滤函数，用于筛选手卡中满足条件的水属性怪兽（可丢弃且能送入墓地）
function c18318842.filter(c)
	return c:IsAttribute(ATTRIBUTE_WATER) and c:IsDiscardable() and c:IsAbleToGraveAsCost()
end
-- 效果的发动费用，检查玩家手卡是否存在满足条件的水属性怪兽并将其丢弃
function c18318842.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家手卡是否存在至少1张满足条件的水属性怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c18318842.filter,tp,LOCATION_HAND,0,1,nil) end
	-- 从玩家手卡中选择并丢弃1张满足条件的水属性怪兽
	Duel.DiscardHand(tp,c18318842.filter,1,1,REASON_COST+REASON_DISCARD)
end
-- 效果的对象选择函数，检查场上是否存在至少1张能回到手卡的卡
function c18318842.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsAbleToHand() end
	-- 检查场上是否存在至少1张能回到手卡的卡
	if chk==0 then return Duel.IsExistingTarget(Card.IsAbleToHand,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
	-- 向玩家提示“请选择要返回手牌的卡”
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)  --"请选择要返回手牌的卡"
	-- 选择场上1张能回到手卡的卡作为效果对象
	local g=Duel.SelectTarget(tp,Card.IsAbleToHand,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
	-- 设置效果处理时的操作信息，指定将要返回手卡的卡
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- 效果的处理函数，将选定的卡送回持有者手卡
function c18318842.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁效果的对象卡
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		-- 将对象卡以效果原因送回持有者手卡
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end
