--アルカナフォースⅤ－THE HIEROPHANT
-- 效果：
-- ①：把这张卡从手卡丢弃才能发动。这个回合，在自己场上有「秘仪之力」怪兽召唤·反转召唤·特殊召唤时对方不能把效果发动。
-- ②：这张卡召唤·反转召唤·特殊召唤的场合发动。进行1次投掷硬币，那个里表的以下效果适用。
-- ●表：同名怪兽不在自己的场上·墓地存在的1只4星以下的「秘仪之力」怪兽从卡组特殊召唤。
-- ●里：从卡组把1只「秘仪之力」怪兽在对方场上特殊召唤。
local s,id,o=GetID()
-- 初始化卡片效果：关联「光之结界」卡名，并注册①效果（丢弃自身封锁对方在「秘仪之力」怪兽召唤等时发动效果）与②效果（召唤·反转召唤·特殊召唤时掷硬币适用对应卡组特召效果）
function s.initial_effect(c)
	-- 在卡上记述「光之结界」的卡号，供相关效果检索与识别
	aux.AddCodeList(c,73206827)
	-- ①：把这张卡从手卡丢弃才能发动。这个回合，在自己场上有「秘仪之力」怪兽召唤·反转召唤·特殊召唤时对方不能把效果发动。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"对方不能把效果发动"
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
	-- ②：这张卡召唤·反转召唤·特殊召唤的场合发动。进行1次投掷硬币，那个里表的以下效果适用。 ●表：同名怪兽不在自己的场上·墓地存在的1只4星以下的「秘仪之力」怪兽从卡组特殊召唤。 ●里：从卡组把1只「秘仪之力」怪兽在对方场上特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"卡组特招"
	e2:SetCategory(CATEGORY_COIN+CATEGORY_SPECIAL_SUMMON+CATEGORY_DECKDES+CATEGORY_DECK_SPSUMMON)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:SetTarget(s.cointg)
	e2:SetOperation(s.coinop)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e3)
	local e4=e2:Clone()
	e4:SetCode(EVENT_FLIP_SUMMON_SUCCESS)
	c:RegisterEffect(e4)
end
s.toss_coin=true
-- ①效果的发动代价检查与支付：确认手卡中的这张卡可丢弃，并将其丢弃送去墓地
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsDiscardable() end
	-- 作为发动代价把手卡中的这张卡丢弃送去墓地
	Duel.SendtoGrave(c,REASON_COST+REASON_DISCARD)
end
-- ①效果的发动检测：确认己方本回合尚未适用过该效果
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动条件检查：确认己方本回合未注册过此卡的封锁标识
	if chk==0 then return Duel.GetFlagEffect(tp,id)==0 end
end
-- ①效果的处理流程：为己方注册本回合已使用标识，并注册监听召唤·反转召唤·特殊召唤及连锁结束的持续效果以限制对方连锁
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 为己方注册持续至回合结束的标识效果，防止本回合重复适用
	Duel.RegisterFlagEffect(tp,id,RESET_PHASE+PHASE_END,0,1)
	-- 这个回合，在自己场上有「秘仪之力」怪兽召唤·反转召唤·特殊召唤时对方不能把效果发动。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCondition(s.limcon)
	e1:SetOperation(s.limop)
	-- 注册监听己方场上「秘仪之力」怪兽特殊召唤成功的持续效果
	Duel.RegisterEffect(e1,tp)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	-- 注册监听己方场上「秘仪之力」怪兽通常召唤成功的持续效果
	Duel.RegisterEffect(e2,tp)
	local e3=e1:Clone()
	e3:SetCode(EVENT_FLIP_SUMMON_SUCCESS)
	-- 注册监听己方场上「秘仪之力」怪兽反转召唤成功的持续效果
	Duel.RegisterEffect(e3,tp)
	-- 在自己场上有「秘仪之力」怪兽召唤·反转召唤·特殊召唤时对方不能把效果发动。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e4:SetCode(EVENT_CHAIN_END)
	e4:SetOperation(s.limop2)
	-- 注册监听连锁串结束时点的持续效果，用于处理连锁1召唤成功后的连锁限制
	Duel.RegisterEffect(e4,tp)
