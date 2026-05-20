--原始太陽ヘリオス
-- 效果：
-- ①：这张卡的攻击力·守备力变成除外状态的怪兽数量×100。
function c54493213.initial_effect(c)
	-- ①：这张卡的攻击力·守备力变成除外状态的怪兽数量×100。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EFFECT_SET_ATTACK)
	e1:SetValue(c54493213.value)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_SET_DEFENSE)
	c:RegisterEffect(e2)
end
-- 过滤除外状态下表侧表示的怪兽
function c54493213.filter(c)
	return c:IsFaceup() and c:IsType(TYPE_MONSTER)
end
-- 计算并返回攻击力·守备力的数值
function c54493213.value(e,c)
	-- 获取双方除外区表侧表示怪兽的数量并乘以100
	return Duel.GetMatchingGroupCount(c54493213.filter,c:GetControler(),LOCATION_REMOVED,LOCATION_REMOVED,nil)*100
end
