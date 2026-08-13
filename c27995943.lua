--Dr.フランゲ
-- 效果：
-- 「科学快人博士」的效果1回合只能使用1次。
-- ①：这张卡召唤·特殊召唤成功的场合，支付500基本分才能发动。自己把卡组最上面的卡确认。那之后，确认的卡回到卡组最下面或给对方观看并加入手卡。加入手卡的场合，下次的自己抽卡阶段跳过。
function c27995943.initial_effect(c)
	-- 「科学快人博士」的效果1回合只能使用1次。①：这张卡召唤·特殊召唤成功的场合，支付500基本分才能发动。自己把卡组最上面的卡确认。那之后，确认的卡回到卡组最下面或给对方观看并加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,27995943)
	e1:SetCost(c27995943.cost)
	e1:SetTarget(c27995943.target)
	e1:SetOperation(c27995943.operation)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
end
-- 定义效果的发动代价函数：用于检查并支付500基本分。
function c27995943.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动前检查：判断玩家tp是否能支付500基本分作为发动代价。
	if chk==0 then return Duel.CheckLPCost(tp,500) end
	-- 实际支付500基本分。
	Duel.PayLPCost(tp,500)
end
-- 定义效果发动目标/可行条件函数：确认自己卡组是否有卡，确保卡组顶端有卡可确认，效果才能发动。
function c27995943.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动前检查：自己卡组的卡数量是否大于0（即有卡可确认）。
	if chk==0 then return Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)>0 end
end
-- 定义效果处理函数：确认卡组最上面的卡，由玩家选择将其放回卡组最下面或加入手卡；若加入手卡则追加跳过下次抽卡阶段的效果。
function c27995943.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取自己卡组最上面的1张卡（g）。
	local g=Duel.GetDecktopGroup(tp,1)
	-- 向自己玩家tp展示这张卡组顶的卡。
	Duel.ConfirmCards(tp,g)
	-- 若该卡不能加入手卡，或玩家选择‘是’（放回卡组最下面）时，执行放回分支；否则执行加入手卡分支。
	if not g:GetFirst():IsAbleToHand() or Duel.SelectYesNo(tp,aux.Stringid(27995943,0)) then  --"是否将确认的卡回到卡组最下面？"
		-- 将确认的卡移动到卡组最下面（放回卡组底）。
		Duel.MoveSequence(g:GetFirst(),SEQ_DECKBOTTOM)
	else
		-- 禁用自动洗切检查，避免系统因从卡组取出/加入手卡而自动洗切卡组或手卡。
		Duel.DisableShuffleCheck()
		-- 将确认的卡加入其持有者的手卡（nil表示回到持有者手卡），原因记为效果。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方玩家展示刚刚加入手卡的那张卡（给对方观看）。
		Duel.ConfirmCards(1-tp,g)
		-- 洗切玩家tp的手卡（因为加入了卡，需要重新排列手卡顺序）。
		Duel.ShuffleHand(tp)
		-- 加入手卡的场合，下次的自己抽卡阶段跳过。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		e1:SetTargetRange(1,0)
		e1:SetCode(EFFECT_SKIP_DP)
		-- 若当前正处于自己的抽卡阶段（即效果在抽卡阶段内发动），则将跳过抽卡阶段的效果重置推迟到下一次抽卡阶段，以确保“下次的自己抽卡阶段”被跳过。
		if Duel.GetTurnPlayer()==tp and Duel.GetCurrentPhase()==PHASE_DRAW then
			e1:SetReset(RESET_PHASE+PHASE_DRAW+RESET_SELF_TURN,2)
		else
			e1:SetReset(RESET_PHASE+PHASE_DRAW+RESET_SELF_TURN)
		end
		-- 将“跳过抽卡阶段”的效果注册给玩家tp，使其在后续生效。
		Duel.RegisterEffect(e1,tp)
	end
end
