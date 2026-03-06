--先史遺産マヤン・マシーン
-- 效果：
-- 机械族怪兽上级召唤的场合，这张卡可以作为2只的数量解放。
function c25163248.initial_effect(c)
	-- 机械族怪兽上级召唤的场合，这张卡可以作为2只的数量解放。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_DOUBLE_TRIBUTE)
	e1:SetValue(c25163248.condition)
	c:RegisterEffect(e1)
end
-- 检查触发效果的怪兽是否为机械族
function c25163248.condition(e,c)
	return c:IsRace(RACE_MACHINE)
end
