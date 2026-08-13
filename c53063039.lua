--Sin Claw Stream
-- 效果：
-- ①：自己场上有「罪」怪兽存在的场合，以对方场上1只怪兽为对象才能发动。那只对方怪兽破坏。
function c53063039.initial_effect(c)
	-- ①：自己场上有「罪」怪兽存在的场合，以对方场上1只怪兽为对象才能发动。那只对方怪兽破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e1:SetCondition(c53063039.condition)
	e1:SetTarget(c53063039.target)
	e1:SetOperation(c53063039.activate)
	c:RegisterEffect(e1)
end
-- 定义过滤函数：筛选出表侧表示且字段为「罪」（0x23）的怪兽。
function c53063039.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x23)
end
-- 发动条件判定：检查自己场上是否存在至少1只满足「罪」字段条件的怪兽。
function c53063039.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 从自己主要怪兽区检索是否存在至少1张表侧表示的「罪」字段怪兽。
	return Duel.IsExistingMatchingCard(c53063039.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
-- 效果发动时的目标处理：选择对方场上1只怪兽作为对象，并登记破坏该对象的操作信息。
function c53063039.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) end
	-- 发动合法性检查：对方场上存在至少1只可成为对象的怪兽时才能发动。
	if chk==0 then return Duel.IsExistingTarget(aux.TRUE,tp,0,LOCATION_MZONE,1,nil) end
	-- 向操作者显示“请选择要破坏的卡”的提示文字。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 从对方场上选择1只怪兽作为效果对象，并自动建立对象关联。
	local g=Duel.SelectTarget(tp,aux.TRUE,tp,0,LOCATION_MZONE,1,1,nil)
	-- 设置连锁操作信息：本次效果将破坏所选择的1只怪兽（类别为破坏）。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 效果处理时的操作：取得之前选择的对象，若仍与效果关联则将其破坏。
function c53063039.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 取得本效果发动时选择的那1只对象怪兽。
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		-- 以效果（REASON_EFFECT）为原因将对象怪兽破坏。
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
