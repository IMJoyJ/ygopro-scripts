--進化合獣ダイオーキシン
-- 效果：
-- ①：这张卡只要在场上·墓地存在，当作通常怪兽使用。
-- ②：可以把场上的当作通常怪兽使用的这张卡作为通常召唤作再1次召唤。那个场合这张卡变成当作效果怪兽使用并得到以下效果。
-- ●只要这张卡在怪兽区域存在，二重怪兽的召唤不会被无效化。
-- ●1回合1次，把自己墓地1只二重怪兽除外，以对方场上1张卡为对象才能发动。那张卡破坏。
function c44088292.initial_effect(c)
	-- 为卡片添加二重怪兽属性
	aux.EnableDualAttribute(c)
	-- 只要这张卡在怪兽区域存在，二重怪兽的召唤不会被无效化。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_DISABLE_SUMMON)
	e1:SetRange(LOCATION_MZONE)
	e1:SetProperty(EFFECT_FLAG_IGNORE_RANGE+EFFECT_FLAG_SET_AVAILABLE)
	-- 效果适用条件为二重怪兽再度召唤状态
	e1:SetCondition(aux.IsDualState)
	-- 效果适用对象为二重怪兽
	e1:SetTarget(aux.TargetBoolFunction(Card.IsType,TYPE_DUAL))
	c:RegisterEffect(e1)
	-- 1回合1次，把自己墓地1只二重怪兽除外，以对方场上1张卡为对象才能发动。那张卡破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(44088292,0))
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCountLimit(1)
	e2:SetRange(LOCATION_MZONE)
	-- 效果适用条件为二重怪兽再度召唤状态
	e2:SetCondition(aux.IsDualState)
	e2:SetCost(c44088292.cost)
	e2:SetTarget(c44088292.target)
	e2:SetOperation(c44088292.activate)
	c:RegisterEffect(e2)
end
-- 费用支付所需满足的条件：墓地存在1只二重怪兽且可作为除外费用
function c44088292.costfilter(c)
	return c:IsType(TYPE_DUAL) and c:IsAbleToRemoveAsCost()
end
-- 支付费用时选择并除外1只满足条件的墓地二重怪兽
function c44088292.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否满足支付费用的条件
	if chk==0 then return Duel.IsExistingMatchingCard(c44088292.costfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 提示玩家选择要除外的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 选择满足条件的墓地1只二重怪兽
	local g=Duel.SelectMatchingCard(tp,c44088292.costfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 将选中的卡除外作为费用
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
-- 选择破坏对象：对方场上的1张卡
function c44088292.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsControler(tp) end
	-- 检查是否满足选择破坏对象的条件
	if chk==0 then return Duel.IsExistingTarget(aux.TRUE,tp,0,LOCATION_ONFIELD,1,nil) end
	-- 提示玩家选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择对方场上的1张卡作为破坏对象
	local g=Duel.SelectTarget(tp,aux.TRUE,tp,0,LOCATION_ONFIELD,1,1,nil)
	-- 设置连锁操作信息，确定破坏效果的处理对象
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 执行破坏效果，将选中的卡破坏
function c44088292.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的破坏对象
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		-- 将目标卡破坏
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
