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
-- 检查玩家是否能支付2000基本分
function c50243722.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家是否能支付2000基本分
	if chk==0 then return Duel.CheckLPCost(tp,2000) end
	-- 让玩家支付2000基本分
	Duel.PayLPCost(tp,2000)
end
-- 判断目标怪兽是否可以里侧守备表示特殊召唤
function c50243722.filter(c,e,tp)
	return c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEDOWN_DEFENSE)
end
-- 设置效果的发动条件，确保场上存在可特殊召唤的墓地怪兽
function c50243722.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c50243722.filter(chkc,e,tp) end
	-- 检查玩家场上是否有足够的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 确认玩家墓地中是否存在符合条件的怪兽
		and Duel.IsExistingTarget(c50243722.filter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择目标怪兽并设置为效果对象
	local g=Duel.SelectTarget(tp,c50243722.filter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置操作信息，表明将要特殊召唤一只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 执行效果的操作部分，处理特殊召唤及确认卡片
function c50243722.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的效果对象
	local tc=Duel.GetFirstTarget()
	-- 判断目标怪兽是否仍然存在于场上并进行特殊召唤
	if tc:IsRelateToEffect(e) and Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEDOWN_DEFENSE)>0 then
		-- 向对方玩家展示被特殊召唤的怪兽
		Duel.ConfirmCards(1-tp,tc)
	end
end
