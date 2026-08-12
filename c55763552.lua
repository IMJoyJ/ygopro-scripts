--壺魔人
-- 效果：
-- 反转：场上表侧表示的「龙族封印之壶」破坏。破坏时，场上表侧表示存在的龙族怪兽全部攻击表示。
function c55763552.initial_effect(c)
	-- 反转：场上表侧表示的「龙族封印之壶」破坏。破坏时，场上表侧表示存在的龙族怪兽全部攻击表示。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(55763552,0))  --"破坏"
	e1:SetCategory(CATEGORY_DESTROY+CATEGORY_POSITION)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_FLIP)
	e1:SetTarget(c55763552.target)
	e1:SetOperation(c55763552.operation)
	c:RegisterEffect(e1)
end
-- 过滤场上表侧表示的「龙族封印之壶」
function c55763552.filter(c)
	return c:IsFaceup() and c:IsCode(50045299)
end
-- 反转效果的发动准备与目标确认
function c55763552.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 获取双方魔法与陷阱区域表侧表示的「龙族封印之壶」
	local g=Duel.GetMatchingGroup(c55763552.filter,tp,LOCATION_SZONE,LOCATION_SZONE,nil)
	-- 设置破坏操作的信息，包含要破坏的卡片组及数量
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
end
-- 过滤场上表侧守备表示的龙族怪兽
function c55763552.pfilter(c)
	return c:IsPosition(POS_FACEUP_DEFENSE) and c:IsRace(RACE_DRAGON)
end
-- 反转效果的处理：破坏「龙族封印之壶」并改变龙族怪兽的表示形式
function c55763552.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取场上所有表侧表示的「龙族封印之壶」
	local g=Duel.GetMatchingGroup(c55763552.filter,tp,LOCATION_SZONE,LOCATION_SZONE,nil)
	-- 破坏这些卡，并判断是否成功破坏了至少1张卡
	if Duel.Destroy(g,REASON_EFFECT)>0 then
		-- 获取双方怪兽区域表侧守备表示的龙族怪兽
		local pg=Duel.GetMatchingGroup(c55763552.pfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
		-- 将这些龙族怪兽全部变为表侧攻击表示
		Duel.ChangePosition(pg,POS_FACEUP_ATTACK)
	end
end
