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
-- 判断是否满足效果发动条件：攻击怪兽为对方怪兽，且其攻击对象为自己场上的怪兽。
function c37053871.atkcon(e,tp,eg,ep,ev,re,r,rp)
	-- 获取正在进行攻击宣言的怪兽。
	local a=Duel.GetAttacker()
	-- 获取被攻击的怪兽（攻击对象）。
	local at=Duel.GetAttackTarget()
	return a:IsControler(1-tp) and at and at:IsControler(tp)
end
-- 效果发动前的合法性检查函数，确认攻击怪兽能否被改为直接攻击。
function c37053871.atktg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查攻击怪兽是否具有“不能直接攻击”的效果；若没有该效果，则允许发动。
	if chk==0 then return not Duel.GetAttacker():IsHasEffect(EFFECT_CANNOT_DIRECT_ATTACK) end
end
-- 效果处理函数，将本次攻击变更为直接攻击。
function c37053871.atkop(e,tp,eg,ep,ev,re,r,rp)
	-- 将攻击对象设置为nil，使攻击变为对自己基本分的直接攻击。
	Duel.ChangeAttackTarget(nil)
end
