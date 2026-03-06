--派手ハネ
-- 效果：
-- 反转：可以选择场上最多3只怪兽回到手卡。
function c28357177.initial_effect(c)
	-- 反转：可以选择场上最多3只怪兽回到手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(28357177,0))  --"返回手牌"
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_FLIP+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e1:SetTarget(c28357177.target)
	e1:SetOperation(c28357177.operation)
	c:RegisterEffect(e1)
end
-- 选择场上满足条件的怪兽作为效果的对象
function c28357177.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsAbleToHand() end
	-- 检查是否场上存在可以送回手卡的怪兽
	if chk==0 then return Duel.IsExistingTarget(Card.IsAbleToHand,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 向玩家提示选择要送回手卡的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)  --"请选择要返回手牌的卡"
	-- 选择1~3只场上可以送回手卡的怪兽
	local g=Duel.SelectTarget(tp,Card.IsAbleToHand,tp,LOCATION_MZONE,LOCATION_MZONE,1,3,nil)
	-- 设置效果处理时要送回手卡的怪兽数量
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,g:GetCount(),0,0)
end
-- 将选中的怪兽送回手卡
function c28357177.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的效果对象怪兽组
	local tg=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	if tg then
		local g=tg:Filter(Card.IsRelateToEffect,nil,e)
		if g:GetCount()>0 then
			-- 将对象怪兽送回手卡
			Duel.SendtoHand(g,nil,REASON_EFFECT)
		end
	end
end
