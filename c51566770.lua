--インフェルニティ・ガーディアン
-- 效果：
-- 自己手卡是0张的场合，场上表侧表示存在的这张卡不会被战斗以及卡的效果破坏。
function c51566770.initial_effect(c)
	-- 自己手卡是0张的场合，场上表侧表示存在的这张卡不会被战斗破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(c51566770.condition)
	e1:SetValue(1)
	c:RegisterEffect(e1)
	-- 自己手卡是0张的场合，场上表侧表示存在的这张卡不会被卡的效果破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(c51566770.condition)
	e2:SetValue(1)
	c:RegisterEffect(e2)
end
-- 条件函数：判断这张卡的控制者手牌数是否为0，用于决定是否适用破坏免疫效果。
function c51566770.condition(e)
	-- 获取效果持有者的控制者的手牌区域（LOCATION_HAND）的卡数量，判断其是否为0；若为0则条件成立。
	return Duel.GetFieldGroupCount(e:GetHandler():GetControler(),LOCATION_HAND,0)==0
end
