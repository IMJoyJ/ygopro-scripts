--インフェルニティ・ドワーフ
-- 效果：
-- 自己手卡是0张的场合，只要这张卡在自己场上表侧表示存在，自己场上存在的怪兽攻击守备表示怪兽时，若攻击力超过那个守备力，给与对方基本分那个数值的战斗伤害。
function c25171661.initial_effect(c)
	-- 自己手卡是0张的场合，只要这张卡在自己场上表侧表示存在，自己场上存在的怪兽攻击守备表示怪兽时，若攻击力超过那个守备力，给与对方基本分那个数值的战斗伤害。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_PIERCE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetCondition(c25171661.condition)
	c:RegisterEffect(e1)
end
-- 该函数为永续效果的条件函数，用于判断是否满足“自己手卡是0张”这一适用条件，只有条件为真时贯穿伤害效果才生效。
function c25171661.condition(e)
	-- 获取此效果持有者的控制者手牌数量（只计算自己的手牌区域，不包含对方），并判断该数量是否为0；为0时条件成立。
	return Duel.GetFieldGroupCount(e:GetHandler():GetControler(),LOCATION_HAND,0)==0
end
