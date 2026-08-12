--虚栄巨影
-- 效果：
-- ①：怪兽的攻击宣言时，以场上1只表侧表示怪兽为对象才能发动。那只怪兽的攻击力直到那次战斗阶段结束时上升1000。
function c73178098.initial_effect(c)
	-- ①：怪兽的攻击宣言时，以场上1只表侧表示怪兽为对象才能发动。那只怪兽的攻击力直到那次战斗阶段结束时上升1000。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_ATTACK_ANNOUNCE)
	e1:SetTarget(c73178098.target)
	e1:SetOperation(c73178098.activate)
	c:RegisterEffect(e1)
end
-- 效果发动的靶向检测与选择对象处理
function c73178098.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsFaceup() end
	-- 在发动阶段，检查场上是否存在至少1只表侧表示的怪兽作为合法对象
	if chk==0 then return Duel.IsExistingTarget(Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 向发动效果的玩家发送提示信息，要求选择表侧表示的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择场上1只表侧表示怪兽作为效果对象
	local g=Duel.SelectTarget(tp,Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
end
-- 效果处理函数，使作为对象的怪兽攻击力上升
function c73178098.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取在发动时被选为对象的怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 那只怪兽的攻击力直到那次战斗阶段结束时上升1000。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_BATTLE)
		e1:SetValue(1000)
		tc:RegisterEffect(e1)
	end
end
