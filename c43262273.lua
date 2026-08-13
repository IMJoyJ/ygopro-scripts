--紅蓮の指名者
-- 效果：
-- ①：支付2000基本分，把手卡全部给对方观看才能发动。把对方手卡确认，从那之中选1张直到下次的对方结束阶段除外。
function c43262273.initial_effect(c)
	-- ①：支付2000基本分，把手卡全部给对方观看才能发动。把对方手卡确认，从那之中选1张直到下次的对方结束阶段除外。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMING_TOHAND)
	e1:SetCost(c43262273.cost)
	e1:SetTarget(c43262273.target)
	e1:SetOperation(c43262273.activate)
	c:RegisterEffect(e1)
end
-- 发动代价判定函数：检查能否支付2000基本分、自己手牌存在且没有已公开的手牌，满足则返回true。
function c43262273.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在效果发动合法性检查时，确认玩家能支付2000基本分，且自己手牌区存在手牌。
	if chk==0 then return Duel.CheckLPCost(tp,2000) and Duel.GetFieldGroupCount(tp,LOCATION_HAND,0)~=0
		-- 并且不存在已公开的手牌，因为需要把手卡全部给对方观看，若有公开手牌则不符合“全部”观看的条件。
		and not Duel.IsExistingMatchingCard(Card.IsPublic,tp,LOCATION_HAND,0,1,nil) end
	-- 支付2000基本分作为发动代价。
	Duel.PayLPCost(tp,2000)
	-- 获取己方手牌的全部卡作为一个组。
	local g=Duel.GetFieldGroup(tp,LOCATION_HAND,0)
	-- 将自己手牌全部给对方玩家确认。
	Duel.ConfirmCards(1-tp,g)
	-- 确认后洗切自己的手牌，以掩盖手牌顺序。
	Duel.ShuffleHand(tp)
end
-- 发动时选择对象的条件判定：确认对方手牌存在且其中有能够被除外的卡。
function c43262273.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 效果发动合法性检查：确认对方手牌区存在手牌。
	if chk==0 then return Duel.GetFieldGroupCount(tp,0,LOCATION_HAND)~=0
		-- 且对方手牌中存在至少1张可以除外的卡。
		and Duel.IsExistingMatchingCard(Card.IsAbleToRemove,tp,0,LOCATION_HAND,1,nil) end
	-- 设置效果处理信息：本效果为除外效果，处理时将从对方手牌除外1张卡。
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,0,1-tp,LOCATION_HAND)
end
-- 效果处理：确认对方手牌，从中选择1张除外，并设置其在下次对方结束阶段返回手牌的效果，最后洗切对方手牌。
function c43262273.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取对方手牌的所有卡作为一个组。
	local g0=Duel.GetFieldGroup(tp,0,LOCATION_HAND)
	-- 让自己确认对方的手牌内容。
	Duel.ConfirmCards(tp,g0)
	-- 从对方手牌中筛选出所有能够被除外的卡，组成候选组。
	local g=Duel.GetMatchingGroup(Card.IsAbleToRemove,tp,0,LOCATION_HAND,nil)
	if g:GetCount()>0 then
		-- 提示玩家选择要除外的卡，显示“请选择要除外的卡”。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
		local sg=g:Select(tp,1,1,nil)
		local tc=sg:GetFirst()
		-- 将选中的卡以表侧表示除外，除外原因为效果。
		Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)
		tc:RegisterFlagEffect(43262273,RESET_EVENT+RESETS_STANDARD,0,1)
		-- 直到下次的对方结束阶段除外。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_PHASE+PHASE_END)
		e1:SetCountLimit(1)
		-- 如果当前正处于对方结束阶段（即发动时点在对方结束阶段），则对返回效果进行特殊计时处理。
		if Duel.GetTurnPlayer()==1-tp and Duel.GetCurrentPhase()==PHASE_END then
			-- 记录当前回合数，用于在后续条件中判断是否已经过了一个回合，避免在同一结束阶段立即返回。
			e1:SetLabel(Duel.GetTurnCount())
			e1:SetReset(RESET_PHASE+PHASE_END+RESET_OPPO_TURN,2)
		else
			e1:SetLabel(0)
			e1:SetReset(RESET_PHASE+PHASE_END+RESET_OPPO_TURN)
		end
		e1:SetLabelObject(tc)
		e1:SetCondition(c43262273.retcon)
		e1:SetOperation(c43262273.retop)
		-- 将返回效果注册为场上持续效果，使其在结束阶段被检测并触发。
		Duel.RegisterEffect(e1,tp)
	end
	-- 处理完选择后，洗切对方的手牌。
	Duel.ShuffleHand(1-tp)
end
-- 返回效果的触发条件：若除外的卡已不在除外状态则重置本效果；否则仅在到达下次对方结束阶段时允许发动返回。
function c43262273.retcon(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	if tc:GetFlagEffect(43262273)==0 then
		e:Reset()
		return false
	else
		-- 满足“当前是对方回合的结束阶段，且当前回合数不等于记录标签”（即已到下次对方结束阶段）时返回true，触发返回。
		return Duel.GetTurnPlayer()==1-tp and Duel.GetTurnCount()~=e:GetLabel()
	end
end
-- 返回效果的处理：将被除外的卡返回对方手牌。
function c43262273.retop(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	-- 将被除外的卡以效果原因返回持有者（对方）的手牌。
	Duel.SendtoHand(tc,1-tp,REASON_EFFECT)
end
