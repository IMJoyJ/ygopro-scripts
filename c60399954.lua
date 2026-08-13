--ユニオン・アタック
-- 效果：
-- ①：以自己场上1只表侧表示怪兽为对象才能发动。这个回合的战斗阶段开始时，那只怪兽的攻击力直到战斗阶段结束时上升其他的自己场上的攻击表示怪兽的攻击力的合计数值。这个回合，作为对象的怪兽给与对方的战斗伤害变成0，其他的自己怪兽不能攻击。
function c60399954.initial_effect(c)
	-- ①：以自己场上1只表侧表示怪兽为对象才能发动。这个回合的战斗阶段开始时，那只怪兽的攻击力直到战斗阶段结束时上升其他的自己场上的攻击表示怪兽的攻击力的合计数值。这个回合，作为对象的怪兽给与对方的战斗伤害变成0，其他的自己怪兽不能攻击。
	local e1=Effect.CreateEffect(c)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCondition(c60399954.condition)
	e1:SetTarget(c60399954.target)
	e1:SetOperation(c60399954.operation)
	c:RegisterEffect(e1)
end
-- 发动条件：只能在主要阶段1（PHASE_MAIN1）发动。
function c60399954.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 判定当前阶段是否为主要阶段1；为真时满足发动条件。
	return Duel.GetCurrentPhase()==PHASE_MAIN1
end
-- 选择对象：从自己场上表侧表示怪兽中选择1只为对象；同时设定誓约效果，使对象以外的自己怪兽本回合不能攻击。
function c60399954.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and chkc:IsFaceup() end
	-- 合法性检查：确认自己场上是否存在至少1只表侧表示怪兽可以作为对象。
	if chk==0 then return Duel.IsExistingTarget(Card.IsFaceup,tp,LOCATION_MZONE,0,1,nil) end
	-- 向玩家发送“请选择表侧表示的卡”的提示消息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择1只自己场上的表侧表示怪兽作为本卡效果的对象。
	local g=Duel.SelectTarget(tp,Card.IsFaceup,tp,LOCATION_MZONE,0,1,1,nil)
	-- 这个回合，其他的自己怪兽不能攻击。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_ATTACK)
	e1:SetProperty(EFFECT_FLAG_OATH+EFFECT_FLAG_IGNORE_IMMUNE)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetTarget(c60399954.ftarget)
	e1:SetLabel(g:GetFirst():GetFieldID())
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将“其他自己怪兽不能攻击”的誓约效果注册到全局，使其本回合持续适用。
	Duel.RegisterEffect(e1,tp)
end
-- 效果处理：给对象怪兽注册在战斗阶段开始时上升攻击力的效果，以及本回合战斗伤害变成0的效果。
function c60399954.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 取得本卡选择的1只对象怪兽。
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) then
		-- 这个回合的战斗阶段开始时，那只怪兽的攻击力直到战斗阶段结束时上升其他的自己场上的攻击表示怪兽的攻击力的合计数值。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_PHASE+PHASE_BATTLE_START)
		e1:SetRange(LOCATION_MZONE)
		e1:SetCountLimit(1)
		e1:SetOperation(c60399954.atkop)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
		-- 这个回合，作为对象的怪兽给与对方的战斗伤害变成0。
		local e2=Effect.CreateEffect(e:GetHandler())
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_NO_BATTLE_DAMAGE)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e2)
	end
end
-- 用于“不能攻击”限制的目标判定：排除被选中的对象，使其他自己怪兽成为不能攻击限制的对象。
function c60399954.ftarget(e,c)
	return e:GetLabel()~=c:GetFieldID()
end
-- 战斗阶段开始时，计算对象以外的自己场上表侧攻击表示怪兽的攻击力合计值，并让对象怪兽的攻击力上升该数值，直到战斗阶段结束。
function c60399954.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local atk=0
	-- 取得对象怪兽以外的、自己场上表侧攻击表示的所有怪兽。
	local g=Duel.GetMatchingGroup(Card.IsPosition,tp,LOCATION_MZONE,0,c,POS_FACEUP_ATTACK)
	local tc=g:GetFirst()
	while tc do
		atk=atk+tc:GetAttack()
		tc=g:GetNext()
	end
	-- 那只怪兽的攻击力直到战斗阶段结束时上升其他的自己场上的攻击表示怪兽的攻击力的合计数值。
	local e1=Effect.CreateEffect(e:GetOwner())
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetValue(atk)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_BATTLE)
	c:RegisterEffect(e1)
end
