--儀式降臨封印の書
-- 效果：
-- 场上表侧表示存在的1只仪式怪兽破坏。
function c9145181.initial_effect(c)
	-- 场上表侧表示存在的1只仪式怪兽破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e1:SetTarget(c9145181.target)
	e1:SetOperation(c9145181.activate)
	c:RegisterEffect(e1)
end
-- 过滤条件：场上表侧表示的仪式怪兽
function c9145181.filter(c)
	return c:IsFaceup() and c:IsType(TYPE_RITUAL)
end
-- 效果发动的目标选择：检查并选择场上1只表侧表示的仪式怪兽作为对象，并设置破坏的操作信息
function c9145181.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c9145181.filter(chkc) end
	-- 在发动阶段，检查场上是否存在可作为对象的表侧表示仪式怪兽
	if chk==0 then return Duel.IsExistingTarget(c9145181.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 向发动效果的玩家提示选择要破坏的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择场上1只表侧表示的仪式怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c9145181.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 设置效果处理信息，表示此效果将破坏选中的1张卡
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 效果处理：获取对象卡片，若其仍与效果有关联且呈表侧表示，则将其破坏
function c9145181.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取在发动时选择的效果对象怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 将目标怪兽因效果破坏
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
