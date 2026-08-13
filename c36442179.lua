--BF－竜巻のハリケーン
-- 效果：
-- ①：1回合1次，以场上1只同调怪兽为对象才能发动。这张卡的攻击力直到回合结束时变成和作为对象的怪兽的攻击力相同。
function c36442179.initial_effect(c)
	-- ①：1回合1次，以场上1只同调怪兽为对象才能发动。这张卡的攻击力直到回合结束时变成和作为对象的怪兽的攻击力相同。
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
-- 过滤函数：判定卡片是否为表侧表示的同调怪兽，用于选择对象。
function c36442179.filter(c)
	return c:IsFaceup() and c:IsType(TYPE_SYNCHRO)
end
-- 效果发动时的取对象处理：检查对象合法性，并让玩家选择场上的1只表侧表示同调怪兽作为对象。
function c36442179.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(1-tp) and chkc:IsLocation(LOCATION_MZONE) and c36442179.filter(chkc) end
	-- 发动合法性检查：场上存在至少1只符合条件的同调怪兽时才能发动。
	if chk==0 then return Duel.IsExistingTarget(c36442179.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 显示选择卡片的提示消息“请选择表侧表示的卡”。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 让玩家从场上表侧表示的同调怪兽中选择1只作为效果对象。
	Duel.SelectTarget(tp,c36442179.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
end
-- 效果处理：若自身与对象怪兽都仍关联且表侧表示存在，则给自身附加攻击力变为对象怪兽当前攻击力直到回合结束的效果。
function c36442179.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果处理时需要参照的对象怪兽卡。
	local tc=Duel.GetFirstTarget()
	local c=e:GetHandler()
	if c:IsFaceup() and c:IsRelateToEffect(e) and tc and tc:IsFaceup() and tc:IsRelateToEffect(e) then
		-- 这张卡的攻击力直到回合结束时变成和作为对象的怪兽的攻击力相同。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_ATTACK_FINAL)
		e1:SetValue(tc:GetAttack())
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		c:RegisterEffect(e1)
	end
end
