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
-- 判断是否处于伤害步骤或伤害计算时，并且当前卡是攻击怪兽
function c34257001.condtion(e)
	-- 获取当前游戏阶段
	local ph=Duel.GetCurrentPhase()
	return (ph==PHASE_DAMAGE or ph==PHASE_DAMAGE_CAL)
		-- 判断攻击怪兽是否为当前效果所属的卡
		and Duel.GetAttacker()==e:GetHandler()
end
