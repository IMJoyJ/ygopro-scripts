--神の息吹
-- 效果：
-- 场上表侧表示存在的岩石族怪兽全部破坏。
function c20101223.initial_effect(c)
	-- 效果原文内容：场上表侧表示存在的岩石族怪兽全部破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c20101223.target)
	e1:SetOperation(c20101223.activate)
	c:RegisterEffect(e1)
end
-- 过滤函数，用于判断怪兽是否为岩石族且表侧表示
function c20101223.filter(c)
	return c:IsRace(RACE_ROCK) and c:IsFaceup()
end
-- 效果的发动时点处理函数，检查场上是否存在满足条件的怪兽并设置破坏操作信息
function c20101223.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断在自己的主要怪兽区和对方的主要怪兽区中是否存在至少1只满足条件的怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c20101223.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 获取场上所有满足条件的怪兽组
	local sg=Duel.GetMatchingGroup(c20101223.filter,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	-- 设置当前连锁的操作信息为破坏效果，目标为满足条件的怪兽组
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,sg,sg:GetCount(),0,0)
end
-- 效果的发动处理函数，执行破坏操作
function c20101223.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取场上所有满足条件的怪兽组
	local sg=Duel.GetMatchingGroup(c20101223.filter,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	-- 将满足条件的怪兽组全部破坏
	Duel.Destroy(sg,REASON_EFFECT)
end
