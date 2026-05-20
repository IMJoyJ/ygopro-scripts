--爆風トカゲ
-- 效果：
-- ①：这张卡反转的场合，以对方场上1只怪兽为对象发动。那只对方怪兽回到持有者手卡。
function c77491079.initial_effect(c)
	-- ①：这张卡反转的场合，以对方场上1只怪兽为对象发动。那只对方怪兽回到持有者手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(77491079,0))  --"返回手牌"
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_FLIP)
	e1:SetTarget(c77491079.target)
	e1:SetOperation(c77491079.operation)
	c:RegisterEffect(e1)
end
-- 效果①的target函数，用于确认发动条件、选择对方场上1只怪兽作为对象并设置操作信息
function c77491079.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(1-tp) and chkc:IsLocation(LOCATION_MZONE) and chkc:IsAbleToHand() end
	if chk==0 then return true end
	-- 向玩家提示选择要返回手牌的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)  --"请选择要返回手牌的卡"
	-- 选择对方场上1只可以回到手牌的怪兽作为效果的对象
	local g=Duel.SelectTarget(tp,Card.IsAbleToHand,tp,0,LOCATION_MZONE,1,1,nil)
	-- 设置操作信息，表示此效果的处理为将选中的卡片送回手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,g:GetCount(),0,0)
end
-- 效果①的operation函数，用于执行将对象怪兽送回手牌的效果处理
function c77491079.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取在发动时选择的对象怪兽
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		-- 因效果将目标怪兽送回持有者的手牌
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end
