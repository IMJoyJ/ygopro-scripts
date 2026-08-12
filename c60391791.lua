--千里眼
-- 效果：
-- 1回合1次，在自己的准备阶段支付100基本分，就可以确认对方卡组最上面的1张卡，之后将其放回。对方不能确认这张卡。
function c60391791.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- 1回合1次，在自己的准备阶段支付100基本分，就可以确认对方卡组最上面的1张卡，之后将其放回。对方不能确认这张卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(60391791,0))  --"确认卡组"
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1)
	e2:SetCondition(c60391791.cfcon)
	e2:SetCost(c60391791.cfcost)
	e2:SetOperation(c60391791.cfop)
	c:RegisterEffect(e2)
end
-- 定义效果发动条件函数，判断是否为自己的准备阶段且对方卡组有卡
function c60391791.cfcon(e,tp,eg,ep,ev,re,r,rp)
	-- 返回当前回合玩家是否为自己，且对方卡组数量不为0
	return Duel.GetTurnPlayer()==tp and Duel.GetFieldGroupCount(tp,0,LOCATION_DECK)~=0
end
-- 定义效果发动代价函数，检查并支付100基本分
function c60391791.cfcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在效果发动时，检查玩家是否能够支付100基本分
	if chk==0 then return Duel.CheckLPCost(tp,100) end
	-- 让玩家支付100基本分
	Duel.PayLPCost(tp,100)
end
-- 定义效果处理函数，获取并确认对方卡组最上方的卡
function c60391791.cfop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取对方卡组最上方的一张卡
	local g=Duel.GetDecktopGroup(1-tp,1)
	if g:GetCount()~=0 then
		-- 给当前玩家确认获取到的卡片
		Duel.ConfirmCards(tp,g)
	end
end
