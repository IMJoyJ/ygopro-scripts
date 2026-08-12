--誤爆
-- 效果：
-- ①：以自己场上1张卡为对象才能发动。那张卡破坏。
function c55573346.initial_effect(c)
	-- ①：以自己场上1张卡为对象才能发动。那张卡破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e1:SetTarget(c55573346.target)
	e1:SetOperation(c55573346.activate)
	c:RegisterEffect(e1)
end
-- 效果发动的对象选择与检测
function c55573346.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsOnField() end
	-- 在发动阶段（chk==0）检测自己场上是否存在除这张卡以外的至少1张卡可以作为效果对象
	if chk==0 then return Duel.IsExistingTarget(nil,tp,LOCATION_ONFIELD,0,1,e:GetHandler()) end
	-- 给玩家发送提示信息，提示选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择自己场上除这张卡以外的1张卡作为效果的对象
	local g=Duel.SelectTarget(tp,nil,tp,LOCATION_ONFIELD,0,1,1,e:GetHandler())
	-- 设置效果处理信息，表明该效果包含破坏操作，操作对象为选择的卡，数量为1
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 效果处理的执行，将作为对象的卡破坏
function c55573346.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取发动时选择的第一个效果对象
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将该对象卡因效果破坏
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
