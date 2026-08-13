--クイック・スパナイト
-- 效果：
-- 这张卡被同调怪兽的同调召唤使用送去墓地的场合，对方场上表侧表示存在的1只怪兽的攻击力下降500。
function c11287364.initial_effect(c)
	-- 这张卡被同调怪兽的同调召唤使用送去墓地的场合，对方场上表侧表示存在的1只怪兽的攻击力下降500。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(11287364,0))  --"攻击下降 "
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_BE_MATERIAL)
	e1:SetCondition(c11287364.atkcon)
	e1:SetTarget(c11287364.atktg)
	e1:SetOperation(c11287364.atkop)
	c:RegisterEffect(e1)
end
-- 判断此卡是否因同调怪兽的同调召唤被使用并送去墓地（当前位于墓地且原因为同调召唤）。
function c11287364.atkcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsLocation(LOCATION_GRAVE) and r==REASON_SYNCHRO
end
-- 取对象效果：选择对方场上表侧表示的1只怪兽作为对象；发动时无需其他条件，若检查已选对象则需满足位于主要怪兽区、对方场上且表侧表示。
function c11287364.atktg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and chkc:IsFaceup() end
	if chk==0 then return true end
	-- 给玩家显示选择提示信息，要求选择表侧表示的怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 从对方场上（主要怪兽区）选择1只表侧表示怪兽作为效果对象。
	Duel.SelectTarget(tp,Card.IsFaceup,tp,0,LOCATION_MZONE,1,1,nil)
end
-- 处理效果：若对象仍与效果关联且为表侧表示，则对其赋予攻击力下降500的持续效果。
function c11287364.atkop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果处理时选择的对象怪兽。
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 对方场上表侧表示存在的1只怪兽的攻击力下降500。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		e1:SetValue(-500)
		tc:RegisterEffect(e1)
	end
end
