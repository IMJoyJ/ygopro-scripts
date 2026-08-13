--リサイクル・ジェネクス
-- 效果：
-- ①：1回合1次，以自己墓地1只「次世代」怪兽为对象才能发动。这张卡直到结束阶段当作和作为对象的怪兽同名卡使用。
function c51827737.initial_effect(c)
	-- ①：1回合1次，以自己墓地1只「次世代」怪兽为对象才能发动。这张卡直到结束阶段当作和作为对象的怪兽同名卡使用。
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
-- 效果发动时的目标选择部分：首先验证连锁候选对象是否合法（对方场上怪兽？不，这里检查的是墓地且控制者为自己的「次世代」怪兽），然后判断是否存在可选的墓地「次世代」怪兽，最后提示玩家选择1只「次世代」怪兽作为对象。
function c51827737.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and chkc:IsSetCard(0x2) end
	-- 检查发动时是否存在满足条件的墓地「次世代」怪兽（1只以上），以此判断效果是否可以发动。
	if chk==0 then return Duel.IsExistingTarget(Card.IsSetCard,tp,LOCATION_GRAVE,0,1,nil,0x2) end
	-- 弹出选择提示框，显示“请选择一张名字带有「次世代」的怪兽”，让玩家明确接下来要选择的对象类型。
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(51827737,1))  --"请选择一张名字带有「次世代」的怪兽"
	-- 从自己墓地的「次世代」怪兽中精确选择1只作为效果对象，并设置为当前连锁的对象。
	Duel.SelectTarget(tp,Card.IsSetCard,tp,LOCATION_GRAVE,0,1,1,nil,0x2)
end
-- 效果处理部分：获取效果发动者自身和选择的对象，确认双方仍然与效果关联且自身未里侧表示后，给自身赋予一个改变卡名的效果，使其在结束阶段前当作与对象怪兽同名的卡使用。
function c51827737.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取效果发动时选择的那1只墓地「次世代」怪兽。
	local tc=Duel.GetFirstTarget()
	if not c:IsRelateToEffect(e) or c:IsFacedown() or not tc:IsRelateToEffect(e) then return end
	-- 这张卡直到结束阶段当作和作为对象的怪兽同名卡使用。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_CHANGE_CODE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
	e1:SetValue(tc:GetCode())
	c:RegisterEffect(e1)
end
