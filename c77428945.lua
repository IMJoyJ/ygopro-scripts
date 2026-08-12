--土地鋸
-- 效果：
-- 这张卡特殊召唤成功时，这张卡以外的场上的特殊召唤的怪兽全部变成里侧守备表示。「土地锯」的效果1回合只能使用1次。
function c77428945.initial_effect(c)
	-- 这张卡特殊召唤成功时，这张卡以外的场上的特殊召唤的怪兽全部变成里侧守备表示。「土地锯」的效果1回合只能使用1次。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(77428945,0))  --"变成里侧守备"
	e1:SetCategory(CATEGORY_POSITION+CATEGORY_MSET)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCountLimit(1,77428945)
	e1:SetTarget(c77428945.target)
	e1:SetOperation(c77428945.operation)
	c:RegisterEffect(e1)
end
-- 过滤函数：筛选场上表侧表示、可以转为里侧表示且是特殊召唤的怪兽
function c77428945.filter(c)
	return c:IsFaceup() and c:IsCanTurnSet() and c:IsSummonType(SUMMON_TYPE_SPECIAL)
end
-- 效果发动的目标确认与操作信息设置（必发效果，直接返回true）
function c77428945.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 获取场上除这张卡以外的所有满足过滤条件的怪兽组
	local g=Duel.GetMatchingGroup(c77428945.filter,tp,LOCATION_MZONE,LOCATION_MZONE,e:GetHandler())
	-- 设置操作信息为改变表示形式，涉及卡片为获取到的怪兽组
	Duel.SetOperationInfo(0,CATEGORY_POSITION,g,g:GetCount(),0,0)
end
-- 效果处理的执行函数，将符合条件的怪兽全部变成里侧守备表示
function c77428945.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前场上除这张卡以外的所有满足过滤条件的怪兽组（使用aux.ExceptThisCard排除自身）
	local g=Duel.GetMatchingGroup(c77428945.filter,tp,LOCATION_MZONE,LOCATION_MZONE,aux.ExceptThisCard(e))
	-- 将目标怪兽组中的所有怪兽改变为里侧守备表示
	Duel.ChangePosition(g,POS_FACEDOWN_DEFENSE)
end
