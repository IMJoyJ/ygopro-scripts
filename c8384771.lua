--EMゴムゴムートン
-- 效果：
-- ←1 【灵摆】 1→
-- ①：1回合1次，自己怪兽和对方怪兽进行战斗的攻击宣言时才能发动。那只自己怪兽不会被那次战斗破坏。
-- 【怪兽效果】
-- ①：1回合1次，自己怪兽和对方怪兽进行战斗的攻击宣言时才能发动。那只自己怪兽不会被那次战斗破坏。
function c8384771.initial_effect(c)
	-- 启用灵摆怪兽属性（注册灵摆召唤和灵摆卡的发动效果）
	aux.EnablePendulumAttribute(c)
	-- ①：1回合1次，自己怪兽和对方怪兽进行战斗的攻击宣言时才能发动。那只自己怪兽不会被那次战斗破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_ATTACK_ANNOUNCE)
	e1:SetCountLimit(1)
	e1:SetRange(LOCATION_PZONE)
	e1:SetCondition(c8384771.condition)
	e1:SetTarget(c8384771.target)
	e1:SetOperation(c8384771.operation1)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetRange(LOCATION_MZONE)
	e2:SetOperation(c8384771.operation2)
	c:RegisterEffect(e2)
end
-- 过滤并确认攻击宣言时是自己怪兽与对方怪兽进行战斗，并将己方怪兽记录在效果的标签对象中
function c8384771.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 获取本次战斗的攻击怪兽
	local a=Duel.GetAttacker()
	-- 获取本次战斗的被攻击怪兽
	local d=Duel.GetAttackTarget()
	if not d or a:GetControler()==d:GetControler() then return false end
	if a:IsControler(tp) then e:SetLabelObject(a) else e:SetLabelObject(d) end
	return true
end
-- 效果发动的靶向处理，将进行战斗的己方怪兽设为效果处理的对象
function c8384771.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 将Condition中记录的己方怪兽设置为当前连锁的处理对象
	Duel.SetTargetCard(e:GetLabelObject())
end
-- 灵摆效果处理：使作为对象的己方怪兽在本次战斗中不会被战斗破坏
function c8384771.operation1(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中设定的第一个处理对象（即进行战斗的己方怪兽）
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 那只自己怪兽不会被那次战斗破坏。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
		e1:SetValue(1)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_DAMAGE)
		tc:RegisterEffect(e1)
	end
end
-- 怪兽效果处理：使作为对象的己方怪兽在本次战斗中不会被战斗破坏
function c8384771.operation2(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中设定的第一个处理对象（即进行战斗的己方怪兽）
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 那只自己怪兽不会被那次战斗破坏。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
		e1:SetValue(1)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_DAMAGE)
		tc:RegisterEffect(e1)
	end
end
