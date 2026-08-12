--アストラルバリア
-- 效果：
-- 对方怪兽攻击自己场上怪兽的场合，可以把那个攻击变成对自己基本分的直接攻击。
function c37053871.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- 对方怪兽攻击自己场上怪兽的场合，可以把那个攻击变成对自己基本分的直接攻击。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(37053871,1))  --"直接攻击"
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_ATTACK_ANNOUNCE)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCondition(c37053871.atkcon)
	e2:SetTarget(c37053871.atktg)
	e2:SetOperation(c37053871.atkop)
	c:RegisterEffect(e2)
end
-- 攻击发动时，攻击怪兽控制者不是自己且攻击目标是自己的场合才能发动
function c37053871.atkcon(e,tp,eg,ep,ev,re,r,rp)
	-- 获取此次战斗的攻击怪兽
	local a=Duel.GetAttacker()
	-- 获取此次战斗的攻击目标怪兽
	local at=Duel.GetAttackTarget()
	return a:IsControler(1-tp) and at and at:IsControler(tp)
end
-- 发动时点，检查攻击怪兽是否能进行直接攻击
function c37053871.atktg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 若攻击怪兽未被无效直接攻击效果影响则可以发动
	if chk==0 then return not Duel.GetAttacker():IsHasEffect(EFFECT_CANNOT_DIRECT_ATTACK) end
end
-- 效果处理，将攻击目标变为基本分
function c37053871.atkop(e,tp,eg,ep,ev,re,r,rp)
	-- 将攻击对象变为基本分，即变为直接攻击
	Duel.ChangeAttackTarget(nil)
end
