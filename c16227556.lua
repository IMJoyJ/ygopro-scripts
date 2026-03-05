--検閲
-- 效果：
-- 每次对方的准备阶段可以支付500基本分，随机看对方1张手卡。
function c16227556.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- 每次对方的准备阶段可以支付500基本分，随机看对方1张手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(16227556,0))  --"查看手牌"
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1)
	e2:SetCondition(c16227556.cfcon)
	e2:SetCost(c16227556.cfcost)
	e2:SetOperation(c16227556.cfop)
	c:RegisterEffect(e2)
end
-- 效果作用
function c16227556.cfcon(e,tp,eg,ep,ev,re,r,rp)
	-- 对方回合且对方手牌不为空时才能发动
	return Duel.GetTurnPlayer()~=tp and Duel.GetFieldGroupCount(tp,0,LOCATION_HAND)~=0
end
-- 效果作用
function c16227556.cfcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否能支付500基本分
	if chk==0 then return Duel.CheckLPCost(tp,500) end
	-- 支付500基本分
	Duel.PayLPCost(tp,500)
end
-- 效果作用
function c16227556.cfop(e,tp,eg,ep,ev,re,r,rp)
	-- 从对方手牌中随机选择1张
	local g=Duel.GetFieldGroup(tp,0,LOCATION_HAND):RandomSelect(tp,1)
	if g:GetCount()~=0 then
		-- 确认对方手牌
		Duel.ConfirmCards(tp,g)
		-- 洗切对方手牌
		Duel.ShuffleHand(1-tp)
	end
end
