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
-- 该效果为强制诱发选发效果，此函数为发动条件判断：仅在对方回合的准备阶段且对方手牌存在时允许发动。
function c16227556.cfcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判定当前回合玩家不是效果控制者（即为对方回合），且对方手牌数量不为0，二者同时满足时才满足发动条件。
	return Duel.GetTurnPlayer()~=tp and Duel.GetFieldGroupCount(tp,0,LOCATION_HAND)~=0
end
-- 该函数为代价函数，用于在发动时先处理支付500基本分的代价；chk=0时进行是否可支付的检测，非0时实际支付。
function c16227556.cfcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 费用检测阶段：检查控制者能否支付500基本分作为发动代价，若不能则无法发动。
	if chk==0 then return Duel.CheckLPCost(tp,500) end
	-- 实际支付500基本分给效果控制者，扣除其生命值。
	Duel.PayLPCost(tp,500)
end
-- 该函数为效果处理操作：随机从对方手牌中选择1张，展示给控制者确认，然后洗切对方手牌。
function c16227556.cfop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取对方全部手卡，并从中随机选择1张作为本次确认的对象。
	local g=Duel.GetFieldGroup(tp,0,LOCATION_HAND):RandomSelect(tp,1)
	if g:GetCount()~=0 then
		-- 将随机选出的那张手牌展示给效果控制者观看，实现‘随机看对方1张手卡’。
		Duel.ConfirmCards(tp,g)
		-- 确认后洗切对方的手牌，以还原手牌顺序，防止因展示操作泄露手牌排列信息。
		Duel.ShuffleHand(1-tp)
	end
end
