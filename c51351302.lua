--ウジャト眼を持つ男
-- 效果：
-- 这张卡通常召唤时和每到自己准备阶段时，选择对方场上1张盖放的卡，确认后回复原状。
function c51351302.initial_effect(c)
	-- 效果原文：这张卡通常召唤时和每到自己准备阶段时，选择对方场上1张盖放的卡，确认后回复原状。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(51351302,0))  --"确认"
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetTarget(c51351302.target)
	e1:SetOperation(c51351302.operation)
	c:RegisterEffect(e1)
	-- 效果原文：这张卡通常召唤时和每到自己准备阶段时，选择对方场上1张盖放的卡，确认后回复原状。
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
-- 判断是否为自己的准备阶段
function c51351302.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前回合玩家是否为自己
	return Duel.GetTurnPlayer()==tp
end
-- 选择对方场上的1张里侧表示的卡作为效果对象
function c51351302.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(1-tp) and chkc:IsOnField() and chkc:IsFacedown() end
	if chk==0 then return true end
	-- 向玩家提示“请选择一张要确认的卡”
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(51351302,1))  --"请选择一张要确认的卡"
	-- 选择目标：对方场上1张里侧表示的卡
	Duel.SelectTarget(tp,Card.IsFacedown,tp,0,LOCATION_ONFIELD,1,1,nil)
end
-- 确认目标卡片内容并展示给玩家
function c51351302.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中被选择的目标卡片
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) and tc:IsFacedown() then
		-- 将目标卡片的内容确认并展示给玩家
		Duel.ConfirmCards(tp,tc)
	end
end
