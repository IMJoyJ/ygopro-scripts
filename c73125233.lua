--風帝ライザー
-- 效果：
-- ①：这张卡上级召唤的场合，以场上1张卡为对象发动。那张卡回到卡组最上面。
function c73125233.initial_effect(c)
	-- ①：这张卡上级召唤的场合，以场上1张卡为对象发动。那张卡回到卡组最上面。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(73125233,0))  --"返回卡组"
	e1:SetCategory(CATEGORY_TODECK)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetCondition(c73125233.condition)
	e1:SetTarget(c73125233.target)
	e1:SetOperation(c73125233.operation)
	c:RegisterEffect(e1)
end
-- 检查这张卡是否是通过上级召唤成功来满足发动条件
function c73125233.condition(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_ADVANCE)
end
-- 效果发动的目标选择与检测：选择场上1张卡作为对象，并设置返回卡组的操作信息
function c73125233.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() end
	if chk==0 then return true end
	-- 给发动效果的玩家发送提示信息，提示其选择要返回卡组的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 选择双方场上合计1张卡作为效果的对象
	local g=Duel.SelectTarget(tp,nil,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
	local tc=g:GetFirst()
	if tc and tc:IsAbleToDeck() then
		-- 设置当前连锁的操作信息，表明将有1张卡被送回卡组
		Duel.SetOperationInfo(0,CATEGORY_TODECK,tc,1,0,0)
	end
end
-- 效果处理：获取对象卡，若其仍对该效果有效，则将其送回卡组最上面
function c73125233.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取在发动阶段选择的对象卡
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		-- 将目标卡片以效果原因送回持有者卡组的最上面
		Duel.SendtoDeck(tc,nil,SEQ_DECKTOP,REASON_EFFECT)
	end
end
