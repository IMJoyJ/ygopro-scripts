--収縮
-- 效果：
-- ①：以场上1只表侧表示怪兽为对象才能发动。那只怪兽的原本攻击力直到回合结束时变成一半。
function c55713623.initial_effect(c)
	-- ①：以场上1只表侧表示怪兽为对象才能发动。那只怪兽的原本攻击力直到回合结束时变成一半。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetHintTiming(TIMING_DAMAGE_STEP)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP)
	e1:SetCode(EVENT_FREE_CHAIN)
	-- 设置效果的发动条件，限制在伤害步骤中只有伤害计算前可以发动。
	e1:SetCondition(aux.dscon)
	e1:SetTarget(c55713623.target)
	e1:SetOperation(c55713623.activate)
	c:RegisterEffect(e1)
end
-- 定义效果发动的目标选择逻辑，包括对历史选择的合法性判断和当前可选择目标的检测。
function c55713623.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsFaceup() end
	-- 在发动效果的准备阶段，检测双方场上是否存在可以作为对象的表侧表示怪兽。
	if chk==0 then return Duel.IsExistingTarget(Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 向发动效果的玩家提示选择表侧表示的卡片。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 让玩家选择场上1只表侧表示的怪兽作为效果对象。
	Duel.SelectTarget(tp,Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
end
-- 定义效果处理逻辑，使目标怪兽的原本攻击力减半直到回合结束。
function c55713623.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取在发动时被选择为效果对象的怪兽。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() then
		local batk=tc:GetBaseAttack()
		-- 那只怪兽的原本攻击力直到回合结束时变成一半。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_BASE_ATTACK_FINAL)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		e1:SetValue(math.ceil(batk/2))
		tc:RegisterEffect(e1)
	end
end
