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
-- 判断是否处于伤害步骤或伤害计算步骤，并且当前卡是攻击怪兽且有攻击目标
function c43791861.condtion(e)
	-- 获取当前游戏阶段
	local ph=Duel.GetCurrentPhase()
	return (ph==PHASE_DAMAGE or ph==PHASE_DAMAGE_CAL)
		-- 判断攻击怪兽为当前卡且攻击目标不为空
		and Duel.GetAttacker()==e:GetHandler() and Duel.GetAttackTarget()~=nil
end
