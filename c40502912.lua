--幻奏の音女アリア
-- 效果：
-- ①：只要特殊召唤的这张卡在怪兽区域存在，自己场上的「幻奏」怪兽不会成为效果的对象，不会被战斗破坏。
function c40502912.initial_effect(c)
	-- ①：只要特殊召唤的这张卡在怪兽区域存在，自己场上的「幻奏」怪兽不会成为效果的对象，不会被战斗破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(LOCATION_MZONE,0)
	-- 设置效果目标为场上自己所有的「幻奏」怪兽
	e1:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,0x9b))
	e1:SetCondition(c40502912.tgcon)
	e1:SetValue(1)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e2:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	c:RegisterEffect(e2)
end
-- 条件函数，判断当前卡是否为特殊召唤方式出场
function c40502912.tgcon(e)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_SPECIAL)
end
