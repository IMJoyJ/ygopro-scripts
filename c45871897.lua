--ロストガーディアン
-- 效果：
-- 这张卡原本的守备力，是自己除外的岩石族怪兽数×700。
function c45871897.initial_effect(c)
	-- 这张卡原本的守备力，是自己除外的岩石族怪兽数×700。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SET_BASE_DEFENSE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetValue(c45871897.defval)
	c:RegisterEffect(e1)
end
-- 过滤函数，筛选出表侧表示且种族为岩石族的怪兽。
function c45871897.filter(c)
	return c:IsFaceup() and c:IsRace(RACE_ROCK)
end
-- 定义原本守备力的数值计算方式：统计自己除外区的岩石族怪兽数量并乘以700。
function c45871897.defval(e,c)
	-- 返回自己除外区表侧表示岩石族怪兽数量乘以700的数值，作为这张卡的原本守备力。
	return Duel.GetMatchingGroupCount(c45871897.filter,c:GetControler(),LOCATION_REMOVED,0,nil)*700
end
