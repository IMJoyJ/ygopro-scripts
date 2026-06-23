--エトワール・サイバー
-- 效果：
-- ①：这张卡直接攻击的伤害步骤内，攻击力上升500。
function c11460577.initial_effect(c)
	-- ①：这张卡直接攻击的伤害步骤内，攻击力上升500。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetCondition(c11460577.condtion)
	e1:SetValue(500)
	c:RegisterEffect(e1)
end
-- 定义条件函数，用于判断效果是否触发
function c11460577.condtion(e)
	-- 获取当前游戏阶段
	local ph=Duel.GetCurrentPhase()
	return (ph==PHASE_DAMAGE or ph==PHASE_DAMAGE_CAL)
		-- 满足当前阶段为伤害步骤且本次攻击的怪兽为效果持有者、且没有攻击目标时触发效果
		and Duel.GetAttacker()==e:GetHandler() and Duel.GetAttackTarget()==nil
end
