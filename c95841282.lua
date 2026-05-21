--ネコ耳族
-- 效果：
-- 对方回合时，与这张卡战斗的怪兽的原本攻击力在伤害步骤时变成200。
function c95841282.initial_effect(c)
	-- 对方回合时，与这张卡战斗的怪兽的原本攻击力在伤害步骤时变成200。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SET_BASE_ATTACK)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(0,LOCATION_MZONE)
	e1:SetTarget(c95841282.atktg)
	e1:SetCondition(c95841282.atkcon)
	e1:SetValue(200)
	c:RegisterEffect(e1)
end
-- 定义效果适用的条件函数：在对方回合的伤害步骤，且这张卡被选为攻击对象时适用
function c95841282.atkcon(e)
	-- 获取当前的游戏阶段
	local ph=Duel.GetCurrentPhase()
	-- 判断当前是否处于伤害步骤或伤害计算时，且当前回合玩家为对方玩家
	return (ph==PHASE_DAMAGE or ph==PHASE_DAMAGE_CAL) and Duel.GetTurnPlayer()~=e:GetHandlerPlayer()
		-- 并且当前被攻击的怪兽是这张卡自身
		and Duel.GetAttackTarget()==e:GetHandler()
end
-- 定义效果影响的目标：与这张卡进行战斗的怪兽
function c95841282.atktg(e,c)
	return c==e:GetHandler():GetBattleTarget()
end
