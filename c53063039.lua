--Sin Claw Stream
-- 效果：
-- ①：自己场上有「罪」怪兽存在的场合，以对方场上1只怪兽为对象才能发动。那只对方怪兽破坏。
function c53063039.initial_effect(c)
	-- 效果原文内容：①：自己场上有「罪」怪兽存在的场合，以对方场上1只怪兽为对象才能发动。那只对方怪兽破坏。
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
-- 规则层面作用：定义过滤函数，用于检测场上是否有表侧表示的「罪」卡
function c53063039.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x23)
end
-- 规则层面作用：判断是否满足发动条件，即自己场上有至少1张「罪」怪兽
function c53063039.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 规则层面作用：检查自己场上是否存在满足条件的「罪」怪兽
	return Duel.IsExistingMatchingCard(c53063039.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
-- 规则层面作用：设置效果的目标选择函数，允许选择对方场上的怪兽作为目标
function c53063039.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) end
	-- 规则层面作用：判断是否可以进行目标选择，即对方场上存在至少1只怪兽
	if chk==0 then return Duel.IsExistingTarget(aux.TRUE,tp,0,LOCATION_MZONE,1,nil) end
	-- 规则层面作用：向玩家提示选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 规则层面作用：选择对方场上的一只怪兽作为效果对象
	local g=Duel.SelectTarget(tp,aux.TRUE,tp,0,LOCATION_MZONE,1,1,nil)
	-- 规则层面作用：设置当前连锁的操作信息，指定将要破坏的卡
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 规则层面作用：设置效果的处理函数，执行破坏操作
function c53063039.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 规则层面作用：获取当前连锁的效果目标
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		-- 规则层面作用：以效果为原因破坏目标怪兽
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
