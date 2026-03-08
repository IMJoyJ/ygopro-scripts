--アーマード・フライ
-- 效果：
-- 自己的场上没有这张卡以外的昆虫族存在，这张卡的攻击力守备力变成1000。
function c42364374.initial_effect(c)
	-- 自己的场上没有这张卡以外的昆虫族存在，这张卡的攻击力守备力变成1000。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EFFECT_SET_ATTACK)
	e1:SetValue(1000)
	e1:SetCondition(c42364374.con)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_SET_DEFENSE)
	c:RegisterEffect(e2)
end
-- 过滤函数，用于检查场上是否存在表侧表示的昆虫族怪兽
function c42364374.filter(c)
	return c:IsFaceup() and c:IsRace(RACE_INSECT)
end
-- 条件函数，判断是否满足效果发动条件（场上没有其他昆虫族怪兽）
function c42364374.con(e)
	local c=e:GetHandler()
	-- 检查以当前控制者来看，场上是否存在至少1张满足filter条件的怪兽
	return not Duel.IsExistingMatchingCard(c42364374.filter,c:GetControler(),LOCATION_MZONE,0,1,c)
end
