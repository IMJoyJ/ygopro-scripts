--プライドの咆哮
-- 效果：
-- 战斗伤害计算时，自己怪兽的攻击力比对方怪兽低的场合，支付那个攻击力差的数值的基本分发动。只在伤害计算时，自己怪兽的攻击力上升和对方怪兽的攻击力差的数值＋300。
function c66518841.initial_effect(c)
	-- 战斗伤害计算时，自己怪兽的攻击力比对方怪兽低的场合，支付那个攻击力差的数值的基本分发动。只在伤害计算时，自己怪兽的攻击力上升和对方怪兽的攻击力差的数值＋300。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_PRE_DAMAGE_CALCULATE)
	e1:SetCondition(c66518841.condition)
	e1:SetCost(c66518841.cost)
	e1:SetOperation(c66518841.activate)
	c:RegisterEffect(e1)
end
-- 判断是否满足发动条件：在伤害计算时，自己怪兽的攻击力低于对方怪兽，并保存攻击力差值
function c66518841.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前的攻击怪兽
	local tc=Duel.GetAttacker()
	-- 如果攻击怪兽是对方的，则将我方的被攻击怪兽作为目标怪兽
	if tc:IsControler(1-tp) then tc=Duel.GetAttackTarget() end
	if not tc then return false end
	local bc=tc:GetBattleTarget()
	if tc and bc then
		local dif=bc:GetAttack()-tc:GetAttack()
		e:SetLabel(dif)
		return dif>0
	else return false end
end
-- 检查并支付发动代价
function c66518841.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在效果发动准备阶段，检查玩家是否能够支付等同于攻击力差值的基本分
	if chk==0 then return Duel.CheckLPCost(tp,e:GetLabel()) end
	-- 支付等同于攻击力差值的基本分
	Duel.PayLPCost(tp,e:GetLabel())
end
-- 执行效果处理：在满足条件时，使我方怪兽的攻击力上升差值+300
function c66518841.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前的攻击怪兽
	local tc=Duel.GetAttacker()
	-- 如果攻击怪兽是对方的，则将我方的被攻击怪兽作为目标怪兽
	if tc:IsControler(1-tp) then tc=Duel.GetAttackTarget() end
	local bc=tc:GetBattleTarget()
	local dif=bc:GetAttack()-tc:GetAttack()
	if dif>0 and tc:IsRelateToBattle() and bc:IsRelateToBattle() and tc:IsFaceup() and bc:IsFaceup() then
		-- 只在伤害计算时，自己怪兽的攻击力上升和对方怪兽的攻击力差的数值＋300。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_DAMAGE_CAL)
		e1:SetValue(dif+300)
		tc:RegisterEffect(e1)
	end
end
