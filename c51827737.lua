--リサイクル・ジェネクス
-- 效果：
-- ①：1回合1次，以自己墓地1只「次世代」怪兽为对象才能发动。这张卡直到结束阶段当作和作为对象的怪兽同名卡使用。
function c51827737.initial_effect(c)
	-- 效果原文内容：①：1回合1次，以自己墓地1只「次世代」怪兽为对象才能发动。这张卡直到结束阶段当作和作为对象的怪兽同名卡使用。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(51827737,0))  --"卡名变化"
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCountLimit(1)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTarget(c51827737.target)
	e1:SetOperation(c51827737.operation)
	c:RegisterEffect(e1)
end
-- 检索满足条件的墓地「次世代」怪兽作为效果对象
function c51827737.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and chkc:IsSetCard(0x2) end
	-- 检查是否存有满足条件的墓地「次世代」怪兽
	if chk==0 then return Duel.IsExistingTarget(Card.IsSetCard,tp,LOCATION_GRAVE,0,1,nil,0x2) end
	-- 向玩家提示选择「次世代」怪兽
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(51827737,1))  --"请选择一张名字带有「次世代」的怪兽"
	-- 选择1只墓地「次世代」怪兽作为效果对象
	Duel.SelectTarget(tp,Card.IsSetCard,tp,LOCATION_GRAVE,0,1,1,nil,0x2)
end
-- 将当前卡牌在结束阶段变为与目标怪兽同名卡
function c51827737.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前连锁的效果对象卡
	local tc=Duel.GetFirstTarget()
	if not c:IsRelateToEffect(e) or c:IsFacedown() or not tc:IsRelateToEffect(e) then return end
	-- 效果原文内容：这张卡直到结束阶段当作和作为对象的怪兽同名卡使用。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_CHANGE_CODE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
	e1:SetValue(tc:GetCode())
	c:RegisterEffect(e1)
end
