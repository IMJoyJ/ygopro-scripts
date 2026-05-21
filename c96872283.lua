--エヴォルテクター シュバリエ
-- 效果：
-- ①：这张卡只要在场上·墓地存在，当作通常怪兽使用。
-- ②：可以把场上的当作通常怪兽使用的这张卡作为通常召唤作再1次召唤。那个场合这张卡变成当作效果怪兽使用并得到以下效果。
-- ●把自己场上1张表侧表示的装备卡送去墓地，以对方场上1张卡为对象才能发动。那张对方的卡破坏。
function c96872283.initial_effect(c)
	-- 为卡片添加二重怪兽属性，使其在场上·墓地当作通常怪兽，并可再度召唤
	aux.EnableDualAttribute(c)
	-- ●把自己场上1张表侧表示的装备卡送去墓地，以对方场上1张卡为对象才能发动。那张对方的卡破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(96872283,0))  --"破坏"
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	-- 设置效果发动条件为该怪兽处于再度召唤状态（二重状态）
	e1:SetCondition(aux.IsDualState)
	e1:SetCost(c96872283.cost)
	e1:SetTarget(c96872283.target)
	e1:SetOperation(c96872283.operation)
	c:RegisterEffect(e1)
end
-- 过滤自己场上表侧表示且可以作为代价送去墓地的装备卡
function c96872283.costfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_EQUIP) and c:IsAbleToGraveAsCost()
end
-- 效果发动的代价处理：将自己场上1张表侧表示的装备卡送去墓地
function c96872283.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己魔陷区是否存在至少1张满足条件的装备卡
	if chk==0 then return Duel.IsExistingMatchingCard(c96872283.costfilter,tp,LOCATION_SZONE,0,1,nil) end
	-- 提示玩家选择要送去墓地的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 玩家选择1张满足条件的装备卡
	local g=Duel.SelectMatchingCard(tp,c96872283.costfilter,tp,LOCATION_SZONE,0,1,1,nil)
	-- 将选择的卡作为代价送去墓地
	Duel.SendtoGrave(g,REASON_COST)
end
-- 效果的目标选择与发动准备：以对方场上1张卡为对象
function c96872283.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(1-tp) and chkc:IsOnField() end
	-- 检查对方场上是否存在至少1张可以作为对象的卡
	if chk==0 then return Duel.IsExistingTarget(aux.TRUE,tp,0,LOCATION_ONFIELD,1,nil) end
	-- 提示玩家选择要破坏的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 玩家选择对方场上1张卡作为效果的对象
	local g=Duel.SelectTarget(tp,aux.TRUE,tp,0,LOCATION_ONFIELD,1,1,nil)
	-- 设置效果处理信息为破坏选中的1张卡
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 效果处理的执行：破坏作为对象的卡
function c96872283.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中被选为对象的卡片
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		-- 因效果将该卡破坏
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
