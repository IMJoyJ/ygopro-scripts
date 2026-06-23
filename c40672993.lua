--避雷神
-- 效果：
-- ①：只要这张卡在怪兽区域存在，双方在主要阶段1内不能把魔法卡发动。
function c40672993.initial_effect(c)
	-- ①：只要这张卡在怪兽区域存在，双方在主要阶段1内不能把魔法卡发动。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(1,1)
	e1:SetValue(c40672993.actlimit)
	c:RegisterEffect(e1)
end
-- 判断是否为魔法卡的发动阶段
function c40672993.actlimit(e,te,tp)
	-- 判断当前阶段是否为主要阶段1
	return Duel.GetCurrentPhase()==PHASE_MAIN1
		and te:IsHasType(EFFECT_TYPE_ACTIVATE) and te:IsActiveType(TYPE_SPELL)
end
