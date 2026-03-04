--フロント・オブザーバー
-- 效果：
-- ①：这张卡召唤成功的回合的结束阶段才能发动。从卡组把1只地属性灵摆怪兽加入手卡。
-- ②：这张卡召唤成功的场合，下次的自己回合的结束阶段，把这张卡解放才能发动。从卡组把1只地属性怪兽加入手卡。
function c12451640.initial_effect(c)
	-- ①：这张卡召唤成功的回合的结束阶段才能发动。从卡组把1只地属性灵摆怪兽加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetOperation(c12451640.regop)
	c:RegisterEffect(e1)
end
-- 效果作用：在通常召唤成功时触发，注册后续效果
function c12451640.regop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- ②：这张卡召唤成功的场合，下次的自己回合的结束阶段，把这张卡解放才能发动。从卡组把1只地属性怪兽加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(12451640,0))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_PHASE+PHASE_END)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetTarget(c12451640.thtg1)
	e1:SetOperation(c12451640.thop1)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD-RESET_TURN_SET+RESET_PHASE+PHASE_END)
	c:RegisterEffect(e1)
	-- 效果作用：注册第二个效果，条件为下次自己回合结束阶段且需要解放自身
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(12451640,1))
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_PHASE+PHASE_END)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(c12451640.thcon)
	e2:SetCost(c12451640.thcost)
	e2:SetTarget(c12451640.thtg2)
	e2:SetOperation(c12451640.thop2)
	-- 记录当前回合数，用于判断是否为下次自己的回合
	e2:SetLabel(Duel.GetTurnCount())
	-- 判断当前回合是否为效果持有者回合
	if Duel.GetTurnPlayer()==tp then
		e2:SetReset(RESET_EVENT+RESETS_STANDARD-RESET_TURN_SET+RESET_PHASE+PHASE_END+RESET_SELF_TURN,2)
	else
		e2:SetReset(RESET_EVENT+RESETS_STANDARD-RESET_TURN_SET+RESET_PHASE+PHASE_END+RESET_SELF_TURN)
	end
	c:RegisterEffect(e2)
end
-- 过滤函数：筛选地属性灵摆怪兽
function c12451640.filter1(c)
	return c:IsType(TYPE_PENDULUM) and c:IsAttribute(ATTRIBUTE_EARTH) and c:IsAbleToHand()
end
-- 效果目标函数：检查是否能从卡组检索地属性灵摆怪兽
function c12451640.thtg1(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否存在满足条件的灵摆怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c12451640.filter1,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息：准备从卡组检索一张卡加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果处理函数：执行检索并加入手牌
function c12451640.thop1(e,tp,eg,ep,ev,re,r,rp)
	-- 提示选择：提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	-- 选择满足条件的卡：从卡组选择一张地属性灵摆怪兽
	local g=Duel.SelectMatchingCard(tp,c12451640.filter1,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡送入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 确认对方看到选中的卡
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 效果触发条件函数：判断是否为自己的回合且不是本回合
function c12451640.thcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前回合玩家是否为效果持有者且回合数不等于记录值
	return Duel.GetTurnPlayer()==tp and Duel.GetTurnCount()~=e:GetLabel()
end
-- 效果费用函数：支付解放自身作为费用
function c12451640.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsReleasable() end
	-- 执行解放操作
	Duel.Release(e:GetHandler(),REASON_COST)
end
-- 过滤函数：筛选地属性怪兽
function c12451640.filter2(c)
	return c:IsAttribute(ATTRIBUTE_EARTH) and c:IsAbleToHand()
end
-- 效果目标函数：检查是否能从卡组检索地属性怪兽
function c12451640.thtg2(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否存在满足条件的地属性怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c12451640.filter2,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息：准备从卡组检索一张卡加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果处理函数：执行检索并加入手牌
function c12451640.thop2(e,tp,eg,ep,ev,re,r,rp)
	-- 提示选择：提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	-- 选择满足条件的卡：从卡组选择一张地属性怪兽
	local g=Duel.SelectMatchingCard(tp,c12451640.filter2,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡送入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 确认对方看到选中的卡
		Duel.ConfirmCards(1-tp,g)
	end
end
