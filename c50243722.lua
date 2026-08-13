--バースト・リバース
-- 效果：
-- ①：支付2000基本分，以自己墓地1只怪兽为对象才能发动。那只怪兽里侧守备表示特殊召唤。
function c50243722.initial_effect(c)
	-- ①：支付2000基本分，以自己墓地1只怪兽为对象才能发动。那只怪兽里侧守备表示特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_MSET)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMING_END_PHASE)
	e1:SetCost(c50243722.cost)
	e1:SetTarget(c50243722.target)
	e1:SetOperation(c50243722.operation)
	c:RegisterEffect(e1)
end
-- 定义发动代价函数：chk==0时检查自己能否支付2000基本分，否则实际支付2000基本分。
function c50243722.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 代价检查阶段：确认自己可以支付2000基本分，若不能则效果不能发动。
	if chk==0 then return Duel.CheckLPCost(tp,2000) end
	-- 实际支付2000基本分，作为效果的发动代价。
	Duel.PayLPCost(tp,2000)
end
-- 筛选条件：怪兽可以被当前玩家以里侧守备表示特殊召唤（调用特殊召唤合法性检查）。
function c50243722.filter(c,e,tp)
	return c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEDOWN_DEFENSE)
end
-- 目标选择处理：验证玩家选中的墓地怪兽是否合法；发动合法性检查时确认自己有可用怪兽区且墓地存在符合条件的对象。
function c50243722.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c50243722.filter(chkc,e,tp) end
	-- 检查自己场上是否有空余的怪兽区域，用于放置里侧守备表示特殊召唤的怪兽。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查自己墓地是否存在至少1张符合条件的可特殊召唤的怪兽作为对象。
		and Duel.IsExistingTarget(c50243722.filter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 向玩家显示选择提示，要求选择要特殊召唤的怪兽（提示文本：请选择要特殊召唤的卡）。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让发动玩家从自己墓地选择1只符合条件的怪兽，并设置为该效果的对象。
	local g=Duel.SelectTarget(tp,c50243722.filter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 登记操作信息：本次效果包含特殊召唤，对象为已选择的怪兽，数量为1（供其它效果联动检测）。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 效果处理：取出对象怪兽，若其仍与效果关联，则将其以里侧守备表示特殊召唤；若成功，则向对方展示该怪兽。
function c50243722.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取发动时所选择的对象怪兽。
	local tc=Duel.GetFirstTarget()
	-- 确认对象怪兽仍与效果关联，尝试以里侧守备表示特殊召唤；若特殊召唤成功则继续执行后续处理。
	if tc:IsRelateToEffect(e) and Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEDOWN_DEFENSE)>0 then
		-- 向对方玩家展示该特殊召唤成功后的怪兽，使对方确认卡片信息。
		Duel.ConfirmCards(1-tp,tc)
	end
end
