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
-- 定义筛选函数：选择手卡中可作为代价丢弃的水属性怪兽，要求其属性为水、可以被丢弃且可作为代价送去墓地。
function c18318842.filter(c)
	return c:IsAttribute(ATTRIBUTE_WATER) and c:IsDiscardable() and c:IsAbleToGraveAsCost()
end
-- 定义效果发动代价：需要从手卡丢弃1只满足条件的水属性怪兽作为代价；先检查是否存在合法代价，再实际执行丢弃。
function c18318842.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 代价检查阶段：确认手卡中是否存在至少1只满足筛选条件的水属性怪兽，若不存在则不能发动效果。
	if chk==0 then return Duel.IsExistingMatchingCard(c18318842.filter,tp,LOCATION_HAND,0,1,nil) end
	-- 实际支付代价：从手卡选择并丢弃1只满足条件的水属性怪兽送去墓地，丢弃原因记为代价与丢弃。
	Duel.DiscardHand(tp,c18318842.filter,1,1,REASON_COST+REASON_DISCARD)
end
-- 定义效果发动时的取对象与操作信息设置：必须选择场上1张卡为对象，并记录为返回手牌的效果。
function c18318842.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsAbleToHand() end
	-- 发动合法性检查：确认场上存在至少1张可以成为对象且能够返回手牌的卡，否则不能发动。
	if chk==0 then return Duel.IsExistingTarget(Card.IsAbleToHand,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
	-- 向玩家显示选择提示文字“请选择要返回手牌的卡”，用于引导选择对象。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)  --"请选择要返回手牌的卡"
	-- 让玩家从双方场上选择1张能够返回手牌的卡作为效果对象，并自动登记为当前连锁的对象。
	local g=Duel.SelectTarget(tp,Card.IsAbleToHand,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
	-- 设置连锁操作信息：将本次效果处理记录为把对象卡返回手牌（CATEGORY_TOHAND），对象数量为1。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- 定义效果处理：取得发动时选择的对象卡，若其仍与效果关联，则将其返回持有者手卡。
function c18318842.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中登记的效果对象卡，即发动时选择的那张场上卡片。
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		-- 将对象卡送回其持有者的手卡，处理原因为效果（REASON_EFFECT）。
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end
