--精霊獣 ペトルフィン
-- 效果：
-- 自己对「精灵兽 川豚」1回合只能有1次特殊召唤。
-- ①：1回合1次，从手卡把1张「灵兽」卡除外，以对方场上1张卡为对象才能发动。那张卡回到手卡。
function c13890468.initial_effect(c)
	c:SetSPSummonOnce(13890468)
	-- ①：1回合1次，从手卡把1张「灵兽」卡除外，以对方场上1张卡为对象才能发动。那张卡回到手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetCountLimit(1)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCost(c13890468.cost)
	e1:SetTarget(c13890468.target)
	e1:SetOperation(c13890468.operation)
	c:RegisterEffect(e1)
end
-- 筛选函数：判断手牌中的卡是否为「灵兽」卡，并且可以作为代价除外。
function c13890468.filter(c)
	return c:IsSetCard(0xb5) and c:IsAbleToRemoveAsCost()
end
-- 代价处理函数：先确认手牌中是否存在符合条件的灵兽卡，然后选择1张以外侧表示除外作为发动代价。
function c13890468.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- cost检查阶段：检查是否存在至少1张手牌的「灵兽」卡满足可作为代价除外的条件。
	if chk==0 then return Duel.IsExistingMatchingCard(c13890468.filter,tp,LOCATION_HAND,0,1,nil) end
	-- 向玩家提示选择要除外的卡片（提示消息类型为选择卡片）。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 让发动玩家从手牌选择1张满足filter条件（灵兽且可除外）的卡作为代价。
	local g=Duel.SelectMatchingCard(tp,c13890468.filter,tp,LOCATION_HAND,0,1,1,nil)
	-- 将选中的卡以表侧表示除外，作为发动效果的代价。
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
-- 取对象目标处理函数：只能选择对方场上的1张卡作为对象，该卡需要能够加入手卡，并设置对应的回手牌操作信息。
function c13890468.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsControler(1-tp) and chkc:IsAbleToHand() end
	-- Target检查阶段：确认对方场上是否存在至少1张可以被回手牌且能成为效果对象的卡。
	if chk==0 then return Duel.IsExistingTarget(Card.IsAbleToHand,tp,0,LOCATION_ONFIELD,1,nil) end
	-- 向玩家提示选择要返回手牌的卡片。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)  --"请选择要返回手牌的卡"
	-- 选择对方场上1张可返回手牌的卡作为效果对象，并将其登记为当前连锁的对象。
	local g=Duel.SelectTarget(tp,Card.IsAbleToHand,tp,0,LOCATION_ONFIELD,1,1,nil)
	-- 设置操作信息：本次效果处理将把1张对象卡返回持有者手牌（分类为CATEGORY_TOHAND）。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- 效果处理函数：在效果处理时获取连锁的对象卡，若该卡仍与效果关联，则将其返回持有者手牌。
function c13890468.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 取得本次效果连锁中登记的对象卡（即发动时选择的目标）。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将对象卡返回其持有者的手牌，处理原因为效果处理。
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end
