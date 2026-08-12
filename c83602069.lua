--共闘するランドスターの剣士
-- 效果：
-- 只要这张卡在场上表侧表示存在，自己场上表侧表示存在的战士族怪兽的攻击力上升400。
function c83602069.initial_effect(c)
	-- 只要这张卡在场上表侧表示存在，自己场上表侧表示存在的战士族怪兽的攻击力上升400。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	-- 设置效果影响的卡片过滤条件，使其仅适用于战士族怪兽
	e1:SetTarget(aux.TargetBoolFunction(Card.IsRace,RACE_WARRIOR))
	e1:SetValue(400)
	c:RegisterEffect(e1)
end
