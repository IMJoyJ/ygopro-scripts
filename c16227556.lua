--検閲
-- 效果：
-- 每次对方的准备阶段可以支付500基本分，随机看对方1张手卡。
function c16227556.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- 效果原文：每次对方的准备阶段可以支付500基本分，随机看对方1张手卡。
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
-- 设置触发条件函数：判断当前是否为自己回合且对方手牌数不为0
function c16227556.cfcon(e,tp,eg,ep,ev,re,r,rp)
	-- 返回条件：当前回合玩家不是自己且对方手牌数不为0
	return Duel.GetTurnPlayer()~=tp and Duel.GetFieldGroupCount(tp,0,LOCATION_HAND)~=0
end
-- 设置费用支付函数：支付500基本分作为发动费用
function c16227556.cfcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 费用检查：判断玩家是否能支付500点LP
	if chk==0 then return Duel.CheckLPCost(tp,500) end
	-- 执行支付：玩家支付500点LP
	Duel.PayLPCost(tp,500)
end
-- 设置效果处理函数：随机查看对方1张手卡并展示后洗切
function c16227556.cfop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取对方手牌并随机选择1张
	local g=Duel.GetFieldGroup(tp,0,LOCATION_HAND):RandomSelect(tp,1)
	if g:GetCount()~=0 then
		-- 展示选中的卡给玩家确认
		Duel.ConfirmCards(tp,g)
		-- 洗切对方的手牌
		Duel.ShuffleHand(1-tp)
	end
end
