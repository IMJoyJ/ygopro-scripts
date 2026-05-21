--解放のアリアドネ
-- 效果：
-- ←3 【灵摆】 3→
-- ①：只要这张卡在灵摆区域存在，以下效果适用。
-- ●自己要为反击陷阱卡发动而支付的基本分变成不需要。
-- ●自己要为反击陷阱卡发动而丢弃的手卡变成不需要。
-- 【怪兽效果】
-- ①：这张卡被战斗·效果破坏的场合才能发动。从卡组把3张反击陷阱卡给对方观看，对方从那之中选1张。那1张卡加入自己手卡，剩余回到卡组。
function c98301564.initial_effect(c)
	-- 为卡片注册灵摆怪兽属性（灵摆召唤、灵摆卡的发动）。
	aux.EnablePendulumAttribute(c)
	-- ●自己要为反击陷阱卡发动而支付的基本分变成不需要。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_LPCOST_CHANGE)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetRange(LOCATION_PZONE)
	e2:SetTargetRange(1,0)
	e2:SetValue(c98301564.costchange)
	c:RegisterEffect(e2)
	-- ●自己要为反击陷阱卡发动而丢弃的手卡变成不需要。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_DISCARD_COST_CHANGE)
	e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e3:SetRange(LOCATION_PZONE)
	e3:SetTargetRange(1,0)
	c:RegisterEffect(e3)
	-- ①：这张卡被战斗·效果破坏的场合才能发动。从卡组把3张反击陷阱卡给对方观看，对方从那之中选1张。那1张卡加入自己手卡，剩余回到卡组。
	local e4=Effect.CreateEffect(c)
	e4:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_DESTROYED)
	e4:SetProperty(EFFECT_FLAG_DELAY)
	e4:SetCondition(c98301564.regcon)
	e4:SetTarget(c98301564.regtg)
	e4:SetOperation(c98301564.regop)
	c:RegisterEffect(e4)
end
-- 判断发动效果的卡是否为反击陷阱卡，若是则将需要支付的生命值代价改变为0。
function c98301564.costchange(e,re,rp,val)
	if re and (re:IsHasType(EFFECT_TYPE_ACTIVATE) or re:GetCode()==EFFECT_TRAP_ACT_IN_HAND or re:GetCode()==EFFECT_TRAP_ACT_IN_SET_TURN) and re:GetHandler():IsType(TYPE_TRAP) and re:GetHandler():IsType(TYPE_COUNTER) then
		return 0
	else
		return val
	end
end
-- 判断卡片是否因战斗或效果被破坏，作为效果发动的条件。
function c98301564.regcon(e,tp,eg,ep,ev,re,r,rp)
	return bit.band(r,REASON_EFFECT+REASON_BATTLE)~=0
end
-- 过滤卡组中可以加入手牌的反击陷阱卡。
function c98301564.cfilter(c)
	return c:IsType(TYPE_TRAP) and c:IsType(TYPE_COUNTER) and c:IsAbleToHand()
end
-- 效果发动的靶向/检测函数，检查卡组中是否存在至少3张反击陷阱卡，并设置检索并加入手牌的操作信息。
function c98301564.regtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在效果发动阶段，检查自己卡组中是否存在至少3张满足条件的反击陷阱卡。
	if chk==0 then return Duel.IsExistingMatchingCard(c98301564.cfilter,tp,LOCATION_DECK,0,3,nil) end
	-- 设置当前连锁的操作信息，表示该效果包含从卡组将1张卡加入手牌的操作。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,0,LOCATION_DECK)
end
-- 效果处理函数，从卡组选3张反击陷阱卡给对方确认，由对方选择1张加入自己手牌，其余回到卡组。
function c98301564.regop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取自己卡组中所有满足条件的反击陷阱卡。
	local g=Duel.GetMatchingGroup(c98301564.cfilter,tp,LOCATION_DECK,0,nil)
	if g:GetCount()>=3 then
		-- 提示自己玩家选择要展示给对方的卡片。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
		local sg=g:Select(tp,3,3,nil)
		-- 将选出的3张卡给对方玩家确认。
		Duel.ConfirmCards(1-tp,sg)
		-- 提示对方玩家选择要加入自己手牌的卡片。
		Duel.Hint(HINT_SELECTMSG,1-tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
		local tg=sg:Select(1-tp,1,1,nil)
		tg:GetFirst():SetStatus(STATUS_TO_HAND_WITHOUT_CONFIRM,true)
		-- 将对方选择的1张卡因效果加入自己手牌。
		Duel.SendtoHand(tg,nil,REASON_EFFECT)
	end
end
