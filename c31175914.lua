--アタック・ゲイナー
-- 效果：
-- 这张卡作为同调召唤的素材送去墓地的场合，对方场上表侧表示存在的1只怪兽的攻击力直到结束阶段时下降1000。
function c31175914.initial_effect(c)
	-- 这张卡作为同调召唤的素材送去墓地的场合，对方场上表侧表示存在的1只怪兽的攻击力直到结束阶段时下降1000。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(31175914,0))  --"攻击下降"
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_BE_MATERIAL)
	e1:SetCondition(c31175914.atkcon)
	e1:SetTarget(c31175914.atktg)
	e1:SetOperation(c31175914.atkop)
	c:RegisterEffect(e1)
end
-- 效果发动条件：这张卡作为同调召唤的素材被送去墓地，且当前位于墓地。
function c31175914.atkcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsLocation(LOCATION_GRAVE) and r==REASON_SYNCHRO
end
-- 选择对象：从对方场上选择1只表侧表示怪兽作为效果对象；在连锁中检查对象时限定为对方场上的表侧表示怪兽。
function c31175914.atktg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and chkc:IsFaceup() end
	if chk==0 then return true end
	-- 向操作玩家显示“请选择表侧表示的卡”的提示信息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 让玩家从对方场上选择1只表侧表示怪兽，并将该卡登记为当前连锁的效果对象。
	Duel.SelectTarget(tp,Card.IsFaceup,tp,0,LOCATION_MZONE,1,1,nil)
end
-- 效果处理：若对象怪兽仍与效果关联且表侧表示，则赋予其攻击力下降1000的效果，直到结束阶段时重置。
function c31175914.atkop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果处理时选择的第一只对象怪兽。
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 攻击力直到结束阶段时下降1000。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		e1:SetValue(-1000)
		tc:RegisterEffect(e1)
	end
end
