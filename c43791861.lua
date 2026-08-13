--鳳王獣ガイルーダ
-- 效果：
-- 这张卡向对方怪兽攻击的场合，伤害步骤内攻击力上升300。
function c43791861.initial_effect(c)
	-- 这张卡向对方怪兽攻击的场合，伤害步骤内攻击力上升300。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetCondition(c43791861.condtion)
	e1:SetValue(300)
	c:RegisterEffect(e1)
end
-- 定义效果适用条件：当前处于伤害步骤或伤害计算时，且此卡是攻击怪兽，并且存在攻击对象（即向对方怪兽攻击）。
function c43791861.condtion(e)
	-- 获取当前游戏阶段，用于判断是否处于伤害步骤或伤害计算时。
	local ph=Duel.GetCurrentPhase()
	return (ph==PHASE_DAMAGE or ph==PHASE_DAMAGE_CAL)
		-- 判定攻击方是否为此效果持有者（本卡），且存在攻击目标，确保效果仅在向对方怪兽攻击时适用。
		and Duel.GetAttacker()==e:GetHandler() and Duel.GetAttackTarget()~=nil
end
