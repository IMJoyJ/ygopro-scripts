--リチュア・キラー
-- 效果：
-- 这张卡召唤·反转召唤成功时，自己场上有这张卡以外的名字带有「遗式」的怪兽表侧表示存在的场合，可以选择这张卡以外的自己场上存在的1只怪兽回到手卡。
function c37557626.initial_effect(c)
	-- 诱发选发效果，对应一速的【……才能发动】
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(37557626,0))  --"返回手卡"
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetCondition(c37557626.condition)
	e1:SetTarget(c37557626.target)
	e1:SetOperation(c37557626.operation)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_FLIP_SUMMON_SUCCESS)
	c:RegisterEffect(e2)
end
-- 检查场上是否存在表侧表示的「遗式」怪兽
function c37557626.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x3a)
end
-- 效果发动条件，判断自己场上有这张卡以外的名字带有「遗式」的怪兽表侧表示存在
function c37557626.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检索满足条件的「遗式」怪兽数量是否大于等于1
	return Duel.IsExistingMatchingCard(c37557626.cfilter,tp,LOCATION_MZONE,0,1,e:GetHandler())
end
-- 选择效果对象，选择1只可以送入手牌的自己场上的怪兽
function c37557626.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and chkc:IsAbleToHand() end
	-- 检查是否存在可以送入手牌的自己场上的怪兽
	if chk==0 then return Duel.IsExistingTarget(Card.IsAbleToHand,tp,LOCATION_MZONE,0,1,e:GetHandler()) end
	-- 提示玩家选择要返回手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)  --"请选择要返回手牌的卡"
	-- 选择1只可以送入手牌的自己场上的怪兽作为效果对象
	local g=Duel.SelectTarget(tp,Card.IsAbleToHand,tp,LOCATION_MZONE,0,1,1,e:GetHandler())
	-- 设置效果处理信息，确定将要处理的卡为1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- 效果处理，将选定的怪兽送入手牌
function c37557626.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 再次确认自己场上有名字带有「遗式」的怪兽表侧表示存在
	if not Duel.IsExistingMatchingCard(c37557626.cfilter,tp,LOCATION_MZONE,0,1,e:GetHandler()) then return end
	-- 获取当前连锁的效果对象卡
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将对象怪兽送入手牌
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end
