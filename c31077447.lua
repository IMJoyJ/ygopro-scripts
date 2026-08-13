--びっくり箱
-- 效果：
-- ①：对方场上有怪兽2只以上存在的场合，对方怪兽的攻击宣言时以那1只怪兽为对象才能发动。那次攻击无效，选那只怪兽以外的对方场上1只怪兽送去墓地。那之后，作为对象的怪兽的攻击力下降送去墓地的怪兽的攻击力和守备力之内较高方的数值。
function c31077447.initial_effect(c)
	-- ①：对方场上有怪兽2只以上存在的场合，对方怪兽的攻击宣言时以那1只怪兽为对象才能发动。那次攻击无效，选那只怪兽以外的对方场上1只怪兽送去墓地。那之后，作为对象的怪兽的攻击力下降送去墓地的怪兽的攻击力和守备力之内较高方的数值。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_ATTACK_ANNOUNCE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCondition(c31077447.condition)
	e1:SetTarget(c31077447.target)
	e1:SetOperation(c31077447.activate)
	c:RegisterEffect(e1)
end
-- 效果发动条件：攻击宣言的怪兽是对方怪兽，且对方场上的怪兽数量大于1。
function c31077447.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 判定攻击怪兽是否为对方怪兽，并确认对方场上怪兽数量超过1。
	return Duel.GetAttacker():IsControler(1-tp) and Duel.GetFieldGroupCount(tp,0,LOCATION_MZONE)>1
end
-- 取攻击怪兽为效果对象：确认连锁选择目标是该怪兽，且其在场并能成为效果对象，然后将其设为对象。
function c31077447.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	-- 获取当前攻击宣言的怪兽。
	local tc=Duel.GetAttacker()
	if chkc then return chkc==tc end
	if chk==0 then return tc:IsOnField() and tc:IsCanBeEffectTarget(e) end
	-- 将攻击怪兽设置为这张卡的效果对象。
	Duel.SetTargetCard(tc)
end
-- 效果处理：无效攻击；从对方场上选择攻击怪兽以外的1只怪兽送去墓地；若成功送去，则使攻击怪兽攻击力下降该怪兽的攻击力与守备力中较高方的数值。
function c31077447.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果对象（攻击怪兽）。
	local tc=Duel.GetFirstTarget()
	-- 无效攻击；若无效失败则终止处理。
	if not Duel.NegateAttack() then return end
	-- 弹出选择‘要送去墓地的卡’的提示，准备选择怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 从对方场上选择1只攻击怪兽以外的怪兽（送去墓地）。
	local g=Duel.SelectMatchingCard(tp,nil,tp,0,LOCATION_MZONE,1,1,tc)
	local sc=g:GetFirst()
	-- 确认选择的怪兽存在且被效果成功送去墓地并处于墓地，才继续处理攻击力下降。
	if sc and Duel.SendtoGrave(sc,REASON_EFFECT)~=0 and sc:IsLocation(LOCATION_GRAVE) then
		-- 中断当前效果处理，使攻击力下降作为‘那之后’的独立处理。
		Duel.BreakEffect()
		local val=math.max(0,sc:GetAttack(),sc:GetDefense())
		-- 那之后，作为对象的怪兽的攻击力下降送去墓地的怪兽的攻击力和守备力之内较高方的数值。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(-val)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
	end
end
