--融合体駆除装置
-- 效果：
-- 场上表侧表示存在的1只融合怪兽破坏。
function c72150572.initial_effect(c)
	-- 场上表侧表示存在的1只融合怪兽破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e1:SetTarget(c72150572.target)
	e1:SetOperation(c72150572.activate)
	c:RegisterEffect(e1)
end
-- 过滤条件：场上表侧表示的融合怪兽
function c72150572.filter(c)
	return c:IsFaceup() and c:IsType(TYPE_FUSION)
end
-- 效果发动时的对象选择与处理
function c72150572.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c72150572.filter(chkc) end
	-- 检查场上是否存在可以作为对象的表侧表示融合怪兽
	if chk==0 then return Duel.IsExistingTarget(c72150572.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 给玩家发送“请选择要破坏的卡”的提示信息
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择场上1只表侧表示的融合怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c72150572.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 设置效果处理信息：破坏选中的1张卡
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 效果处理的执行函数
function c72150572.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取在发动时选择的效果对象
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 因效果破坏该目标怪兽
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
