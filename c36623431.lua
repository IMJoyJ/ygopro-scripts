--コアキメイルの鋼核
-- 效果：
-- 这张卡在墓地存在的场合，可以作为自己的抽卡阶段时进行通常抽卡的代替，把这张卡加入手卡。此外，自己的抽卡阶段时可以从手卡把1只名字带有「核成」的怪兽送去墓地，自己墓地存在的这张卡加入手卡。
function c36623431.initial_effect(c)
	-- 效果原文：这张卡在墓地存在的场合，可以作为自己的抽卡阶段时进行通常抽卡的代替，把这张卡加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(36623431,0))  --"代替抽卡加入手卡"
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_PREDRAW)
	e1:SetRange(LOCATION_GRAVE)
	e1:SetCondition(c36623431.condition1)
	e1:SetTarget(c36623431.target1)
	e1:SetOperation(c36623431.operation1)
	c:RegisterEffect(e1)
	-- 效果原文：此外，自己的抽卡阶段时可以从手卡把1只名字带有「核成」的怪兽送去墓地，自己墓地存在的这张卡加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(36623431,1))  --"加入手卡"
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_PHASE+PHASE_DRAW)
	e2:SetCountLimit(1)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCondition(c36623431.condition2)
	e2:SetCost(c36623431.cost2)
	e2:SetTarget(c36623431.target2)
	e2:SetOperation(c36623431.operation2)
	c:RegisterEffect(e2)
end
-- 规则层面：判断是否为当前回合玩家触发效果
function c36623431.condition1(e,tp,eg,ep,ev,re,r,rp)
	-- 规则层面：判断是否为当前回合玩家触发效果
	return tp==Duel.GetTurnPlayer()
end
-- 规则层面：设置效果目标为将自身加入手卡
function c36623431.target1(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 规则层面：检查是否可以通常抽卡且自身可以加入手卡
	if chk==0 then return aux.IsPlayerCanNormalDraw(tp) and e:GetHandler():IsAbleToHand() end
	-- 规则层面：设置连锁操作信息为将自身加入手卡
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,e:GetHandler(),1,0,0)
end
-- 规则层面：执行效果操作，放弃通常抽卡并将自身加入手卡
function c36623431.operation1(e,tp,eg,ep,ev,re,r,rp)
	-- 规则层面：检查是否可以通常抽卡，否则不执行效果
	if not aux.IsPlayerCanNormalDraw(tp) then return end
	-- 规则层面：使当前玩家放弃通常抽卡
	aux.GiveUpNormalDraw(e,tp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 规则层面：将自身送入手卡
		Duel.SendtoHand(c,nil,REASON_EFFECT)
		-- 规则层面：确认对方查看送入手卡的卡片
		Duel.ConfirmCards(1-tp,c)
	end
end
-- 规则层面：判断是否为当前回合玩家触发效果
function c36623431.condition2(e,tp,eg,ep,ev,re,r,rp)
	-- 规则层面：判断是否为当前回合玩家触发效果
	return tp==Duel.GetTurnPlayer()
end
-- 规则层面：定义用于支付代价的过滤函数，选择手卡中名字带有「核成」的怪兽
function c36623431.costfilter(c)
	return c:IsSetCard(0x1d) and c:IsType(TYPE_MONSTER) and c:IsAbleToGraveAsCost()
end
-- 规则层面：设置效果代价为丢弃一张名字带有「核成」的怪兽卡
function c36623431.cost2(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 规则层面：检查手卡中是否存在满足条件的怪兽卡
	if chk==0 then return Duel.IsExistingMatchingCard(c36623431.costfilter,tp,LOCATION_HAND,0,1,nil) end
	-- 规则层面：从手卡丢弃一张名字带有「核成」的怪兽卡作为代价
	Duel.DiscardHand(tp,c36623431.costfilter,1,1,REASON_COST,nil)
end
-- 规则层面：设置效果目标为将自身加入手卡
function c36623431.target2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToHand() end
	-- 规则层面：设置连锁操作信息为将自身加入手卡
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,e:GetHandler(),1,0,0)
end
-- 规则层面：执行效果操作，将自身加入手卡
function c36623431.operation2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 规则层面：将自身送入手卡
		Duel.SendtoHand(c,nil,REASON_EFFECT)
		-- 规则层面：确认对方查看送入手卡的卡片
		Duel.ConfirmCards(1-tp,c)
	end
end
