--死の合唱
-- 效果：
-- 自己场上有3只「死亡青蛙」表侧表示存在时才能发动。对方场上存在的卡全部破坏。
function c44883830.initial_effect(c)
	-- 效果原文内容：自己场上有3只「死亡青蛙」表侧表示存在时才能发动。对方场上存在的卡全部破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCondition(c44883830.condition)
	e1:SetTarget(c44883830.target)
	e1:SetOperation(c44883830.activate)
	c:RegisterEffect(e1)
end
-- 效果作用：检查一张卡是否为表侧表示的「死亡青蛙」
function c44883830.cfilter(c)
	return c:IsFaceup() and c:IsCode(84451804)
end
-- 效果作用：判断自己场上是否存在3张以上表侧表示的「死亡青蛙」
function c44883830.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 效果作用：判断自己场上是否存在3张以上表侧表示的「死亡青蛙」
	return Duel.IsExistingMatchingCard(c44883830.cfilter,tp,LOCATION_MZONE,0,3,nil)
end
-- 效果作用：设置发动时的处理目标为对方场上存在的所有卡
function c44883830.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 效果作用：判断对方场上是否存在至少1张卡
	if chk==0 then return Duel.IsExistingMatchingCard(aux.TRUE,tp,0,LOCATION_ONFIELD,1,nil) end
	-- 效果作用：获取对方场上存在的所有卡
	local g=Duel.GetMatchingGroup(aux.TRUE,tp,0,LOCATION_ONFIELD,nil)
	-- 效果作用：设置连锁操作信息为破坏效果，目标为对方场上所有卡
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
end
-- 效果作用：对对方场上所有卡进行破坏处理
function c44883830.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 效果作用：获取对方场上存在的所有卡
	local g=Duel.GetMatchingGroup(aux.TRUE,tp,0,LOCATION_ONFIELD,nil)
	-- 效果作用：对目标卡进行破坏
	Duel.Destroy(g,REASON_EFFECT)
end
