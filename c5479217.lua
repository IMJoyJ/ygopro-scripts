--ジュラック・インパクト
-- 效果：
-- ①：自己场上有攻击力2500以上的恐龙族怪兽存在的场合才能发动。场上的卡全部破坏。
function c5479217.initial_effect(c)
	-- ①：自己场上有攻击力2500以上的恐龙族怪兽存在的场合才能发动。场上的卡全部破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCondition(c5479217.condition)
	e1:SetTarget(c5479217.target)
	e1:SetOperation(c5479217.activate)
	c:RegisterEffect(e1)
end
-- 过滤条件：表侧表示、攻击力2500以上且是恐龙族的怪兽
function c5479217.cfilter(c)
	return c:IsFaceup() and c:IsAttackAbove(2500) and c:IsRace(RACE_DINOSAUR)
end
-- 发动条件：检查自己场上是否存在满足条件的怪兽
function c5479217.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否存在至少1张表侧表示且攻击力2500以上的恐龙族怪兽
	return Duel.IsExistingMatchingCard(c5479217.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
-- 效果发动时的目标选择与处理：检查场上是否有其他卡，并设置破坏的操作信息
function c5479217.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动检测时，检查场上是否存在除这张卡以外的至少1张卡
	if chk==0 then return Duel.IsExistingMatchingCard(aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,e:GetHandler()) end
	-- 获取场上除这张卡以外的所有卡片
	local g=Duel.GetMatchingGroup(aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,e:GetHandler())
	-- 设置操作信息：破坏场上除这张卡以外的所有卡
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
end
-- 效果处理：获取场上除这张卡以外的所有卡并将其全部破坏
function c5479217.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取场上除这张卡（若仍在场上）以外的所有卡片
	local g=Duel.GetMatchingGroup(aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,aux.ExceptThisCard(e))
	-- 因效果破坏获取到的所有卡片
	Duel.Destroy(g,REASON_EFFECT)
end
