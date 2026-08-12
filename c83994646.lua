--死の4つ星てんとう虫
-- 效果：
-- 反转：对方场上表侧表示存在的4星怪兽全部破坏。
function c83994646.initial_effect(c)
	-- 反转：对方场上表侧表示存在的4星怪兽全部破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(83994646,0))
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_FLIP)
	e1:SetTarget(c83994646.target)
	e1:SetOperation(c83994646.operation)
	c:RegisterEffect(e1)
end
-- 过滤对方场上表侧表示且等级为4的怪兽
function c83994646.filter(c)
	return c:IsFaceup() and c:IsLevel(4)
end
-- 效果发动的目标确认，获取并设置要破坏的卡片信息
function c83994646.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 获取对方场上所有表侧表示的4星怪兽
	local g=Duel.GetMatchingGroup(c83994646.filter,tp,0,LOCATION_MZONE,nil)
	-- 设置效果处理信息为破坏获取到的怪兽组
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
end
-- 效果处理的执行，获取并破坏符合条件的怪兽
function c83994646.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前对方场上所有表侧表示的4星怪兽
	local g=Duel.GetMatchingGroup(c83994646.filter,tp,0,LOCATION_MZONE,nil)
	-- 因效果破坏获取到的怪兽组
	Duel.Destroy(g,REASON_EFFECT)
end
