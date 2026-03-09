--光の封札剣
-- 效果：
-- ①：对方手卡随机选1张里侧表示除外。这张卡的发动后，用对方回合计算的第4回合的对方准备阶段，那张卡回到对方手卡。
function c49587034.initial_effect(c)
	-- 效果原文内容：①：对方手卡随机选1张里侧表示除外。这张卡的发动后，用对方回合计算的第4回合的对方准备阶段，那张卡回到对方手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMING_END_PHASE)
	e1:SetTarget(c49587034.target)
	e1:SetOperation(c49587034.activate)
	c:RegisterEffect(e1)
end
-- 效果作用：检查对方手卡是否存在可除外的卡片，并设置操作信息为除外对方手卡的卡片。
function c49587034.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 规则层面操作：判断对方手卡是否存在至少1张可以除外的卡片。
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsAbleToRemove,tp,0,LOCATION_HAND,1,nil,tp,POS_FACEDOWN) end
	-- 规则层面操作：设置连锁处理信息，表示将要除外对方手卡的1张卡片。
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,1-tp,LOCATION_HAND)
end
-- 效果作用：检索对方手卡随机1张卡并除外，若成功则注册一个准备阶段触发的效果用于在第4回合将该卡送回手卡。
function c49587034.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 规则层面操作：获取对方手卡的所有卡片组成一个组。
	local g=Duel.GetFieldGroup(1-tp,LOCATION_HAND,0)
	local rs=g:RandomSelect(1-tp,1)
	local card=rs:GetFirst()
	if card==nil then return end
	-- 规则层面操作：执行将选定的卡片以里侧表示除外，并确认此效果为发动效果。
	if Duel.Remove(card,POS_FACEDOWN,REASON_EFFECT)>0 and e:IsHasType(EFFECT_TYPE_ACTIVATE) then
		-- 规则层面操作：获取当前游戏阶段。
		local ph=Duel.GetCurrentPhase()
		-- 规则层面操作：获取当前回合玩家。
		local cp=Duel.GetTurnPlayer()
		-- 效果原文内容：①：对方手卡随机选1张里侧表示除外。这张卡的发动后，用对方回合计算的第4回合的对方准备阶段，那张卡回到对方手卡。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetRange(LOCATION_REMOVED)
		e1:SetCode(EVENT_PHASE+PHASE_STANDBY)
		e1:SetCountLimit(1)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_STANDBY+RESET_SELF_TURN,4)
		e1:SetCondition(c49587034.thcon)
		e1:SetOperation(c49587034.thop)
		e1:SetLabel(1)
		card:RegisterEffect(e1)
		e:GetHandler():RegisterFlagEffect(1082946,RESET_PHASE+PHASE_END+RESET_SELF_TURN,0,3)
		c49587034[e:GetHandler()]=e1
	end
end
-- 效果作用：判断是否为当前玩家的准备阶段。
function c49587034.thcon(e,tp,eg,ep,ev,re,r,rp)
	-- 规则层面操作：判断当前回合玩家是否等于效果持有者。
	return Duel.GetTurnPlayer()==tp
end
-- 效果作用：处理准备阶段触发的效果，记录回合计数器，当达到第4回合时将卡片送回手卡。
function c49587034.thop(e,tp,eg,ep,ev,re,r,rp)
	local ct=e:GetLabel()
	e:GetOwner():SetTurnCounter(ct)
	if ct==4 then
		-- 规则层面操作：将该卡片以效果原因送回对方手卡。
		Duel.SendtoHand(e:GetHandler(),nil,REASON_EFFECT)
		e:GetOwner():ResetFlagEffect(1082946)
	else
		e:SetLabel(ct+1)
	end
end
