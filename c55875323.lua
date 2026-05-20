--でんきトカゲ
-- 效果：
-- 不死族以外的怪兽攻击这张卡的场合，那只怪兽下一个回合不能攻击宣言。
function c55875323.initial_effect(c)
	-- 不死族以外的怪兽攻击这张卡的场合，那只怪兽下一个回合不能攻击宣言。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(55875323,0))  --"攻击限制"
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_BATTLED)
	e1:SetCondition(c55875323.condition)
	e1:SetOperation(c55875323.operation)
	c:RegisterEffect(e1)
end
-- 定义效果发动条件函数
function c55875323.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 判断自身是否为攻击对象，且攻击怪兽的种族不是不死族
	return e:GetHandler()==Duel.GetAttackTarget() and not Duel.GetAttacker():IsRace(RACE_ZOMBIE)
end
-- 定义效果处理函数，使攻击怪兽在下一个回合不能进行攻击宣言
function c55875323.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取进行攻击的怪兽
	local tc=Duel.GetAttacker()
	if tc:IsRelateToBattle() then
		-- 那只怪兽下一个回合不能攻击宣言。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CANNOT_ATTACK)
		-- 将当前回合数作为标签（Label）保存，用于后续判断是否到了下一个回合
		e1:SetLabel(Duel.GetTurnCount())
		e1:SetCondition(c55875323.atkcon)
		e1:SetOwnerPlayer(tp)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END+RESET_OPPO_TURN,2)
		tc:RegisterEffect(e1)
	end
end
-- 定义不能攻击效果的适用条件函数
function c55875323.atkcon(e)
	-- 判断当前回合不是效果发动时的回合，且当前回合玩家是攻击怪兽的控制者（非效果发动者）
	return Duel.GetTurnCount()~=e:GetLabel() and Duel.GetTurnPlayer()~=e:GetOwnerPlayer()
end
