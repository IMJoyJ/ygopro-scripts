--炎妖蝶ウィルプス
-- 效果：
-- ①：这张卡只要在场上·墓地存在，当作通常怪兽使用。
-- ②：可以把场上的当作通常怪兽使用的这张卡作为通常召唤作再1次召唤。那个场合这张卡变成当作效果怪兽使用并得到以下效果。
-- ●把这张卡解放，以「炎妖蝶 维尔普斯」以外的自己墓地1只二重怪兽为对象才能发动。那只怪兽特殊召唤。这个效果特殊召唤的怪兽当作再1次召唤的状态使用。
function c16984449.initial_effect(c)
	-- 为卡片添加二重怪兽属性
	aux.EnableDualAttribute(c)
	-- ②：可以把场上的当作通常怪兽使用的这张卡作为通常召唤作再1次召唤。那个场合这张卡变成当作效果怪兽使用并得到以下效果。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetDescription(aux.Stringid(16984449,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_MZONE)
	-- 设置效果的发动条件为二重怪兽处于再度召唤状态
	e1:SetCondition(aux.IsDualState)
	e1:SetCost(c16984449.cost)
	e1:SetTarget(c16984449.target)
	e1:SetOperation(c16984449.operation)
	c:RegisterEffect(e1)
end
-- 费用处理函数，判断是否可以解放自身作为发动费用
function c16984449.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsReleasable() end
	-- 将自身从游戏中解放作为发动费用
	Duel.Release(e:GetHandler(),REASON_COST)
end
-- 筛选函数，用于筛选满足条件的墓地二重怪兽
function c16984449.filter(c,e,sp)
	return c:IsType(TYPE_DUAL) and not c:IsCode(16984449) and c:IsCanBeSpecialSummoned(e,0,sp,false,false)
end
-- 目标选择函数，用于选择符合条件的墓地二重怪兽作为特殊召唤对象
function c16984449.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c16984449.filter(chkc,e,tp) end
	-- 检查场上是否有足够的怪兽区域用于特殊召唤
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>-1
		-- 检查自己墓地是否存在符合条件的二重怪兽
		and Duel.IsExistingTarget(c16984449.filter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 向玩家发送提示信息，提示选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择符合条件的墓地二重怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c16984449.filter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置连锁的操作信息，表明将要特殊召唤一只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 效果处理函数，执行特殊召唤并设置其为再度召唤状态
function c16984449.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的效果对象卡
	local tc=Duel.GetFirstTarget()
	-- 判断对象卡是否仍然存在于场上或墓地，并执行特殊召唤步骤
	if tc:IsRelateToEffect(e) and Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP) then
		tc:EnableDualState()
	end
	-- 完成特殊召唤流程，确保所有特殊召唤步骤都已处理完毕
	Duel.SpecialSummonComplete()
end
