--天狼王 ブルー・セイリオス
-- 效果：
-- 调整＋调整以外的怪兽1只以上
-- 场上存在的这张卡被破坏送去墓地时，选择对方场上表侧表示存在的1只怪兽发动。选择的怪兽的攻击力下降2400。
function c32995007.initial_effect(c)
	-- 为“天狼王 苍狼星”添加同调召唤手续：需要任意1只调整怪兽＋1只以上调整以外的怪兽作为素材。
	aux.AddSynchroProcedure(c,nil,aux.NonTuner(nil),1)
	c:EnableReviveLimit()
	-- 场上存在的这张卡被破坏送去墓地时，选择对方场上表侧表示存在的1只怪兽发动。选择的怪兽的攻击力下降2400。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(32995007,0))  --"攻击下降"
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_TO_GRAVE)
	e1:SetCondition(c32995007.atkcon)
	e1:SetTarget(c32995007.atktg)
	e1:SetOperation(c32995007.atkop)
	c:RegisterEffect(e1)
end
-- 效果发动条件：这张卡从场上被破坏并送去墓地（此前位置为场上且破坏原因）。
function c32995007.atkcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousLocation(LOCATION_ONFIELD) and e:GetHandler():IsReason(REASON_DESTROY)
end
-- 效果发动时的取对象处理：选择对方场上表侧表示存在的1只怪兽作为对象。
function c32995007.atktg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and chkc:IsFaceup() end
	-- 发动前检查：对方场上存在至少1只表侧表示怪兽且能成为效果对象，否则不能发动。
	if chk==0 then return Duel.IsExistingTarget(Card.IsFaceup,tp,0,LOCATION_MZONE,1,nil) end
	-- 给玩家显示选择提示“请选择表侧表示的卡”。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 让玩家从对方场上选择1只表侧表示怪兽，并将其设置为当前连锁的对象。
	Duel.SelectTarget(tp,Card.IsFaceup,tp,0,LOCATION_MZONE,1,1,nil)
end
-- 效果处理：将对象怪兽的攻击力下降2400，并在对象上附加永续的攻击力增减效果，随标准重置条件失效。
function c32995007.atkop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中本效果选择的对象怪兽。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 选择的怪兽的攻击力下降2400。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(-2400)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
	end
end
