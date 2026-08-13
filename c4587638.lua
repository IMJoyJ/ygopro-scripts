--吠え猛る大地
-- 效果：
-- 自己场上在的兽族怪兽向守备表示怪兽攻击时，若攻击力超过那个守备力，给与对方基本分那个数值的战斗伤害。这个效果适用给与对方基本分战斗伤害时，对方场上表侧表示存在的1只怪兽的攻击力·守备力下降500。
function c4587638.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- 自己场上在的兽族怪兽向守备表示怪兽攻击时，若攻击力超过那个守备力，给与对方基本分那个数值的战斗伤害。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_PIERCE)
	e2:SetRange(LOCATION_SZONE)
	e2:SetTargetRange(LOCATION_MZONE,0)
	-- 筛选我方场上的兽族怪兽作为该贯穿效果的适用对象。
	e2:SetTarget(aux.TargetBoolFunction(Card.IsRace,RACE_BEAST))
	c:RegisterEffect(e2)
	-- 这个效果适用给与对方基本分战斗伤害时，对方场上表侧表示存在的1只怪兽的攻击力·守备力下降500。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(4587638,0))  --"攻守下降"
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetCode(EVENT_BATTLE_DAMAGE)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCondition(c4587638.atkcon)
	e3:SetTarget(c4587638.atktg)
	e3:SetOperation(c4587638.atkop)
	c:RegisterEffect(e3)
end
-- 战斗伤害发生时，判定造成伤害的攻击怪兽是否为己方兽族怪兽且被攻击怪兽为守备表示。
function c4587638.atkcon(e,tp,eg,ep,ev,re,r,rp)
	-- 获取进行战斗的攻击怪兽。
	local a=Duel.GetAttacker()
	-- 获取被攻击的怪兽（攻击对象）。
	local d=Duel.GetAttackTarget()
	return d and eg:GetFirst()==a and a:IsControler(tp) and a:IsRace(RACE_BEAST) and d:IsDefensePos()
end
-- 取对象效果的目标选择：从对方场上选择1只表侧表示怪兽作为攻守下降的对象。
function c4587638.atktg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and chkc:IsFaceup() end
	if chk==0 then return true end
	-- 弹出选择提示消息，提示玩家选择1只表侧表示的怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 让玩家从对方场上选择1只表侧表示怪兽，并将其设为效果对象。
	Duel.SelectTarget(tp,Card.IsFaceup,tp,0,LOCATION_MZONE,1,1,nil)
end
-- 效果处理：若发动卡和对象怪兽仍与效果相关且对象表侧表示，则使其攻击力、守备力各下降500。
function c4587638.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取效果处理时选择的对象怪兽。
	local tc=Duel.GetFirstTarget()
	if c:IsRelateToEffect(e) and tc and tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 攻击力下降500。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(-500)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_UPDATE_DEFENSE)
		tc:RegisterEffect(e2)
	end
end
