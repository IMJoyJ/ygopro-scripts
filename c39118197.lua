--カラクリ武者 六参壱八
-- 效果：
-- 这张卡可以攻击的场合必须作出攻击。场上表侧攻击表示存在的这张卡被选择作为攻击对象时，这张卡的表示形式变成守备表示。场上存在的名字带有「机巧」的怪兽被破坏的场合，这张卡的攻击力上升400。
function c39118197.initial_effect(c)
	-- 这张卡可以攻击的场合必须作出攻击。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_MUST_ATTACK)
	c:RegisterEffect(e1)
	-- 场上表侧攻击表示存在的这张卡被选择作为攻击对象时，这张卡的表示形式变成守备表示。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(39118197,0))  --"变成守备表示"
	e3:SetCategory(CATEGORY_POSITION)
	e3:SetType(EFFECT_TYPE_TRIGGER_F+EFFECT_TYPE_SINGLE)
	e3:SetCode(EVENT_BE_BATTLE_TARGET)
	e3:SetCondition(c39118197.poscon)
	e3:SetOperation(c39118197.posop)
	c:RegisterEffect(e3)
	-- 场上存在的名字带有「机巧」的怪兽被破坏的场合，这张卡的攻击力上升400。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(39118197,1))  --"攻击上升"
	e4:SetType(EFFECT_TYPE_TRIGGER_F+EFFECT_TYPE_FIELD)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCategory(CATEGORY_ATKCHANGE)
	e4:SetCode(EVENT_DESTROYED)
	e4:SetCondition(c39118197.atkcon)
	e4:SetOperation(c39118197.atkop)
	c:RegisterEffect(e4)
end
-- 判断条件：自身处于攻击表示时才触发此效果（对应“场上表侧攻击表示存在的这张卡”的限制）。
function c39118197.poscon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsAttackPos()
end
-- 效果处理：将这张卡变为表侧守备表示。
function c39118197.posop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsFaceup() and c:IsRelateToEffect(e) then
		-- 将此卡的表示形式变更为表侧守备表示。
		Duel.ChangePosition(c,POS_FACEUP_DEFENSE)
	end
end
-- 过滤条件：被破坏的怪兽在破坏前位于怪兽区域、表侧表示，且卡名含有「机巧」字段（0x11）。
function c39118197.filter(c)
	return c:IsPreviousLocation(LOCATION_MZONE) and c:IsPreviousPosition(POS_FACEUP) and c:IsPreviousSetCard(0x11)
end
-- 诱发条件：本次被破坏的怪兽集合中存在至少1只满足filter条件的「机巧」怪兽。
function c39118197.atkcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c39118197.filter,1,nil)
end
-- 处理效果：若这张卡仍与效果相关且表侧表示，则使其攻击力上升400，并设置该增益的复位条件（离场、无效等时失效）。
function c39118197.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and c:IsFaceup() then
		-- 这张卡的攻击力上升400。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE)
		e1:SetValue(400)
		c:RegisterEffect(e1)
	end
end
