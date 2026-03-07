--BF－竜巻のハリケーン
-- 效果：
-- ①：1回合1次，以场上1只同调怪兽为对象才能发动。这张卡的攻击力直到回合结束时变成和作为对象的怪兽的攻击力相同。
function c36442179.initial_effect(c)
	-- 效果原文：①：1回合1次，以场上1只同调怪兽为对象才能发动。这张卡的攻击力直到回合结束时变成和作为对象的怪兽的攻击力相同。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(36442179,0))  --"攻击变化"
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetTarget(c36442179.target)
	e1:SetOperation(c36442179.operation)
	c:RegisterEffect(e1)
end
-- 检索满足条件的卡片组：表侧表示的同调怪兽
function c36442179.filter(c)
	return c:IsFaceup() and c:IsType(TYPE_SYNCHRO)
end
-- 效果作用：选择对方场上的1只表侧表示的同调怪兽作为对象
function c36442179.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(1-tp) and chkc:IsLocation(LOCATION_MZONE) and c36442179.filter(chkc) end
	-- 效果作用：确认是否满足选择对象的条件
	if chk==0 then return Duel.IsExistingTarget(c36442179.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 效果作用：向玩家提示“请选择表侧表示的卡”
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 效果作用：选择满足条件的1只怪兽作为对象
	Duel.SelectTarget(tp,c36442179.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
end
-- 效果作用：将自身攻击力变成与对象怪兽的攻击力相同
function c36442179.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 效果作用：获取当前连锁中的目标怪兽
	local tc=Duel.GetFirstTarget()
	local c=e:GetHandler()
	if c:IsFaceup() and c:IsRelateToEffect(e) and tc and tc:IsFaceup() and tc:IsRelateToEffect(e) then
		-- 效果原文：这张卡的攻击力直到回合结束时变成和作为对象的怪兽的攻击力相同。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_ATTACK_FINAL)
		e1:SetValue(tc:GetAttack())
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		c:RegisterEffect(e1)
	end
end
