--狡猾な落とし穴
-- 效果：
-- ①：自己墓地没有陷阱卡存在的场合，以场上2只怪兽为对象才能发动。那些怪兽破坏。
function c99590524.initial_effect(c)
	-- ①：自己墓地没有陷阱卡存在的场合，以场上2只怪兽为对象才能发动。那些怪兽破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e1:SetCondition(c99590524.condition)
	e1:SetTarget(c99590524.target)
	e1:SetOperation(c99590524.activate)
	c:RegisterEffect(e1)
end
-- 效果发动条件函数：检查自己墓地没有陷阱卡存在时才允许发动。
function c99590524.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己墓地中不存在陷阱卡，若不存在则条件成立。
	return not Duel.IsExistingMatchingCard(Card.IsType,tp,LOCATION_GRAVE,0,1,nil,TYPE_TRAP)
end
-- 取对象函数：选择场上2只怪兽作为效果对象，并设置破坏效果的操作信息。
function c99590524.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) end
	-- 确认场上存在至少2只可以作为对象的怪兽。
	if chk==0 then return Duel.IsExistingTarget(aux.TRUE,tp,LOCATION_MZONE,LOCATION_MZONE,2,nil) end
	-- 给操作者发送选择提示：请选择要破坏的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 从双方场上选择2只怪兽作为效果对象，并将它们设为当前连锁的对象。
	local g=Duel.SelectTarget(tp,aux.TRUE,tp,LOCATION_MZONE,LOCATION_MZONE,2,2,nil)
	-- 设置本次连锁的效果分类为破坏，对象为所选的2只怪兽。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,2,0,0)
end
-- 效果处理函数：取回发动时选择的对象，过滤掉已不相关或不在场的卡，然后将其破坏。
function c99590524.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁选择的对象卡组，并过滤出仍然与此效果相关的卡片。
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e)
	-- 将这些卡片以效果破坏并送入墓地。
	Duel.Destroy(g,REASON_EFFECT)
end
