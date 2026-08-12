--王宮の重税
-- 效果：
-- 对方回合的准备阶段时才能发动。随机选择对方的1张手卡并确认。选择的卡或者同名卡直到下次自己的结束阶段结束时没有召唤或者发动的场合，给与对方基本分1000分伤害。有召唤或者发动的场合，自己受到1000分伤害。
function c86742443.initial_effect(c)
	-- 对方回合的准备阶段时才能发动。随机选择对方的1张手卡并确认。选择的卡或者同名卡直到下次自己的结束阶段结束时没有召唤或者发动的场合，给与对方基本分1000分伤害。有召唤或者发动的场合，自己受到1000分伤害。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(TIMING_STANDBY_PHASE)
	e1:SetCondition(c86742443.condition)
	e1:SetTarget(c86742443.target)
	e1:SetOperation(c86742443.operation)
	c:RegisterEffect(e1)
end
-- 定义发动条件函数，判断是否在对方回合的准备阶段。
function c86742443.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前阶段是否为准备阶段，且当前回合玩家为对方。
	return Duel.GetCurrentPhase()==PHASE_STANDBY and Duel.GetTurnPlayer()~=tp
end
-- 定义发动目标函数，确认对方手牌数量。
function c86742443.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动时，确认对方手牌中至少有1张卡。
	if chk==0 then return Duel.GetFieldGroupCount(1-tp,LOCATION_HAND,0)>0 end
end
-- 定义发动效果处理函数，随机确认对方1张手牌，并注册后续的检测与伤害效果。
function c86742443.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 若对方手牌数量为0，则不进行后续处理。
	if Duel.GetFieldGroupCount(1-tp,LOCATION_HAND,0)==0 then return end
	-- 从对方手牌中随机选择1张卡并获取卡片组。
	local g=Duel.GetFieldGroup(1-tp,LOCATION_HAND,0):RandomSelect(tp,1)
	local tc=g:GetFirst()
	-- 让己方玩家确认这张卡。
	Duel.ConfirmCards(tp,tc)
	-- 洗切对方的手牌。
	Duel.ShuffleHand(1-tp)
	local code=tc:GetCode()
	-- 选择的卡或者同名卡直到下次自己的结束阶段结束时没有召唤或者发动的场合，给与对方基本分1000分伤害。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_PHASE+PHASE_END)
	e1:SetCountLimit(1)
	e1:SetCondition(c86742443.damcon)
	e1:SetOperation(c86742443.damop)
	e1:SetLabel(0)
	e1:SetReset(RESET_PHASE+PHASE_END,2)
	-- 注册在结束阶段触发的延迟伤害效果。
	Duel.RegisterEffect(e1,tp)
	-- 有召唤或者发动的场合，自己受到1000分伤害。
	local e2=Effect.CreateEffect(e:GetHandler())
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:SetOperation(c86742443.damop2)
	e2:SetCountLimit(1)
	e2:SetLabelObject(e1)
	e2:SetLabel(code)
	e2:SetReset(RESET_PHASE+PHASE_END,2)
	-- 注册检测通常召唤成功的延迟伤害效果。
	Duel.RegisterEffect(e2,tp)
	-- 有召唤或者发动的场合，自己受到1000分伤害。
	local e3=Effect.CreateEffect(e:GetHandler())
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_CHAIN_SOLVING)
	e3:SetOperation(c86742443.damop3)
	e3:SetCountLimit(1)
	e3:SetLabelObject(e1)
	e3:SetLabel(code)
	e3:SetReset(RESET_PHASE+PHASE_END,2)
	-- 注册检测效果发动的延迟伤害效果。
	Duel.RegisterEffect(e3,tp)
end
-- 定义结束阶段伤害效果的触发条件函数。
function c86742443.damcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前是否为自己的回合，且被确认的卡或同名卡未被召唤或发动过。
	return Duel.GetTurnPlayer()==tp and e:GetLabel()==0
end
-- 定义结束阶段伤害效果的处理函数。
function c86742443.damop(e,tp,eg,ep,ev,re,r,rp)
	-- 给与对方1000分伤害。
	Duel.Damage(1-tp,1000,REASON_EFFECT)
end
-- 定义召唤成功时的伤害处理函数，若召唤了被确认的卡或同名卡，则自己受到伤害并标记已召唤。
function c86742443.damop2(e,tp,eg,ep,ev,re,r,rp)
	if eg:GetFirst():IsCode(e:GetLabel()) then
		-- 给与自己1000分伤害。
		Duel.Damage(tp,1000,REASON_EFFECT)
		e:GetLabelObject():SetLabel(1)
	end
end
-- 定义效果发动时的伤害处理函数，若发动了被确认的卡或同名卡，则自己受到伤害并标记已发动。
function c86742443.damop3(e,tp,eg,ep,ev,re,r,rp)
	if re:GetHandler():IsCode(e:GetLabel()) then
		-- 给与自己1000分伤害。
		Duel.Damage(tp,1000,REASON_EFFECT)
		e:GetLabelObject():SetLabel(1)
	end
end
