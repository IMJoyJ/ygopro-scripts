--真紅眼の凶雷皇－エビル・デーモン
-- 效果：
-- ①：这张卡只要在场上·墓地存在，当作通常怪兽使用。
-- ②：可以把场上的当作通常怪兽使用的这张卡作为通常召唤作再1次召唤。那个场合这张卡变成当作效果怪兽使用并得到以下效果。
-- ●1回合1次，自己主要阶段才能发动。持有比这张卡的攻击力低的守备力的对方场上的表侧表示怪兽全部破坏。
function c39357122.initial_effect(c)
	-- 为卡片添加二重怪兽属性
	aux.EnableDualAttribute(c)
	-- ●1回合1次，自己主要阶段才能发动。持有比这张卡的攻击力低的守备力的对方场上的表侧表示怪兽全部破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	-- 效果的发动条件为该卡处于再度召唤状态
	e1:SetCondition(aux.IsDualState)
	e1:SetTarget(c39357122.destg)
	e1:SetOperation(c39357122.desop)
	c:RegisterEffect(e1)
end
-- 过滤函数，用于筛选对方场上表侧表示且守备力低于指定攻击力的怪兽
function c39357122.filter(c,atk)
	return c:IsFaceup() and c:IsDefenseBelow(atk-1)
end
-- 效果的发动时点处理函数，用于判断是否满足发动条件并设置破坏对象
function c39357122.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	local atk=e:GetHandler():GetAttack()
	-- 判断在对方场上是否存在满足条件的怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c39357122.filter,tp,0,LOCATION_MZONE,1,nil,atk) end
	-- 获取所有满足条件的对方场上表侧表示怪兽
	local g=Duel.GetMatchingGroup(c39357122.filter,tp,0,LOCATION_MZONE,nil,atk)
	-- 设置连锁处理信息，指定将要破坏的怪兽组和数量
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
end
-- 效果的处理函数，执行破坏操作
function c39357122.desop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) or c:IsFacedown() then return end
	local atk=c:GetAttack()
	-- 获取所有满足条件的对方场上表侧表示怪兽
	local g=Duel.GetMatchingGroup(c39357122.filter,tp,0,LOCATION_MZONE,nil,atk)
	-- 将指定怪兽组以效果原因破坏
	Duel.Destroy(g,REASON_EFFECT)
end
