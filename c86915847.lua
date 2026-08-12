--アーマード・ビー
-- 效果：
-- 1回合1次，选择对方场上表侧表示存在的1只怪兽才能发动。选择的对方怪兽的攻击力直到结束阶段时变成一半数值。
function c86915847.initial_effect(c)
	-- 1回合1次，选择对方场上表侧表示存在的1只怪兽才能发动。选择的对方怪兽的攻击力直到结束阶段时变成一半数值。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(86915847,0))  --"攻防减半"
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetTarget(c86915847.target)
	e1:SetOperation(c86915847.operation)
	c:RegisterEffect(e1)
end
-- 效果发动的靶向检测与目标选择处理
function c86915847.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(1-tp) and chkc:IsFaceup() and chkc:IsLocation(LOCATION_MZONE) end
	-- 检查对方场上是否存在可以作为效果对象的表侧表示怪兽
	if chk==0 then return Duel.IsExistingTarget(Card.IsFaceup,tp,0,LOCATION_MZONE,1,nil) end
	-- 向发动效果的玩家发送选择表侧表示卡的提示信息
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择对方场上1只表侧表示的怪兽作为效果对象
	Duel.SelectTarget(tp,Card.IsFaceup,tp,0,LOCATION_MZONE,1,1,nil)
end
-- 效果处理，将作为对象的怪兽攻击力直到结束阶段时变成一半
function c86915847.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取发动时选择的效果对象怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) then
		-- 选择的对方怪兽的攻击力直到结束阶段时变成一半数值。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_ATTACK_FINAL)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		e1:SetValue(math.ceil(tc:GetAttack()/2))
		tc:RegisterEffect(e1)
	end
end
