--ダブル・プロテクター
-- 效果：
-- 自己场上存在的这张卡被战斗破坏送去墓地时，对方场上表侧表示存在的1只怪兽的攻击力直到结束阶段时变成一半数值。
function c24025620.initial_effect(c)
	-- 自己场上存在的这张卡被战斗破坏送去墓地时，对方场上表侧表示存在的1只怪兽的攻击力直到结束阶段时变成一半数值。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(24025620,0))  --"攻击变化"
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_BATTLE_DESTROYED)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCondition(c24025620.atkcon)
	e1:SetTarget(c24025620.atktg)
	e1:SetOperation(c24025620.atkop)
	c:RegisterEffect(e1)
end
-- 发动条件判断：本卡从场上被战斗破坏后送去墓地，且战斗破坏之前由这张卡的效果发动者（原控制者）控制，满足“自己场上存在的这张卡被战斗破坏送去墓地时”。
function c24025620.atkcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsLocation(LOCATION_GRAVE) and c:IsReason(REASON_BATTLE) and c:IsPreviousControler(tp)
end
-- 取对象的目标选择处理：从对方场上表侧表示怪兽中选择1只作为效果对象，并校验对象必须是对方场上表侧表示怪兽。
function c24025620.atktg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(1-tp) and chkc:IsLocation(LOCATION_MZONE) and chkc:IsFaceup() end
	-- 效果发动时确认是否有合法对象：检查对方场上是否存在至少1只表侧表示怪兽可以作为效果对象（取对象效果需要存在合法目标才能发动）。
	if chk==0 then return Duel.IsExistingTarget(Card.IsFaceup,tp,0,LOCATION_MZONE,1,nil) end
	-- 向操作者显示“请选择表侧表示的卡”的提示消息，用于接下来的选择怪兽操作。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 让玩家从对方场上表侧表示怪兽中选择1只，并将其登记为当前连锁的效果对象。
	Duel.SelectTarget(tp,Card.IsFaceup,tp,0,LOCATION_MZONE,1,1,nil)
end
-- 效果处理：获取对象怪兽，若对象仍然表侧表示且与效果存在关联，则赋予其攻击力变为原攻击力一半的永续效果，并持续到结束阶段。
function c24025620.atkop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的效果所选择的对象怪兽。
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsFaceup() and tc:IsRelateToEffect(e) then
		-- 对方场上表侧表示存在的1只怪兽的攻击力直到结束阶段时变成一半数值。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_ATTACK_FINAL)
		e1:SetValue(math.ceil(tc:GetAttack()/2))
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
	end
end
