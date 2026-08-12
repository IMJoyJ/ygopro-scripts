--びっくり箱
-- 效果：
-- ①：对方场上有怪兽2只以上存在的场合，对方怪兽的攻击宣言时以那1只怪兽为对象才能发动。那次攻击无效，选那只怪兽以外的对方场上1只怪兽送去墓地。那之后，作为对象的怪兽的攻击力下降送去墓地的怪兽的攻击力和守备力之内较高方的数值。
function c31077447.initial_effect(c)
	-- 效果定义：当对方怪兽攻击宣言时才能发动，将该怪兽作为对象。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_ATTACK_ANNOUNCE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCondition(c31077447.condition)
	e1:SetTarget(c31077447.target)
	e1:SetOperation(c31077447.activate)
	c:RegisterEffect(e1)
end
-- 效果条件：对方场上有2只以上怪兽存在且攻击怪兽的控制者为对方。
function c31077447.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 对方场上有2只以上怪兽存在且攻击怪兽的控制者为对方。
	return Duel.GetAttacker():IsControler(1-tp) and Duel.GetFieldGroupCount(tp,0,LOCATION_MZONE)>1
end
-- 效果目标：以攻击怪兽为对象。
function c31077447.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	-- 获取当前攻击怪兽。
	local tc=Duel.GetAttacker()
	if chkc then return chkc==tc end
	if chk==0 then return tc:IsOnField() and tc:IsCanBeEffectTarget(e) end
	-- 将攻击怪兽设置为效果对象。
	Duel.SetTargetCard(tc)
end
-- 效果处理：无效此次攻击，选择对方场上1只怪兽送去墓地，并使攻击怪兽攻击力下降。
function c31077447.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前效果对象怪兽。
	local tc=Duel.GetFirstTarget()
	-- 无效此次攻击，若无效失败则返回。
	if not Duel.NegateAttack() then return end
	-- 提示玩家选择要送去墓地的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 选择对方场上1只怪兽送去墓地。
	local g=Duel.SelectMatchingCard(tp,nil,tp,0,LOCATION_MZONE,1,1,tc)
	local sc=g:GetFirst()
	-- 将选中的怪兽送去墓地并确认其在墓地。
	if sc and Duel.SendtoGrave(sc,REASON_EFFECT)~=0 and sc:IsLocation(LOCATION_GRAVE) then
		-- 中断当前效果处理，使后续处理视为错时点。
		Duel.BreakEffect()
		local val=math.max(0,sc:GetAttack(),sc:GetDefense())
		-- 使对象怪兽的攻击力下降送去墓地的怪兽的攻击力和守备力之中较高方的数值。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(-val)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
	end
end
