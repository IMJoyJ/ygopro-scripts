--ダークジェロイド
-- 效果：
-- 这张卡召唤·反转召唤·特殊召唤成功时，选择场上1只表侧表示怪兽。只要那只怪兽在场上表侧表示存在，攻击力下降800。
function c90980792.initial_effect(c)
	-- 这张卡召唤·反转召唤·特殊召唤成功时，选择场上1只表侧表示怪兽。只要那只怪兽在场上表侧表示存在，攻击力下降800。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(90980792,0))  --"攻击下降"
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetTarget(c90980792.target)
	e1:SetOperation(c90980792.operation)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
	local e3=e1:Clone()
	e3:SetCode(EVENT_FLIP_SUMMON_SUCCESS)
	c:RegisterEffect(e3)
end
-- 效果发动时的对象选择处理，判断并选择场上1只表侧表示怪兽作为效果对象
function c90980792.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsFaceup() end
	-- 在效果发动准备阶段，检查双方场上是否存在至少1只表侧表示怪兽作为可选对象
	if chk==0 then return Duel.IsExistingTarget(Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 向发动效果的玩家提示选择表侧表示的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 让发动效果的玩家选择双方场上1只表侧表示怪兽作为效果对象
	Duel.SelectTarget(tp,Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
end
-- 效果处理时的具体操作，使选择的怪兽攻击力下降800
function c90980792.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取在效果发动时选择的效果对象怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) then
		-- 只要那只怪兽在场上表侧表示存在，攻击力下降800。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(-800)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
	end
end
