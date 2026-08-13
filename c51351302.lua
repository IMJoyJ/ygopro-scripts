--ウジャト眼を持つ男
-- 效果：
-- 这张卡通常召唤时和每到自己准备阶段时，选择对方场上1张盖放的卡，确认后回复原状。
function c51351302.initial_effect(c)
	-- 这张卡通常召唤时，选择对方场上1张盖放的卡，确认后回复原状。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(51351302,0))  --"确认"
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetTarget(c51351302.target)
	e1:SetOperation(c51351302.operation)
	c:RegisterEffect(e1)
	-- 每到自己准备阶段时，选择对方场上1张盖放的卡，确认后回复原状。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(51351302,0))  --"确认"
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e2:SetCountLimit(1)
	e2:SetCondition(c51351302.condition)
	e2:SetTarget(c51351302.target)
	e2:SetOperation(c51351302.operation)
	c:RegisterEffect(e2)
end
-- 该效果的发动条件：当前回合玩家是这张卡的控制者，即仅在自己回合的准备阶段才能发动。
function c51351302.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前回合玩家是否为自己，确保效果只在自己的准备阶段发动。
	return Duel.GetTurnPlayer()==tp
end
-- 效果发动时的Target处理：取对象条件为对方场上的里侧表示卡；发动时选择对方场上1张里侧表示的卡作为对象。
function c51351302.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(1-tp) and chkc:IsOnField() and chkc:IsFacedown() end
	if chk==0 then return true end
	-- 向操作玩家显示选择提示消息，提示其选择一张要确认的卡。
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(51351302,1))  --"请选择一张要确认的卡"
	-- 选择对方场上1张里侧表示的卡作为效果对象，并将该卡登记为当前连锁的对象。
	Duel.SelectTarget(tp,Card.IsFacedown,tp,0,LOCATION_ONFIELD,1,1,nil)
end
-- 效果处理：取得效果对象，若对象仍与此效果关联且仍为里侧表示，则向控制者展示该卡（确认后自然回复原状）。
function c51351302.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果处理时连锁中登记的第一个对象卡。
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) and tc:IsFacedown() then
		-- 将自己选择的对方里侧表示的卡展示给控制者（即确认该卡），确认后卡片仍保持里侧表示，相当于回复原状。
		Duel.ConfirmCards(tp,tc)
	end
end
