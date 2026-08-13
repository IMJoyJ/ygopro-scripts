--紅蓮魔獣 ダ・イーザ
-- 效果：
-- ①：这张卡的攻击力·守备力变成自己的除外状态的卡数量×400。
function c36584821.initial_effect(c)
	-- ①：这张卡的攻击力·守备力变成自己的除外状态的卡数量×400。（本行实现攻击力部分：创建单卡效果，设为单体永续效果，仅在怪兽区域生效，用value函数设定攻击力数值）
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EFFECT_SET_ATTACK)
	e1:SetValue(c36584821.value)
	c:RegisterEffect(e1)
	-- ①：这张卡的攻击力·守备力变成自己的除外状态的卡数量×400。（本行实现守备力部分：创建单卡效果，设为单体永续效果，仅在怪兽区域生效，用value函数设定守备力数值）
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCode(EFFECT_SET_DEFENSE)
	e2:SetValue(c36584821.value)
	c:RegisterEffect(e2)
end
-- 定义value函数，作为攻击力/守备力的设定值来源：根据效果持有卡（c）的控制者，统计其除外区卡牌数量并乘以400，得到当前攻守数值。
function c36584821.value(e,c)
	-- 获取这张卡当前控制者自己的除外区卡牌数量（LOCATION_REMOVED，对方区域为0），乘以400，作为攻击力/守备力的变化数值。
	return Duel.GetFieldGroupCount(c:GetControler(),LOCATION_REMOVED,0)*400
end
