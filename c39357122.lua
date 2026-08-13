--真紅眼の凶雷皇－エビル・デーモン
-- 效果：
-- ①：这张卡只要在场上·墓地存在，当作通常怪兽使用。
-- ②：可以把场上的当作通常怪兽使用的这张卡作为通常召唤作再1次召唤。那个场合这张卡变成当作效果怪兽使用并得到以下效果。
-- ●1回合1次，自己主要阶段才能发动。持有比这张卡的攻击力低的守备力的对方场上的表侧表示怪兽全部破坏。
function c39357122.initial_effect(c)
	-- 调用aux函数为这张卡添加二重怪兽标识，使其在场上·墓地作为通常怪兽使用，并可进行二重召唤的再召唤处理。
	aux.EnableDualAttribute(c)
	-- ●1回合1次，自己主要阶段才能发动。持有比这张卡的攻击力低的守备力的对方场上的表侧表示怪兽全部破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	-- 设置效果的发动条件为：这张卡处于二重怪兽的再度召唤状态（即当作效果怪兽使用）时才能发动。
	e1:SetCondition(aux.IsDualState)
	e1:SetTarget(c39357122.destg)
	e1:SetOperation(c39357122.desop)
	c:RegisterEffect(e1)
end
-- 定义筛选函数：选取对方场上表侧表示且守备力小于这张卡当前攻击力（即守备力≤攻击力-1）的怪兽。
function c39357122.filter(c,atk)
	return c:IsFaceup() and c:IsDefenseBelow(atk-1)
end
-- 目标设定函数：chk==0时检查对方场上是否存在至少1只满足条件的表侧怪兽；chk>0时获取所有满足条件的怪兽并登记破坏操作信息。
function c39357122.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	local atk=e:GetHandler():GetAttack()
	-- 发动合法性检查：对方场上是否存在至少1只表侧表示且守备力低于这张卡当前攻击力的怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(c39357122.filter,tp,0,LOCATION_MZONE,1,nil,atk) end
	-- 获取对方场上所有满足条件（表侧表示且守备力低于当前攻击力）的怪兽，作为后续破坏所涉及的对象集合。
	local g=Duel.GetMatchingGroup(c39357122.filter,tp,0,LOCATION_MZONE,nil,atk)
	-- 将本次要破坏的怪兽集合g及其数量登记到操作信息中（属于不取对象的全体破坏），用于星尘龙等卡的连锁检测。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
end
-- 效果处理函数：先确认发动效果的这张卡仍在场上且表侧表示，再重新获取当前所有符合条件的对方怪兽并全部破坏。
function c39357122.desop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) or c:IsFacedown() then return end
	local atk=c:GetAttack()
	-- 效果处理时重新获取对方场上满足条件的表侧怪兽，因为这张卡的攻击力可能发生变化，需要以当前攻击力重新筛选。
	local g=Duel.GetMatchingGroup(c39357122.filter,tp,0,LOCATION_MZONE,nil,atk)
	-- 以效果原因（REASON_EFFECT）将这些怪兽全部破坏。
	Duel.Destroy(g,REASON_EFFECT)
end
