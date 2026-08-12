--ダークストーム・ドラゴン
-- 效果：
-- ①：这张卡只要在场上·墓地存在，当作通常怪兽使用。
-- ②：可以把场上的当作通常怪兽使用的这张卡作为通常召唤作再1次召唤。那个场合这张卡变成当作效果怪兽使用并得到以下效果。
-- ●1回合1次，把自己场上1张表侧表示的魔法·陷阱卡送去墓地才能发动。场上的魔法·陷阱卡全部破坏。
function c57662975.initial_effect(c)
	-- 为卡片注册二重怪兽的通用属性与再度召唤规则。
	aux.EnableDualAttribute(c)
	-- ●1回合1次，把自己场上1张表侧表示的魔法·陷阱卡送去墓地才能发动。场上的魔法·陷阱卡全部破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetDescription(aux.Stringid(57662975,0))  --"破坏"
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	-- 设置效果发动条件为该卡处于再度召唤后的状态（二重状态）。
	e1:SetCondition(aux.IsDualState)
	e1:SetCost(c57662975.cost)
	e1:SetTarget(c57662975.target)
	e1:SetOperation(c57662975.operation)
	c:RegisterEffect(e1)
end
-- 过滤条件：自己场上表侧表示且能作为代价送去墓地的魔法·陷阱卡。
function c57662975.cfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsAbleToGraveAsCost()
end
-- 效果发动代价的处理：选择自己场上1张表侧表示的魔法·陷阱卡送去墓地。
function c57662975.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 校验阶段：检查自己场上是否存在至少1张符合条件的表侧表示魔法·陷阱卡。
	if chk==0 then return Duel.IsExistingMatchingCard(c57662975.cfilter,tp,LOCATION_ONFIELD,0,1,nil) end
	-- 给发动效果的玩家发送“请选择要送去墓地的卡”的提示信息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 玩家选择自己场上1张符合条件的表侧表示魔法·陷阱卡。
	local g=Duel.SelectMatchingCard(tp,c57662975.cfilter,tp,LOCATION_ONFIELD,0,1,1,nil)
	-- 将选中的卡作为发动代价送去墓地。
	Duel.SendtoGrave(g,REASON_COST)
end
-- 过滤条件：场上的魔法·陷阱卡。
function c57662975.dfilter(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP)
end
-- 效果目标处理：确认场上存在至少2张魔法·陷阱卡，并向系统注册破坏效果的信息。
function c57662975.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 校验阶段：检查场上是否存在至少2张魔法·陷阱卡（确保扣除1张代价后仍有卡可破坏）。
	if chk==0 then return Duel.IsExistingMatchingCard(c57662975.dfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,2,nil) end
	-- 获取双方场上所有的魔法·陷阱卡。
	local g=Duel.GetMatchingGroup(c57662975.dfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
	-- 设置效果处理信息，表明将破坏场上所有的魔法·陷阱卡。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
end
-- 效果运行处理：获取并破坏场上所有的魔法·陷阱卡。
function c57662975.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果处理时双方场上所有的魔法·陷阱卡。
	local g=Duel.GetMatchingGroup(c57662975.dfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
	-- 因效果破坏获取到的所有魔法·陷阱卡。
	Duel.Destroy(g,REASON_EFFECT)
end
