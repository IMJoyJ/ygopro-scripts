--ゼンマイナイト
-- 效果：
-- 自己场上表侧表示存在的名字带有「发条」的怪兽被选择作为攻击对象时，可以把那只怪兽的攻击无效。这个效果只在这张卡在场上表侧表示存在能使用1次。
function c80538728.initial_effect(c)
	-- 自己场上表侧表示存在的名字带有「发条」的怪兽被选择作为攻击对象时，可以把那只怪兽的攻击无效。这个效果只在这张卡在场上表侧表示存在能使用1次。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(80538728,0))  --"攻击无效"
	e1:SetProperty(EFFECT_FLAG_NO_TURN_RESET)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_BE_BATTLE_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCondition(c80538728.condition)
	e1:SetOperation(c80538728.operation)
	c:RegisterEffect(e1)
end
-- 判断被选择作为攻击对象的怪兽是否为自己场上表侧表示的名字带有「发条」的怪兽
function c80538728.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前的攻击对象怪兽
	local d=Duel.GetAttackTarget()
	return d and d:IsControler(tp) and d:IsFaceup() and d:IsSetCard(0x58)
end
-- 无效攻击的效果处理
function c80538728.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 使当前的攻击无效
	Duel.NegateAttack()
end
