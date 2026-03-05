--ダーク・アサシン
-- 效果：
-- 自己墓地存在的暗属性怪兽数量让这张卡得到以下效果。
-- ●1张以下：这张卡的攻击力下降400。
-- ●2至4张：这张卡的攻击力上升400。
-- ●5张以上：可以把这张卡送去墓地，对方场上里侧表示存在的怪兽全部破坏。
function c19357125.initial_effect(c)
	-- 效果原文内容：自己墓地存在的暗属性怪兽数量让这张卡得到以下效果。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetValue(c19357125.atkval)
	c:RegisterEffect(e1)
	-- 效果原文内容：●5张以上：可以把这张卡送去墓地，对方场上里侧表示存在的怪兽全部破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(19357125,0))  --"破坏"
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(c19357125.condition)
	e2:SetCost(c19357125.cost)
	e2:SetTarget(c19357125.target)
	e2:SetOperation(c19357125.operation)
	c:RegisterEffect(e2)
end
-- 规则层面作用：根据墓地暗属性怪兽数量调整此卡攻击力
function c19357125.atkval(e,c)
	-- 规则层面作用：统计自己墓地暗属性怪兽数量
	local ct=Duel.GetMatchingGroupCount(Card.IsAttribute,c:GetControler(),LOCATION_GRAVE,0,nil,ATTRIBUTE_DARK)
	if ct<=1 then return -400
	elseif ct<=4 then return 400
	else return 0 end
end
-- 规则层面作用：判断是否满足发动条件（墓地至少有5张暗属性怪兽）
function c19357125.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 规则层面作用：检查己方墓地是否存在至少5张暗属性怪兽
	return not e:GetHandler():IsDisabled() and Duel.IsExistingMatchingCard(Card.IsAttribute,tp,LOCATION_GRAVE,0,5,nil,ATTRIBUTE_DARK)
end
-- 规则层面作用：设置发动此效果的费用（解放自身）
function c19357125.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsReleasable() end
	-- 规则层面作用：将自身从场上解放作为费用
	Duel.Release(e:GetHandler(),REASON_COST)
end
-- 规则层面作用：过滤函数，用于筛选里侧表示的怪兽
function c19357125.filter(c)
	return c:IsFacedown()
end
-- 规则层面作用：设置效果的目标为对方场上里侧表示的怪兽
function c19357125.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 规则层面作用：检查对方场上是否存在里侧表示的怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c19357125.filter,tp,0,LOCATION_MZONE,1,nil) end
	-- 规则层面作用：获取对方场上所有里侧表示的怪兽作为目标
	local g=Duel.GetMatchingGroup(c19357125.filter,tp,0,LOCATION_MZONE,nil)
	-- 规则层面作用：设置连锁操作信息，表明将要破坏怪兽
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
end
-- 规则层面作用：执行破坏对方场上里侧表示怪兽的效果
function c19357125.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 规则层面作用：获取对方场上所有里侧表示的怪兽作为破坏对象
	local g=Duel.GetMatchingGroup(c19357125.filter,tp,0,LOCATION_MZONE,nil)
	-- 规则层面作用：将目标怪兽以效果原因破坏
	Duel.Destroy(g,REASON_EFFECT)
end
