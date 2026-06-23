--リボーン・ゾンビ
-- 效果：
-- 只要自己手卡是0张，场上攻击表示存在的这张卡不会被战斗破坏。
function c23421244.initial_effect(c)
	-- 只要自己手卡是0张，场上攻击表示存在的这张卡不会被战斗破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(c23421244.condition)
	e1:SetValue(1)
	c:RegisterEffect(e1)
end
-- 检查当前怪兽是否在攻击表示且自己手卡数量为0
function c23421244.condition(e)
	-- 返回当前怪兽是否在攻击表示且自己手卡数量为0
	return e:GetHandler():IsAttackPos() and Duel.GetFieldGroupCount(e:GetHandlerPlayer(),LOCATION_HAND,0)==0
end
