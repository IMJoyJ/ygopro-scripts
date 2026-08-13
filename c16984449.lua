--炎妖蝶ウィルプス
-- 效果：
-- ①：这张卡只要在场上·墓地存在，当作通常怪兽使用。
-- ②：可以把场上的当作通常怪兽使用的这张卡作为通常召唤作再1次召唤。那个场合这张卡变成当作效果怪兽使用并得到以下效果。
-- ●把这张卡解放，以「炎妖蝶 维尔普斯」以外的自己墓地1只二重怪兽为对象才能发动。那只怪兽特殊召唤。这个效果特殊召唤的怪兽当作再1次召唤的状态使用。
function c16984449.initial_effect(c)
	-- 为这张卡赋予二重怪兽属性，使其在场上·墓地当作通常怪兽使用，并支持二重再召唤机制。
	aux.EnableDualAttribute(c)
	-- 对应效果原文：●把这张卡解放，以「炎妖蝶 维尔普斯」以外的自己墓地1只二重怪兽为对象才能发动。那只怪兽特殊召唤。这个效果特殊召唤的怪兽当作再1次召唤的状态使用。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetDescription(aux.Stringid(16984449,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_MZONE)
	-- 设置效果发动条件：必须是在这张卡处于再1次召唤（二重状态）时才能发动。
	e1:SetCondition(aux.IsDualState)
	e1:SetCost(c16984449.cost)
	e1:SetTarget(c16984449.target)
	e1:SetOperation(c16984449.operation)
	c:RegisterEffect(e1)
end
-- 定义发动代价：检查这张卡是否可以被解放，并在发动时解放这张卡作为代价。
function c16984449.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsReleasable() end
	-- 将这张卡解放，作为效果的发动代价（REASON_COST）。
	Duel.Release(e:GetHandler(),REASON_COST)
end
-- 过滤函数：选择自己墓地中满足条件的二重怪兽——必须是二重怪兽、卡名不是「炎妖蝶 维尔普斯」、且能够被特殊召唤。
function c16984449.filter(c,e,sp)
	return c:IsType(TYPE_DUAL) and not c:IsCode(16984449) and c:IsCanBeSpecialSummoned(e,0,sp,false,false)
end
-- 定义效果发动时的目标选择：检查自己场上是否有可用区域（因解放后会有空位，所以用-1判断），并选择1只符合条件的墓地二重怪兽作为对象。
function c16984449.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c16984449.filter(chkc,e,tp) end
	-- 效果发动时检查可用区域：由于这张卡会被解放，允许当前场上没有空位，因此条件为区域数>-1。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>-1
		-- 同时确认墓地中存在至少1只符合条件的二重怪兽可以作为效果对象。
		and Duel.IsExistingTarget(c16984449.filter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 向操作者显示选择提示，提示内容为“请选择要特殊召唤的卡”。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从自己墓地选择1只符合条件的二重怪兽，并将其登记为效果对象。
	local g=Duel.SelectTarget(tp,c16984449.filter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置操作信息：本次效果为特殊召唤1只怪兽，用于连锁相关判定。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 效果处理：获取对象怪兽，若它仍与效果关联则将其特殊召唤，并让它进入再1次召唤状态；最后完成特殊召唤处理。
function c16984449.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 取得效果处理时要特殊召唤的对象怪兽（即发动时选择的那只墓地二重怪兽）。
	local tc=Duel.GetFirstTarget()
	-- 检查对象怪兽是否仍与效果关联，并尝试将其以表侧表示特殊召唤到自己场上；特殊召唤成功则进行后续处理。
	if tc:IsRelateToEffect(e) and Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP) then
		tc:EnableDualState()
	end
	-- 完成特殊召唤处理流程，确认特殊召唤结果。
	Duel.SpecialSummonComplete()
end
