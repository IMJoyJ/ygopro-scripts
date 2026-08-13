--侵略の波動
-- 效果：
-- 让自己场上表侧表示存在的1只上级召唤成功的名字带有「侵入魔鬼」的怪兽回到手卡发动。选择对方场上存在的1张卡破坏。
function c18816758.initial_effect(c)
	-- 让自己场上表侧表示存在的1只上级召唤成功的名字带有「侵入魔鬼」的怪兽回到手卡发动。选择对方场上存在的1张卡破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCost(c18816758.cost)
	e1:SetTarget(c18816758.target)
	e1:SetOperation(c18816758.activate)
	c:RegisterEffect(e1)
end
-- 定义代价筛选条件：怪兽必须表侧表示、属于「侵入魔鬼」系列、上级召唤成功，并且可以作为代价返回手卡。
function c18816758.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x100a)
		and c:IsSummonType(SUMMON_TYPE_ADVANCE) and c:IsAbleToHandAsCost()
end
-- 代价处理流程：先检查是否存在符合条件的怪兽，存在则提示玩家选择1张，将其返回手卡作为发动代价。
function c18816758.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在代价确认阶段检查自己场上是否存在至少1张满足过滤器c18816758.cfilter的卡，若不存在则不能发动。
	if chk==0 then return Duel.IsExistingMatchingCard(c18816758.cfilter,tp,LOCATION_MZONE,0,1,nil) end
	-- 向玩家发送选择提示，消息内容为“请选择要返回手牌的卡”，用于后续选择卡片的交互提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)  --"请选择要返回手牌的卡"
	-- 从自己场上选择1张满足过滤器c18816758.cfilter的怪兽作为发动代价。
	local g=Duel.SelectMatchingCard(tp,c18816758.cfilter,tp,LOCATION_MZONE,0,1,1,nil)
	-- 将选择的怪兽以代价原因返回持有者手卡，完成发动代价的支付。
	Duel.SendtoHand(g,nil,REASON_COST)
end
-- 目标处理流程：效果为取对象破坏，先验证对象合法性，再选择对方场上的1张卡作为效果对象，并设置破坏的操作信息。
function c18816758.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(1-tp) and chkc:IsOnField() end
	-- 在目标确认阶段检查对方场上是否存在至少1张可以作为效果对象的卡，若不存在则不能发动。
	if chk==0 then return Duel.IsExistingTarget(aux.TRUE,tp,0,LOCATION_ONFIELD,1,nil) end
	-- 向玩家发送选择提示，消息内容为“请选择要破坏的卡”，用于后续选择对象的交互提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择对方场上的1张卡作为本效果的对象，并建立该卡与当前连锁的关联。
	local g=Duel.SelectTarget(tp,aux.TRUE,tp,0,LOCATION_ONFIELD,1,1,nil)
	-- 设置当前连锁的操作信息，表明本效果将破坏1张卡，用于被其他卡或效果的正确响应。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 效果处理流程：从当前连锁取得效果对象，若对象仍与效果关联则将其破坏。
function c18816758.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 取出本效果发动时选择的对象卡。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 以效果原因破坏对象卡，实际执行“选择对方场上存在的1张卡破坏”的规则操作。
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
