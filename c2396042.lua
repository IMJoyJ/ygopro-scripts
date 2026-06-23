--ディノンの鋼鉄騎兵
-- 效果：
-- ←5 【灵摆】 5→
-- 【怪兽效果】
-- ①：这张卡和灵摆怪兽进行战斗的伤害步骤开始时发动。这张卡的攻击力·守备力直到伤害步骤结束时变成一半。
function c2396042.initial_effect(c)
	-- 为该卡添加灵摆怪兽属性，使其可以灵摆召唤和灵摆卡的发动
	aux.EnablePendulumAttribute(c)
	-- ①：这张卡和灵摆怪兽进行战斗的伤害步骤开始时发动。这张卡的攻击力·守备力直到伤害步骤结束时变成一半。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(2396042,0))
	e1:SetCategory(CATEGORY_ATKCHANGE+CATEGORY_DEFCHANGE)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_BATTLE_START)
	e1:SetCondition(c2396042.adcon)
	e1:SetOperation(c2396042.adop)
	c:RegisterEffect(e1)
end
-- 判断战斗中的对方怪兽是否为灵摆怪兽（表侧表示）
function c2396042.adcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local bc=c:GetBattleTarget()
	return bc and bc:IsFaceup() and bc:IsType(TYPE_PENDULUM)
end
-- 将自身攻击力和守备力都变为原来的一半
function c2396042.adop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and c:IsFaceup() then
		-- 将自身守备力变为原来的一半
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_DEFENSE_FINAL)
		e1:SetValue(math.ceil(c:GetDefense()/2))
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE+RESET_PHASE+PHASE_DAMAGE)
		c:RegisterEffect(e1)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_SET_ATTACK_FINAL)
		e2:SetValue(math.ceil(c:GetAttack()/2))
		c:RegisterEffect(e2)
	end
end