end
-- 筛选条件：检查卡片是否为己方控制且表侧表示的「秘仪之力」怪兽
function s.limfilter(c,tp)
	return c:IsControler(tp) and c:IsFaceup() and c:IsSetCard(0x5)
end
-- 监听触发条件：确认本次召唤·反转召唤·特殊召唤的怪兽中存在己方表侧「秘仪之力」怪兽
function s.limcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.limfilter,1,nil,tp)
end
-- 封锁处理函数：若在连锁外召唤则直接限制对方连锁；若在连锁1处理中召唤则挂起待连锁串结束时检查并施加封锁
function s.limop(e,tp,eg,ep,ev,re,r,rp)
	-- 判断本次召唤等是否发生在连锁串之外（当前无正在处理的连锁）
	if Duel.GetCurrentChain()==0 then
		-- 设置连锁限制直至当前连锁串结束，禁止对方发动效果
		Duel.SetChainLimitTillChainEnd(s.chainlm)
	-- 判断本次召唤等是否发生在连锁1的效果处理中
	elseif Duel.GetCurrentChain()==1 then
		-- 为己方注册临时标识，标记本次在连锁1中有「秘仪之力」怪兽登场
		Duel.RegisterFlagEffect(tp,id+o,RESET_EVENT+RESETS_STANDARD,0,1)
		-- 在自己场上有「秘仪之力」怪兽召唤·反转召唤·特殊召唤时对方不能把效果发动。 ②：这张卡召唤·反转召唤·特殊召唤的场合发动。进行1次投掷硬币，那个里表的以下效果适用。 ●表：同名怪兽不在自己的场上·墓地存在的1只4星以下的「秘仪之力」怪兽从卡组特殊召唤。 ●里：从卡组把1只「秘仪之力」怪兽在对方场上特殊召唤。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_CHAINING)
		e1:SetOperation(s.resetop)
		-- 注册在出现新连锁时点时清除临时封锁标识的监听效果
		Duel.RegisterEffect(e1,tp)
		local e2=e1:Clone()
		e2:SetCode(EVENT_BREAK_EFFECT)
		e2:SetReset(RESET_CHAIN)
		-- 注册在BreakEffect时点清除临时封锁标识的监听效果，确保仅限于召唤成功时机有效
		Duel.RegisterEffect(e2,tp)
	end
end
-- 重置处理函数：若中间发生了其他连锁或效果中断，则清除临时封锁标识并销毁自身
function s.resetop(e,tp,eg,ep,ev,re,r,rp)
	-- 清除临时封锁标识，不再在连锁串结束时触发封锁
	Duel.ResetFlagEffect(tp,id+o)
	e:Reset()
end
-- 连锁串结束处理函数：若仍保留有临时封锁标识，则在连锁串结束后设置禁止对方连锁的限制并清除标识
function s.limop2(e,tp,eg,ep,ev,re,r,rp)
	-- 检查己方是否仍保有“连锁1召唤「秘仪之力」且后续未中断”的临时标识
	if Duel.GetFlagEffect(tp,id+o)~=0 then
		-- 设置连锁限制直至接下来的连锁串结束，禁止对方发动效果
		Duel.SetChainLimitTillChainEnd(s.chainlm)
	end
	-- 重置并清除该临时封锁标识
	Duel.ResetFlagEffect(tp,id+o)
end
-- 连锁限制条件函数：仅允许己方玩家进行连锁，禁止对方发动效果
function s.chainlm(e,rp,tp)
	return tp==rp
end
-- ②效果的发动检测与连锁信息设置：因必发诱发效果直接通过，并登记1次投掷硬币的操作信息
function s.cointg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 登记连锁的投掷硬币操作信息，预计投掷1次硬币
	Duel.SetOperationInfo(0,CATEGORY_COIN,nil,0,tp,1)
