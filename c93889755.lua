--マーダーサーカス
-- 效果：
-- 这张卡的表示形式从守备表示变成攻击表示时，对方场上的1只怪兽回到持有者手卡。
function c93889755.initial_effect(c)
	-- 这张卡的表示形式从守备表示变成攻击表示时，对方场上的1只怪兽回到持有者手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(93889755,0))  --"对方1只怪兽回到手牌"
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_CHANGE_POS)
	e1:SetCondition(c93889755.condition)
	e1:SetTarget(c93889755.target)
	e1:SetOperation(c93889755.operation)
	c:RegisterEffect(e1)
end
-- 判断此卡是否从守备表示变为了表侧攻击表示
function c93889755.condition(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsPreviousPosition(POS_DEFENSE) and c:IsFaceup() and c:IsAttackPos()
end
-- 效果发动的对象选择与检测，选择对方场上1只怪兽作为对象，并设置操作信息
function c93889755.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and chkc:IsAbleToHand() end
	if chk==0 then return true end
	-- 给玩家发送提示信息，提示选择要返回手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)  --"请选择要返回手牌的卡"
	-- 选择对方场上1只可以回到手牌的怪兽作为效果的对象
	local g=Duel.SelectTarget(tp,Card.IsAbleToHand,tp,0,LOCATION_MZONE,1,1,nil)
	-- 设置效果处理信息，表示该连锁的处理为将选中的卡片送回手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,g:GetCount(),0,0)
end
-- 效果处理的执行，将选中的对象怪兽送回持有者的手牌
function c93889755.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取在发动时选择的第一个效果对象
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		-- 通过效果将目标怪兽送回持有者的手牌
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end
