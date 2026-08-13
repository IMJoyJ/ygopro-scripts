--スリーカード
-- 效果：
-- 自己场上有衍生物以外的同名怪兽3只以上存在的场合才能发动。选择对方场上3张卡破坏。
function c47594192.initial_effect(c)
	-- 自己场上有衍生物以外的同名怪兽3只以上存在的场合才能发动。选择对方场上3张卡破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e1:SetCondition(c47594192.condition)
	e1:SetTarget(c47594192.target)
	e1:SetOperation(c47594192.activate)
	c:RegisterEffect(e1)
end
-- 定义筛选怪兽的条件：该怪兽需表侧表示且不是衍生物，并且场上还存在至少2只与其同名的表侧表示怪兽（排除自身）。
function c47594192.cfilter(c,tp)
	-- 返回真当且仅当：该怪兽表侧表示且不是衍生物，且自己场上存在至少2只同名的其他表侧表示怪兽。
	return c:IsFaceup() and not c:IsType(TYPE_TOKEN) and Duel.IsExistingMatchingCard(c47594192.cfilter2,tp,LOCATION_MZONE,0,2,c,c:GetCode())
end
-- 定义同名筛选：检查目标怪兽是否表侧表示且卡名与指定卡号一致。
function c47594192.cfilter2(c,code)
	return c:IsFaceup() and c:IsCode(code)
end
-- 发动条件判定：自己场上存在至少1只满足非衍生物且有3只以上同名表侧表示怪兽条件的怪兽时，允许发动。
function c47594192.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否存在至少1只满足c47594192.cfilter条件的怪兽（该条件会进一步确认同名怪兽3只以上）。
	return Duel.IsExistingMatchingCard(c47594192.cfilter,tp,LOCATION_MZONE,0,1,nil,tp)
end
-- 发动时的目标选择处理：确认对象为对方场上的卡；检查对方场上是否有3张可选卡；提示并选择3张卡作为效果对象，同时登记破坏3张卡的操作信息。
function c47594192.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsControler(1-tp) end
	-- 在合法性检查阶段（chk==0），确认对方场上存在至少3张可以成为效果对象的卡。
	if chk==0 then return Duel.IsExistingTarget(aux.TRUE,tp,0,LOCATION_ONFIELD,3,nil) end
	-- 向操作玩家显示选择提示，提示文字为“请选择要破坏的卡”。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 让操作玩家选择对方场上的3张卡作为效果对象，并将这些卡登记为当前连锁的对象。
	local g=Duel.SelectTarget(tp,aux.TRUE,tp,0,LOCATION_ONFIELD,3,3,nil)
	-- 登记本连锁的操作信息：本次效果为破坏3张卡，对象为已选择的g，供后续连锁判断使用。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,3,0,0)
end
-- 效果处理操作：取出连锁对象中仍与效果关联的卡，并将其全部破坏。
function c47594192.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取本连锁处理时登记的对象卡，并过滤出仍然与本次效果相关的卡（排除已离场或失去关联的卡）。
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e)
	-- 以效果（REASON_EFFECT）为破坏原因，将过滤后的对象卡全部破坏。
	Duel.Destroy(g,REASON_EFFECT)
end
