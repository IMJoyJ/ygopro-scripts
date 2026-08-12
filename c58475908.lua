--ゼンマイマイ
-- 效果：
-- 自己的主要阶段时，可以选择场上盖放的1张卡回到持有者手卡。这个效果只在这张卡在场上表侧表示存在能使用1次。
function c58475908.initial_effect(c)
	-- 自己的主要阶段时，可以选择场上盖放的1张卡回到持有者手卡。这个效果只在这张卡在场上表侧表示存在能使用1次。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(58475908,0))  --"返回手牌"
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_NO_TURN_RESET)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetTarget(c58475908.target)
	e1:SetOperation(c58475908.operation)
	c:RegisterEffect(e1)
end
-- 过滤条件：场上盖放且能回到手卡的卡片
function c58475908.filter(c)
	return c:IsFacedown() and c:IsAbleToHand()
end
-- 效果的发动准备与目标选择：验证并选择场上盖放的卡片作为对象，并设置操作信息
function c58475908.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and c58475908.filter(chkc) end
	-- 在发动准备阶段，检查场上是否存在至少1张满足过滤条件的卡片
	if chk==0 then return Duel.IsExistingTarget(c58475908.filter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
	-- 向玩家发送提示信息，提示选择要返回手牌的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)  --"请选择要返回手牌的卡"
	-- 玩家选择场上盖放的1张卡片作为该效果的对象
	local g=Duel.SelectTarget(tp,c58475908.filter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
	-- 设置效果处理信息：将选中的1张卡片送回手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- 效果的处理：获取对象卡片，确认其仍为盖放状态且与效果有关联后，将其送回手牌
function c58475908.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取在发动阶段被选择为效果对象的卡片
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsFacedown() and tc:IsRelateToEffect(e) then
		-- 通过效果将目标卡片送回其持有者的手牌
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end
