--リターン・ゾンビ
-- 效果：
-- 自己的准备阶段时，这张卡在墓地存在并且自己手卡是0张的场合，可以支付500基本分把这张卡加入手卡。
function c3072077.initial_effect(c)
	-- 自己的准备阶段时，这张卡在墓地存在并且自己手卡是0张的场合，可以支付500基本分把这张卡加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(3072077,0))  --"加入手牌"
	e1:SetType(EFFECT_TYPE_TRIGGER_O+EFFECT_TYPE_FIELD)
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e1:SetRange(LOCATION_GRAVE)
	e1:SetCountLimit(1)
	e1:SetCondition(c3072077.condition)
	e1:SetCost(c3072077.cost)
	e1:SetTarget(c3072077.target)
	e1:SetOperation(c3072077.operation)
	c:RegisterEffect(e1)
end
-- 效果发动条件判定：确认当前回合玩家为自己，且自己手牌数量为0，满足条件才允许进入后续发动流程。
function c3072077.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 返回条件判断结果：当前回合玩家是tp，且tp手牌数为0（即自己准备阶段且手牌为0）。
	return Duel.GetTurnPlayer()==tp and Duel.GetFieldGroupCount(tp,LOCATION_HAND,0)==0
end
-- 定义发动代价：支付500基本分作为发动效果的代价，并在满足代价时执行支付。
function c3072077.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 代价检查阶段（chk==0）：确认玩家tp是否能够支付500基本分。
	if chk==0 then return Duel.CheckLPCost(tp,500) end
	-- 实际支付500基本分。
	Duel.PayLPCost(tp,500)
end
-- 效果发动时的目标处理：检查这张卡能否加入手牌，并设置将这张卡加入手牌的操作信息。
function c3072077.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToHand() end
	-- 设置操作信息：将本效果处理时加入手牌的对象确定为这张卡，分类为回手牌，数量为1。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,e:GetHandler(),1,0,0)
end
-- 效果处理阶段：若这张卡仍与本效果关联，则将其加入手牌。
function c3072077.operation(e,tp,eg,ep,ev,re,r,rp)
	if e:GetHandler():IsRelateToEffect(e) then
		-- 将这张卡送入其持有者的手牌，加入手牌的原因为效果。
		Duel.SendtoHand(e:GetHandler(),nil,REASON_EFFECT)
	end
end
