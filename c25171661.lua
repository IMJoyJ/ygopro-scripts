--インフェルニティ・ドワーフ
-- 效果：
-- 自己手卡是0张的场合，只要这张卡在自己场上表侧表示存在，自己场上存在的怪兽攻击守备表示怪兽时，若攻击力超过那个守备力，给与对方基本分那个数值的战斗伤害。
function c25171661.initial_effect(c)
	-- 效果原文内容：自己手卡是0张的场合，只要这张卡在自己场上表侧表示存在，自己场上存在的怪兽攻击守备表示怪兽时，若攻击力超过那个守备力，给与对方基本分那个数值的战斗伤害。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_PIERCE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetCondition(c25171661.condition)
	c:RegisterEffect(e1)
end
-- 条件函数判断：当自己手卡数量为0时效果才生效
function c25171661.condition(e)
	-- 检索当前控制者手卡数量是否为0
	return Duel.GetFieldGroupCount(e:GetHandler():GetControler(),LOCATION_HAND,0)==0
end
