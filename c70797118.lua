--雷電娘々
-- 效果：
-- 自己场上存在光属性以外的表侧表示怪兽的场合，表侧表示的这张卡破坏。
function c70797118.initial_effect(c)
	-- 自己场上存在光属性以外的表侧表示怪兽的场合，表侧表示的这张卡破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EFFECT_SELF_DESTROY)
	e1:SetCondition(c70797118.sdcon)
	c:RegisterEffect(e1)
end
-- 定义过滤函数：筛选表侧表示且非光属性的怪兽
function c70797118.sdfilter(c)
	return c:IsFaceup() and c:IsNonAttribute(ATTRIBUTE_LIGHT)
end
-- 定义自我破坏效果的启用条件：自己场上存在符合过滤条件的怪兽
function c70797118.sdcon(e)
	-- 检查自己场上是否存在至少1张表侧表示且非光属性的怪兽
	return Duel.IsExistingMatchingCard(c70797118.sdfilter,e:GetHandlerPlayer(),LOCATION_MZONE,0,1,nil)
end
