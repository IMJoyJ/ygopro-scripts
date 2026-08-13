--ダッシュ・ウォリアー
-- 效果：
-- 这张卡攻击的场合，伤害步骤内这张卡的攻击力上升1200。
function c34257001.initial_effect(c)
	-- 这张卡攻击的场合，伤害步骤内这张卡的攻击力上升1200。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetCondition(c34257001.condtion)
	e1:SetValue(1200)
	c:RegisterEffect(e1)
end
-- 判定当前阶段是否为伤害步骤或伤害计算时，且攻击怪兽为效果持有者自身，以此作为攻击力上升效果适用的条件。
function c34257001.condtion(e)
	-- 获取当前游戏阶段并保存到局部变量ph。
	local ph=Duel.GetCurrentPhase()
	return (ph==PHASE_DAMAGE or ph==PHASE_DAMAGE_CAL)
		-- 判断当前攻击怪兽是否为效果持有者（即此卡自己）。
		and Duel.GetAttacker()==e:GetHandler()
end
