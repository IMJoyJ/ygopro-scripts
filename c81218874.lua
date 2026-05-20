--侵略の波紋
-- 效果：
-- 支付500基本分，选择自己墓地存在的1只4星以下的名字带有「侵入魔鬼」的怪兽发动。选择的怪兽从墓地特殊召唤。
function c81218874.initial_effect(c)
	-- 支付500基本分，选择自己墓地存在的1只4星以下的名字带有「侵入魔鬼」的怪兽发动。选择的怪兽从墓地特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMING_END_PHASE)
	e1:SetCost(c81218874.cost)
	e1:SetTarget(c81218874.target)
	e1:SetOperation(c81218874.activate)
	c:RegisterEffect(e1)
end
-- 定义发动代价（Cost）函数，处理支付500基本分的操作
function c81218874.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动检查阶段，确认玩家是否能支付500点基本分
	if chk==0 then return Duel.CheckLPCost(tp,500) end
	-- 执行支付500点基本分的操作
	Duel.PayLPCost(tp,500)
end
-- 定义过滤条件：等级4以下、名字带有「侵入魔鬼」且可以特殊召唤的怪兽
function c81218874.filter(c,e,tp)
	return c:IsLevelBelow(4) and c:IsSetCard(0x100a) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 定义效果发动时的目标选择（Target）函数，进行发动条件检查并选择对象
function c81218874.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c81218874.filter(chkc,e,tp) end
	-- 在发动检查阶段，确认自己场上是否有空余的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 并确认自己墓地是否存在至少1只符合条件的怪兽可以作为对象
		and Duel.IsExistingTarget(c81218874.filter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 设置提示信息，提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家选择自己墓地1只符合条件的怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c81218874.filter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置效果处理信息，声明此效果包含特殊召唤该怪兽的操作
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 定义效果处理（Operation）函数，执行特殊召唤
function c81218874.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取发动时选择的效果对象怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将该怪兽以表侧表示特殊召唤到自己场上
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
