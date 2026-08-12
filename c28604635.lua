--ふるい落とし
-- 效果：
-- 支付500基本分。场上表侧攻击表示存在的全部3星的怪兽破坏。
function c28604635.initial_effect(c)
	-- 支付500基本分。场上表侧攻击表示存在的全部3星的怪兽破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCost(c28604635.cost)
	e1:SetTarget(c28604635.target)
	e1:SetOperation(c28604635.activate)
	c:RegisterEffect(e1)
end
-- 检查玩家是否能支付500基本分
function c28604635.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家是否能支付500基本分
	if chk==0 then return Duel.CheckLPCost(tp,500) end
	-- 让玩家支付500基本分
	Duel.PayLPCost(tp,500)
end
-- 过滤函数，检查是否为表侧攻击表示且等级为3的怪兽
function c28604635.filter(c)
	return c:IsPosition(POS_FACEUP_ATTACK) and c:IsLevel(3)
end
-- 效果发动时的处理，检查场上是否存在满足条件的怪兽并设置操作信息
function c28604635.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查场上是否存在至少1只表侧攻击表示且等级为3的怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c28604635.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 获取场上所有满足条件的怪兽组
	local g=Duel.GetMatchingGroup(c28604635.filter,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	-- 设置连锁操作信息为破坏效果，并指定要破坏的怪兽组
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
end
-- 效果发动时的处理，检索满足条件的怪兽并将其破坏
function c28604635.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取场上所有满足条件的怪兽组
	local g=Duel.GetMatchingGroup(c28604635.filter,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	-- 将满足条件的怪兽组以效果原因进行破坏
	Duel.Destroy(g,REASON_EFFECT)
end
