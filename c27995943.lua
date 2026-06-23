--Dr.フランゲ
-- 效果：
-- 「科学快人博士」的效果1回合只能使用1次。
-- ①：这张卡召唤·特殊召唤成功的场合，支付500基本分才能发动。自己把卡组最上面的卡确认。那之后，确认的卡回到卡组最下面或给对方观看并加入手卡。加入手卡的场合，下次的自己抽卡阶段跳过。
function c27995943.initial_effect(c)
	-- 创建一个诱发选发效果，用于处理通常召唤成功时的触发条件
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
-- 支付500基本分的费用处理函数
function c27995943.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家是否能支付500基本分
	if chk==0 then return Duel.CheckLPCost(tp,500) end
	-- 让玩家支付500基本分
	Duel.PayLPCost(tp,500)
end
-- 效果的发动条件判断函数
function c27995943.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家卡组是否至少有1张卡
	if chk==0 then return Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)>0 end
end
-- 效果的主要处理函数，包含卡组顶牌确认与后续操作
function c27995943.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取玩家卡组最上方的1张卡
	local g=Duel.GetDecktopGroup(tp,1)
	-- 给玩家确认这些卡
	Duel.ConfirmCards(tp,g)
	-- 判断是否将确认的卡回到卡组最下面，或选择加入手卡
	if not g:GetFirst():IsAbleToHand() or Duel.SelectYesNo(tp,aux.Stringid(27995943,0)) then  --"是否将确认的卡回到卡组最下面？"
		-- 将确认的卡移至卡组最下方
		Duel.MoveSequence(g:GetFirst(),SEQ_DECKBOTTOM)
	else
		-- 禁用后续操作的洗卡检测
		Duel.DisableShuffleCheck()
		-- 将确认的卡以效果原因送入手卡
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 给对方确认这些卡
		Duel.ConfirmCards(1-tp,g)
		-- 手动洗切玩家的手卡
		Duel.ShuffleHand(tp)
		-- 创建一个影响玩家的永续效果，用于跳过下次抽卡阶段
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		e1:SetTargetRange(1,0)
		e1:SetCode(EFFECT_SKIP_DP)
		-- 判断当前是否为玩家的抽卡阶段
		if Duel.GetTurnPlayer()==tp and Duel.GetCurrentPhase()==PHASE_DRAW then
			e1:SetReset(RESET_PHASE+PHASE_DRAW+RESET_SELF_TURN,2)
		else
			e1:SetReset(RESET_PHASE+PHASE_DRAW+RESET_SELF_TURN)
		end
		-- 将效果注册给玩家，使其生效
		Duel.RegisterEffect(e1,tp)
	end
end
