--トラファスフィア
-- 效果：
-- 这张卡上级召唤的场合，解放的怪兽必须是鸟兽族怪兽。这张卡只要在场上表侧表示存在不受陷阱卡的效果影响。
function c72144675.initial_effect(c)
	-- 这张卡上级召唤的场合，解放的怪兽必须是鸟兽族怪兽。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_TRIBUTE_LIMIT)
	e1:SetValue(c72144675.tlimit)
	c:RegisterEffect(e1)
	-- 这张卡只要在场上表侧表示存在不受陷阱卡的效果影响。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCode(EFFECT_IMMUNE_EFFECT)
	e2:SetValue(c72144675.efilter)
	c:RegisterEffect(e2)
end
-- 限制不能解放非鸟兽族的怪兽来进行这张卡的上级召唤
function c72144675.tlimit(e,c)
	return not c:IsRace(RACE_WINDBEAST)
end
-- 过滤出陷阱卡的效果，使这张卡不受其影响
function c72144675.efilter(e,te)
	return te:IsActiveType(TYPE_TRAP)
end