end
-- 筛选条件（硬币表）：检查卡片是否为4星以下、可特殊召唤的「秘仪之力」怪兽，且同名卡不在己方场上·墓地表侧存在
function s.spfilter(c,e,tp)
	return c:IsSetCard(0x5) and c:IsLevelBelow(4) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		-- 确认己方怪兽区和墓地中不存在表侧表示的同名怪兽
		and not Duel.IsExistingMatchingCard(aux.AND(Card.IsFaceup,Card.IsCode),tp,LOCATION_MZONE+LOCATION_GRAVE,0,1,nil,c:GetCode())
end
-- 筛选条件（硬币里）：检查卡片是否为「秘仪之力」怪兽且能以表侧表示特殊召唤到对方场上
function s.spfilter2(c,e,tp)
	return c:IsSetCard(0x5) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP,1-tp)
end
-- ②效果的处理流程：若「光之结界」生效则直接从可用的表/里分支中选择适用，否则投掷1次硬币；表时从卡组特召4星以下同名不在场墓的「秘仪之力」怪兽，里时从卡组特召1只「秘仪之力」怪兽到对方场上
function s.coinop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local res=-1
	-- 检测【光之结界】(73206827)的效果是否生效中。若在生效中，自己的「秘仪之力」怪兽的召唤·反转召唤·特殊召唤时发动的效果不进行投掷硬币而选里表的其中1个适用。
	if Duel.IsPlayerAffectedByEffect(tp,73206827) then
		-- 检查硬币“表”效果是否可执行：己方怪兽区有空位且卡组有满足条件的4星以下「秘仪之力」怪兽
		local b1=Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp)
		-- 检查硬币“里”效果是否可执行：对方怪兽区有空位且卡组有可特召到对方场上的「秘仪之力」怪兽
		local b2=Duel.GetLocationCount(1-tp,LOCATION_MZONE)>0 and Duel.IsExistingMatchingCard(s.spfilter2,tp,LOCATION_DECK,0,1,nil,e,tp)
		if b1 and not b2 then
			-- 向对方提示己方因「光之结界」直接选择了硬币“表”的效果
			Duel.Hint(HINT_OPSELECTED,1-tp,60)
			res=1
		end
		if b2 and not b1 then
			-- 向对方提示己方因「光之结界」直接选择了硬币“里”的效果
			Duel.Hint(HINT_OPSELECTED,1-tp,61)
			res=0
		end
		if b1 and b2 then
			-- 当表和里均可执行时，让己方选择适用“表”还是“里”的效果
			res=aux.SelectFromOptions(tp,
				{b1,60,1},
				{b2,61,0})
		end
	else
		-- 未受「光之结界」影响时，让己方投掷1次硬币决定正反面结果
		res=Duel.TossCoin(tp,1)
	end
	if res==1 then
		-- 硬币为表时，确认己方主要怪兽区是否有空位，若无空位则终止处理
		if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
		-- 向己方提示选择要特殊召唤到己方场上的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 让己方从己方卡组选择1只满足“表”效果条件的4星以下「秘仪之力」怪兽
		local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
		if g:GetCount()>0 then
			-- 将所选「秘仪之力」怪兽以表侧表示特殊召唤到己方场上
			Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
		end
	elseif res==0 then
		-- 硬币为里时，确认对方主要怪兽区是否有空位，若无空位则终止处理
		if Duel.GetLocationCount(1-tp,LOCATION_MZONE)<=0 then return end
		-- 向己方提示选择要特殊召唤到对方场上的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 让己方从己方卡组选择1只可特殊召唤到对方场上的「秘仪之力」怪兽
		local g=Duel.SelectMatchingCard(tp,s.spfilter2,tp,LOCATION_DECK,0,1,1,nil,e,tp)
		if g:GetCount()>0 then
			-- 将所选「秘仪之力」怪兽以表侧表示特殊召唤到对方场上
			Duel.SpecialSummon(g,0,tp,1-tp,false,false,POS_FACEUP)
		end
	end
end
