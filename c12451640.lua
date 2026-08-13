--フロント・オブザーバー
-- 效果：
-- ①：这张卡召唤成功的回合的结束阶段才能发动。从卡组把1只地属性灵摆怪兽加入手卡。
-- ②：这张卡召唤成功的场合，下次的自己回合的结束阶段，把这张卡解放才能发动。从卡组把1只地属性怪兽加入手卡。
function c12451640.initial_effect(c)
	-- ①：这张卡召唤成功的回合的结束阶段才能发动。从卡组把1只地属性灵摆怪兽加入手卡。②：这张卡召唤成功的场合，下次的自己回合的结束阶段，把这张卡解放才能发动。从卡组把1只地属性怪兽加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetOperation(c12451640.regop)
	c:RegisterEffect(e1)
end
-- 召唤成功时，为这张卡注册两个效果：①在当前回合结束阶段可发动，从卡组把1只地属性灵摆怪兽加入手卡；②在下一次自己的回合的结束阶段可解放自身，从卡组把1只地属性怪兽加入手卡。
function c12451640.regop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- ①：这张卡召唤成功的回合的结束阶段才能发动。从卡组把1只地属性灵摆怪兽加入手卡。
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
	-- ②：这张卡召唤成功的场合，下次的自己回合的结束阶段，把这张卡解放才能发动。从卡组把1只地属性怪兽加入手卡。
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
	-- 将召唤成功时的回合数记录到效果e2的标签中，用于判断是否已到下一次自己的回合（当前回合数与之不同且为自身回合）。
	e2:SetLabel(Duel.GetTurnCount())
	-- 判断当前回合玩家是否为这张卡的控制者（即召唤成功时是否为自己回合）；若是，则e2需经过两次自己回合结束阶段才重置，以确保能覆盖到下一次自己的结束阶段；否则只需一次。
	if Duel.GetTurnPlayer()==tp then
		e2:SetReset(RESET_EVENT+RESETS_STANDARD-RESET_TURN_SET+RESET_PHASE+PHASE_END+RESET_SELF_TURN,2)
	else
		e2:SetReset(RESET_EVENT+RESETS_STANDARD-RESET_TURN_SET+RESET_PHASE+PHASE_END+RESET_SELF_TURN)
	end
	c:RegisterEffect(e2)
end
-- 过滤出卡组中地属性、灵摆怪兽且可以被加入手卡的卡片。
function c12451640.filter1(c)
	return c:IsType(TYPE_PENDULUM) and c:IsAttribute(ATTRIBUTE_EARTH) and c:IsAbleToHand()
end
-- 效果①的发动条件与操作信息设置：在发动时确认卡组存在符合条件的卡，并设置效果处理时将从卡组把1张卡加入手卡。
function c12451640.thtg1(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在效果发动时（chk==0）检查卡组是否存在至少1张满足filter1的卡片，作为该效果可发动的条件。
	if chk==0 then return Duel.IsExistingMatchingCard(c12451640.filter1,tp,LOCATION_DECK,0,1,nil) end
	-- 设置本次效果处理的操作信息：将把1张卡从卡组加入手卡（目标数量为1，目标位置为卡组，目标玩家为己方），供连锁判定等使用。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果①的实际处理：从卡组选择1只满足条件的地属性灵摆怪兽，加入持有者手卡，并让对手确认。
function c12451640.thop1(e,tp,eg,ep,ev,re,r,rp)
	-- 给玩家显示选择提示：请选择要加入手牌的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从卡组选择1张满足filter1的卡片（自动过滤出地属性灵摆怪兽）。
	local g=Duel.SelectMatchingCard(tp,c12451640.filter1,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选择的卡以效果原因加入持有者手卡。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 让对手确认这张加入手卡的卡片。
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 效果②的发动条件：当前回合玩家是自己，且当前回合数不等于召唤成功时记录下的回合数，即必须是在下一次自己的回合（结束阶段）才能发动。
function c12451640.thcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前回合是否为自己回合，且当前回合数是执行过召唤后的另一个自己回合（回合数变化），从而确保是“下次的自己回合”。
	return Duel.GetTurnPlayer()==tp and Duel.GetTurnCount()~=e:GetLabel()
end
-- 效果②的发动代价：解放这张卡；代价确认时检查这张卡是否可以被解放。
function c12451640.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsReleasable() end
	-- 将这张卡解放作为发动效果②的代价。
	Duel.Release(e:GetHandler(),REASON_COST)
end
-- 过滤出卡组中地属性且可以被加入手卡的怪兽（不限灵摆）。
function c12451640.filter2(c)
	return c:IsAttribute(ATTRIBUTE_EARTH) and c:IsAbleToHand()
end
-- 效果②的发动条件与操作信息设置：检查卡组中存在地属性怪兽，并设置效果处理时将从卡组把1张卡加入手卡。
function c12451640.thtg2(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在效果发动时（chk==0）检查卡组是否存在至少1只满足filter2的地属性怪兽，作为该效果可发动的条件。
	if chk==0 then return Duel.IsExistingMatchingCard(c12451640.filter2,tp,LOCATION_DECK,0,1,nil) end
	-- 设置本次效果处理的操作信息：将把1张卡从卡组加入手卡（目标数量为1，目标位置为卡组）。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果②的实际处理：从卡组选择1只地属性怪兽，加入持有者手卡，并让对手确认。
function c12451640.thop2(e,tp,eg,ep,ev,re,r,rp)
	-- 给玩家显示选择提示：请选择要加入手牌的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从卡组选择1张满足filter2的卡片（地属性怪兽）。
	local g=Duel.SelectMatchingCard(tp,c12451640.filter2,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选择的卡以效果原因加入持有者手卡。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 让对手确认这张加入手卡的卡片。
		Duel.ConfirmCards(1-tp,g)
	end
end
