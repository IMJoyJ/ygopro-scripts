--アーマード・フライ
-- 效果：
-- 自己的场上没有这张卡以外的昆虫族存在，这张卡的攻击力守备力变成1000。
function c42364374.initial_effect(c)
	-- 对应效果原文“这张卡的攻击力守备力变成1000。”中的攻击力部分：创建并注册一个永续效果，使这张卡在满足条件时攻击力变成1000。
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
-- 过滤函数：筛选出表侧表示且种族为昆虫族的怪兽，用于检查场上是否存在这张卡以外的昆虫族。
function c42364374.filter(c)
	return c:IsFaceup() and c:IsRace(RACE_INSECT)
end
-- 条件函数：检测这张卡的控制者自己场上是否不存在满足filter条件、且不是这张卡自身的其他表侧表示昆虫族怪兽。
function c42364374.con(e)
	local c=e:GetHandler()
	-- 检查这张卡的控制者场上（主要怪兽区）是否存在至少1张满足filter且排除自身这张卡的昆虫族怪兽；若不存在则返回true，即满足“自己的场上没有这张卡以外的昆虫族存在”。
	return not Duel.IsExistingMatchingCard(c42364374.filter,c:GetControler(),LOCATION_MZONE,0,1,c)
end
