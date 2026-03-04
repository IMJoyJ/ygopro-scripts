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
-- 效果条件函数，判断卡片是否在墓地且因同调召唤被送入墓地
function c11287364.atkcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsLocation(LOCATION_GRAVE) and r==REASON_SYNCHRO
end
-- 效果目标选择函数，选择对方场上表侧表示的1只怪兽
function c11287364.atktg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and chkc:IsFaceup() end
	if chk==0 then return true end
	-- 向玩家提示选择“表侧表示”的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	-- 选择对方场上表侧表示的1只怪兽作为效果对象
	Duel.SelectTarget(tp,Card.IsFaceup,tp,0,LOCATION_MZONE,1,1,nil)
end
-- 效果发动时的处理函数，对目标怪兽造成攻击力下降效果
function c11287364.atkop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中选择的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 使目标怪兽的攻击力下降500
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		e1:SetValue(-500)
		tc:RegisterEffect(e1)
	end
end
