--ハリマンボウ
-- 效果：
-- 这张卡被送去墓地时，选择对方场上表侧表示存在的1只怪兽发动。选择的对方怪兽的攻击力下降500。
function c56223084.initial_effect(c)
	-- 这张卡被送去墓地时，选择对方场上表侧表示存在的1只怪兽发动。选择的对方怪兽的攻击力下降500。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(56223084,0))  --"攻击下降"
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_TO_GRAVE)
	e1:SetTarget(c56223084.target)
	e1:SetOperation(c56223084.operation)
	c:RegisterEffect(e1)
end
-- 效果发动时的目标选择处理，用于确认并选择对方场上表侧表示的怪兽作为对象。
function c56223084.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(1-tp) and chkc:IsLocation(LOCATION_MZONE) and chkc:IsFaceup() end
	if chk==0 then return true end
	-- 向发动效果的玩家发送提示信息，要求选择表侧表示的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择对方场上表侧表示存在的1只怪兽作为效果的对象。
	Duel.SelectTarget(tp,Card.IsFaceup,tp,0,LOCATION_MZONE,1,1,nil)
end
-- 效果解决时的操作处理，使作为对象的怪兽攻击力下降500。
function c56223084.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取在效果发动时所选择的那个对象怪兽。
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsFaceup() and tc:IsRelateToEffect(e) then
		-- 选择的对方怪兽的攻击力下降500。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(-500)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
	end
end
