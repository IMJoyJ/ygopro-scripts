--溟界の漠－ゾーハ
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡从场上送去墓地的场合或者从墓地的特殊召唤成功的场合才能发动。对方从卡组抽1张，自己从卡组把「溟界之漠-佐哈」以外的1只「溟界」怪兽加入手卡。那之后，双方玩家选1张手卡送去墓地。
-- ②：这张卡在墓地存在的场合，把1张手卡送去墓地才能发动。这张卡加入手卡。
function c35998832.initial_effect(c)
	-- ①：这张卡从场上送去墓地的场合或者从墓地的特殊召唤成功的场合才能发动。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(35998832,0))
	e1:SetCategory(CATEGORY_DRAW+CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_HANDES)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_TO_GRAVE)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,35998832)
	e1:SetCondition(c35998832.drcon)
	e1:SetTarget(c35998832.drtg)
	e1:SetOperation(c35998832.drop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetCondition(c35998832.drcon2)
	c:RegisterEffect(e2)
	-- ②：这张卡在墓地存在的场合，把1张手卡送去墓地才能发动。这张卡加入手卡。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(35998832,1))
	e3:SetCategory(CATEGORY_TOHAND)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_GRAVE)
	e3:SetCountLimit(1,35998833)
	e3:SetCost(c35998832.thcost)
	e3:SetTarget(c35998832.thtg)
	e3:SetOperation(c35998832.thop)
	c:RegisterEffect(e3)
end
-- 效果发动条件：这张卡是从场上送去墓地的
function c35998832.drcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousLocation(LOCATION_ONFIELD)
end
-- 效果发动条件：这张卡是从墓地特殊召唤成功的
function c35998832.drcon2(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousLocation(LOCATION_GRAVE)
end
-- 检索过滤函数：排除自己，检索「溟界」怪兽且能加入手牌的卡
function c35998832.drfilter(c)
	return not c:IsCode(35998832) and c:IsSetCard(0x161) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
-- 效果发动时的检查：对方可以抽卡，自己卡组存在满足条件的「溟界」怪兽
function c35998832.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查对方是否可以抽卡
	if chk==0 then return Duel.IsPlayerCanDraw(1-tp,1)
		-- 检查自己卡组是否存在满足条件的「溟界」怪兽
		and Duel.IsExistingMatchingCard(c35998832.drfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息：对方抽卡
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,1-tp,1)
	-- 设置操作信息：自己从卡组检索「溟界」怪兽
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果处理函数：对方抽卡，自己检索并加入手牌，然后双方各选一张手牌送去墓地
function c35998832.drop(e,tp,eg,ep,ev,re,r,rp)
	-- 对方抽卡成功后执行后续处理
	if Duel.Draw(1-tp,1,REASON_EFFECT)~=0 then
		-- 提示玩家选择要加入手牌的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
		-- 选择满足条件的「溟界」怪兽加入手牌
		local g=Duel.SelectMatchingCard(tp,c35998832.drfilter,tp,LOCATION_DECK,0,1,1,nil)
		if g:GetCount()>0 then
			-- 将选中的怪兽加入手牌
			Duel.SendtoHand(g,nil,REASON_EFFECT)
			-- 确认对方看到加入手牌的卡
			Duel.ConfirmCards(1-tp,g)
			-- 获取当前回合玩家
			local turnp=Duel.GetTurnPlayer()
			-- 获取当前回合玩家的手牌组
			local tg1=Duel.GetFieldGroup(turnp,LOCATION_HAND,0)
			-- 获取非当前回合玩家的手牌组
			local tg2=Duel.GetFieldGroup(1-turnp,LOCATION_HAND,0)
			if tg1:GetCount()<1 or tg2:GetCount()<1 then return end
			-- 中断当前效果处理
			Duel.BreakEffect()
			-- 洗切当前回合玩家的手牌
			Duel.ShuffleHand(turnp)
			-- 提示当前回合玩家选择要送去墓地的卡
			Duel.Hint(HINT_SELECTMSG,turnp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
			local tc1=tg1:Select(turnp,1,1,nil):GetFirst()
			-- 将选中的卡送去墓地
			Duel.SendtoGrave(tc1,REASON_EFFECT)
			-- 洗切非当前回合玩家的手牌
			Duel.ShuffleHand(1-turnp)
			-- 提示非当前回合玩家选择要送去墓地的卡
			Duel.Hint(HINT_SELECTMSG,1-turnp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
			local tc2=tg2:Select(1-turnp,1,1,nil):GetFirst()
			-- 将选中的卡送去墓地
			Duel.SendtoGrave(tc2,REASON_EFFECT)
		end
	end
end
-- 效果发动时的处理：支付1张手牌送去墓地作为费用
function c35998832.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否可以支付1张手牌作为费用
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsAbleToGraveAsCost,tp,LOCATION_HAND,0,1,nil) end
	-- 提示玩家选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 选择1张手牌送去墓地作为费用
	local g=Duel.SelectMatchingCard(tp,Card.IsAbleToGraveAsCost,tp,LOCATION_HAND,0,1,1,nil)
	-- 将选中的手牌送去墓地作为费用
	Duel.SendtoGrave(g,REASON_COST)
end
-- 效果发动时的处理：设置将自己加入手牌的操作信息
function c35998832.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsAbleToHand() end
	-- 设置操作信息：将自己加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,c,1,0,0)
end
-- 效果处理函数：将自己加入手牌
function c35998832.thop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 将自己加入手牌
		Duel.SendtoHand(c,nil,REASON_EFFECT)
	end
end
