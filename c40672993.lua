--避雷神
-- 效果：
-- ①：只要这张卡在怪兽区域存在，双方在主要阶段1内不能把魔法卡发动。
function c40672993.initial_effect(c)
	-- ①：只要这张卡在怪兽区域存在，自己·对方的主要阶段1内，双方不能把魔法卡发动。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(1,1)
	e1:SetValue(c40672993.actlimit)
	c:RegisterEffect(e1)
end
-- 该函数作为效果的值判定函数，在效果生效时判断玩家当前是否被禁止发动魔法卡：若处于主要阶段1，且对方尝试发动的是魔法卡的发动，则返回 true 禁止其发动。
function c40672993.actlimit(e,te,tp)
	-- 该行判断当前游戏阶段是否为主要阶段1（PHASE_MAIN1），只有处于主要阶段1时才满足避雷神发动的限制条件。
	return Duel.GetCurrentPhase()==PHASE_MAIN1
		and te:IsHasType(EFFECT_TYPE_ACTIVATE) and te:IsActiveType(TYPE_SPELL)
end
