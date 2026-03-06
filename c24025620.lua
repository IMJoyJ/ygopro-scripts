--ダブル・プロテクター
-- 效果：
-- 自己场上存在的这张卡被战斗破坏送去墓地时，对方场上表侧表示存在的1只怪兽的攻击力直到结束阶段时变成一半数值。
function c24025620.initial_effect(c)
	-- 效果原文内容：自己场上存在的这张卡被战斗破坏送去墓地时，对方场上表侧表示存在的1只怪兽的攻击力直到结束阶段时变成一半数值。
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
-- 效果作用：判断触发条件，确认该卡是否因战斗破坏而进入墓地且为我方控制者。
function c24025620.atkcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsLocation(LOCATION_GRAVE) and c:IsReason(REASON_BATTLE) and c:IsPreviousControler(tp)
end
-- 效果作用：选择对方场上表侧表示的1只怪兽作为目标。
function c24025620.atktg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(1-tp) and chkc:IsLocation(LOCATION_MZONE) and chkc:IsFaceup() end
	-- 效果作用：检查是否有对方场上表侧表示的怪兽可作为目标。
	if chk==0 then return Duel.IsExistingTarget(Card.IsFaceup,tp,0,LOCATION_MZONE,1,nil) end
	-- 效果作用：提示玩家选择对方场上表侧表示的怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 效果作用：选择对方场上表侧表示的1只怪兽为目标。
	Duel.SelectTarget(tp,Card.IsFaceup,tp,0,LOCATION_MZONE,1,1,nil)
end
-- 效果作用：将目标怪兽的攻击力变为原来的一半数值，持续到结束阶段。
function c24025620.atkop(e,tp,eg,ep,ev,re,r,rp)
	-- 效果作用：获取当前连锁中选择的目标怪兽。
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsFaceup() and tc:IsRelateToEffect(e) then
		-- 效果原文内容：对方场上表侧表示存在的1只怪兽的攻击力直到结束阶段时变成一半数值。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_ATTACK_FINAL)
		e1:SetValue(math.ceil(tc:GetAttack()/2))
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
	end
end
