--ゴーレム・ドラゴン
-- 效果：
-- 只要这张卡在场上表侧表示存在，对方不能选择表侧表示存在的其他的龙族怪兽作为攻击对象。
function c9666558.initial_effect(c)
	-- 只要这张卡在场上表侧表示存在，对方不能选择表侧表示存在的其他的龙族怪兽作为攻击对象。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SELECT_BATTLE_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(0,LOCATION_MZONE)
	e1:SetValue(c9666558.tg)
	c:RegisterEffect(e1)
end
-- 过滤出自身以外的、表侧表示的龙族怪兽作为不能被选择为攻击对象的目标
function c9666558.tg(e,c)
	return c~=e:GetHandler() and c:IsFaceup() and c:IsRace(RACE_DRAGON)
end
