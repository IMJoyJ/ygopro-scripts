--精霊獣 ペトルフィン
-- 效果：
-- 自己对「精灵兽 川豚」1回合只能有1次特殊召唤。
-- ①：1回合1次，从手卡把1张「灵兽」卡除外，以对方场上1张卡为对象才能发动。那张卡回到手卡。
function c13890468.initial_effect(c)
	c:SetSPSummonOnce(13890468)
	-- 效果原文内容：①：1回合1次，从手卡把1张「灵兽」卡除外，以对方场上1张卡为对象才能发动。那张卡回到手卡。
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
-- 过滤函数，用于检测手卡中是否存在满足条件的「灵兽」卡（可除外作为代价）
function c13890468.filter(c)
	return c:IsSetCard(0xb5) and c:IsAbleToRemoveAsCost()
end
-- 效果的发动费用处理函数，检查是否能支付除外费用
function c13890468.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断是否满足除外费用条件：手卡中是否存在至少1张「灵兽」卡
	if chk==0 then return Duel.IsExistingMatchingCard(c13890468.filter,tp,LOCATION_HAND,0,1,nil) end
	-- 向玩家提示选择要除外的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	-- 选择1张手卡中的「灵兽」卡作为除外费用
	local g=Duel.SelectMatchingCard(tp,c13890468.filter,tp,LOCATION_HAND,0,1,1,nil)
	-- 将选中的卡除外（作为发动效果的费用）
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
-- 效果的对象选择函数，用于选择对方场上的卡作为效果对象
function c13890468.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsControler(1-tp) and chkc:IsAbleToHand() end
	-- 判断是否满足选择对象条件：对方场上是否存在至少1张可送回手卡的卡
	if chk==0 then return Duel.IsExistingTarget(Card.IsAbleToHand,tp,0,LOCATION_ONFIELD,1,nil) end
	-- 向玩家提示选择要送回手卡的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)
	-- 选择对方场上的1张卡作为效果对象
	local g=Duel.SelectTarget(tp,Card.IsAbleToHand,tp,0,LOCATION_ONFIELD,1,1,nil)
	-- 设置效果处理信息，确定效果将使目标卡送回手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- 效果的处理函数，执行将目标卡送回手牌的操作
function c13890468.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中被选择的目标卡
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标卡送回玩家手牌
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end
