--リターン・ゾンビ
-- 效果：
-- 自己的准备阶段时，这张卡在墓地存在并且自己手卡是0张的场合，可以支付500基本分把这张卡加入手卡。
function c3072077.initial_effect(c)
	-- 创建一个诱发选发效果，满足条件时可以将此卡加入手卡
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
-- 效果发动的条件：当前回合玩家为效果持有者且手卡为0张
function c3072077.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 当前回合玩家为效果持有者且手卡为0张
	return Duel.GetTurnPlayer()==tp and Duel.GetFieldGroupCount(tp,LOCATION_HAND,0)==0
end
-- 支付500基本分的费用
function c3072077.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否能支付500基本分
	if chk==0 then return Duel.CheckLPCost(tp,500) end
	-- 支付500基本分
	Duel.PayLPCost(tp,500)
end
-- 设置效果的目标为自身
function c3072077.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToHand() end
	-- 设置连锁操作信息为将自身加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,e:GetHandler(),1,0,0)
end
-- 效果处理时将自身加入手牌
function c3072077.operation(e,tp,eg,ep,ev,re,r,rp)
	if e:GetHandler():IsRelateToEffect(e) then
		-- 将自身以效果原因加入手牌
		Duel.SendtoHand(e:GetHandler(),nil,REASON_EFFECT)
	end
end
