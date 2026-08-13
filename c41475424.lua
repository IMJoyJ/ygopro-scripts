--機限爆弾
-- 效果：
-- 选择自己场上表侧表示存在的1只名字带有「机皇」的怪兽和对方场上存在的1张卡发动。选择的卡破坏。
function c41475424.initial_effect(c)
	-- 选择自己场上表侧表示存在的1只名字带有「机皇」的怪兽和对方场上存在的1张卡发动。选择的卡破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e1:SetTarget(c41475424.target)
	e1:SetOperation(c41475424.activate)
	c:RegisterEffect(e1)
end
-- 定义过滤器：筛选出表侧表示且属于「机皇」系列的怪兽，用于选择自己场上的机皇怪兽。
function c41475424.filter(c)
	return c:IsFaceup() and c:IsSetCard(0x13)
end
-- 效果发动时的目标检查和合法性判断：排除连锁处理时的不合法调用，并确认自己场上有机皇怪兽且对方场上有卡可以作为取对象目标。
function c41475424.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	-- 检查自己场上是否存在1只表侧表示且名字带有「机皇」的怪兽，且该怪兽能成为效果对象。
	if chk==0 then return Duel.IsExistingTarget(c41475424.filter,tp,LOCATION_MZONE,0,1,nil)
		-- 检查对方场上是否存在1张卡，且该卡能成为效果对象。
		and Duel.IsExistingTarget(aux.TRUE,tp,0,LOCATION_ONFIELD,1,nil) end
	-- 向操作者显示“请选择要破坏的卡”的选择提示消息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 从自己场上选择1只表侧表示且名字带有「机皇」的怪兽作为效果对象。
	local g1=Duel.SelectTarget(tp,c41475424.filter,tp,LOCATION_MZONE,0,1,1,nil)
	-- 向操作者显示“请选择要破坏的卡”的选择提示消息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 从对方场上选择1张卡作为效果对象。
	local g2=Duel.SelectTarget(tp,aux.TRUE,tp,0,LOCATION_ONFIELD,1,1,nil)
	g1:Merge(g2)
	-- 设置本次连锁将破坏所选2张卡的操作信息，用于后续的发动判定与效果处理。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g1,2,0,0)
end
-- 效果处理时，获取全部对象卡，筛选出仍与该效果关联的卡，若存在则将其全部破坏。
function c41475424.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁处理中记录的对象卡组。
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	local tg=g:Filter(Card.IsRelateToEffect,nil,e)
	if tg:GetCount()>0 then
		-- 将筛选出的对象卡以效果破坏送入墓地。
		Duel.Destroy(tg,REASON_EFFECT)
	end
end
