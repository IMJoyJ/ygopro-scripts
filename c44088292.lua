--進化合獣ダイオーキシン
-- 效果：
-- ①：这张卡只要在场上·墓地存在，当作通常怪兽使用。
-- ②：可以把场上的当作通常怪兽使用的这张卡作为通常召唤作再1次召唤。那个场合这张卡变成当作效果怪兽使用并得到以下效果。
-- ●只要这张卡在怪兽区域存在，二重怪兽的召唤不会被无效化。
-- ●1回合1次，把自己墓地1只二重怪兽除外，以对方场上1张卡为对象才能发动。那张卡破坏。
function c44088292.initial_effect(c)
	-- 为这张卡附加二重怪兽属性，使其作为二重怪兽处理。
	aux.EnableDualAttribute(c)
	-- ●只要这张卡在怪兽区域存在，二重怪兽的召唤不会被无效化。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_DISABLE_SUMMON)
	e1:SetRange(LOCATION_MZONE)
	e1:SetProperty(EFFECT_FLAG_IGNORE_RANGE+EFFECT_FLAG_SET_AVAILABLE)
	-- 设置该效果仅在“这张卡处于再度召唤状态（当作效果怪兽使用）”时生效。
	e1:SetCondition(aux.IsDualState)
	-- 设置该效果影响的对象：所有二重怪兽（包括自身），使它们的召唤不会被无效化。
	e1:SetTarget(aux.TargetBoolFunction(Card.IsType,TYPE_DUAL))
	c:RegisterEffect(e1)
	-- ●1回合1次，把自己墓地1只二重怪兽除外，以对方场上1张卡为对象才能发动。那张卡破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(44088292,0))
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCountLimit(1)
	e2:SetRange(LOCATION_MZONE)
	-- 设置破坏效果仅在“这张卡处于再度召唤状态”时才能发动。
	e2:SetCondition(aux.IsDualState)
	e2:SetCost(c44088292.cost)
	e2:SetTarget(c44088292.target)
	e2:SetOperation(c44088292.activate)
	c:RegisterEffect(e2)
end
-- 定义代价筛选函数：选择自己墓地中类型为二重怪兽且可以作为代价除外的卡。
function c44088292.costfilter(c)
	return c:IsType(TYPE_DUAL) and c:IsAbleToRemoveAsCost()
end
-- 定义代价处理函数：从自己墓地选择1只二重怪兽除外，作为发动效果的代价。
function c44088292.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 代价确认：检查自己墓地是否存在至少1只满足条件的二重怪兽，若不存在则不能发动。
	if chk==0 then return Duel.IsExistingMatchingCard(c44088292.costfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 显示“请选择要除外的卡”的提示，让玩家选择除外对象。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 玩家从自己墓地选择1只满足条件的二重怪兽。
	local g=Duel.SelectMatchingCard(tp,c44088292.costfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 将选择的卡以表侧表示除外，作为发动代价。
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
-- 定义取对象的目标函数：选择对方场上1张卡作为破坏对象，并登记破坏信息。
function c44088292.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsControler(tp) end
	-- 目标确认：检查对方场上是否存在至少1张可以选择的卡。
	if chk==0 then return Duel.IsExistingTarget(aux.TRUE,tp,0,LOCATION_ONFIELD,1,nil) end
	-- 显示“请选择要破坏的卡”的提示，让玩家选择破坏对象。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 从对方场上选择1张卡作为效果对象（取对象效果）。
	local g=Duel.SelectTarget(tp,aux.TRUE,tp,0,LOCATION_ONFIELD,1,1,nil)
	-- 设置本次效果处理的操作信息为破坏1张卡，供连锁判定等使用。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 定义效果处理函数：在效果处理时，若对象仍与效果相关联，将其破坏。
function c44088292.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取发动时选择的对方场上那张对象卡。
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		-- 将该对象卡破坏（破坏原因为效果破坏）。
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
