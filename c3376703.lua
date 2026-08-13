--アルカナフォースⅤ－THE HIEROPHANT
-- 效果：
-- ①：把这张卡从手卡丢弃才能发动。这个回合，在自己场上有「秘仪之力」怪兽召唤·反转召唤·特殊召唤时对方不能把效果发动。
-- ②：这张卡召唤·反转召唤·特殊召唤的场合发动。进行1次投掷硬币，那个里表的以下效果适用。
-- ●表：同名怪兽不在自己的场上·墓地存在的1只4星以下的「秘仪之力」怪兽从卡组特殊召唤。
-- ●里：从卡组把1只「秘仪之力」怪兽在对方场上特殊召唤。
local s,id,o=GetID()
-- 初始化效果注册：为手卡①效果注册起动效果；为②效果及其召唤/特殊召唤/反转召唤三个时点分别注册诱发效果。
function s.initial_effect(c)
	-- 把【光之结界】的卡号73206827登记到本卡的记载卡名列表中，供相关检索与判别使用。
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
	-- ②：这张卡召唤·反转召唤·特殊召唤的场合发动。进行1次投掷硬币，那个里表的以下效果适用。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"卡组特招"
	e2:SetCategory(CATEGORY_COIN+CATEGORY_SPECIAL_SUMMON+CATEGORY_DECKDES)
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
-- e1的代价函数：发动前检查手牌的这张卡能否作为代价丢弃，确认后将其从手卡丢弃为代价。
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsDiscardable() end
	-- 以代价加丢弃的理由将手牌的这张卡送入墓地，完成丢弃代价。
	Duel.SendtoGrave(c,REASON_COST+REASON_DISCARD)
end
-- e1的发动条件判定：没有操作对象；只要求本回合尚未使用过①效果，即对应flag为0时才能发动。
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查用flag：若己方存在本回合①效果已发动的标识，则不能发动；否则返回true。
	if chk==0 then return Duel.GetFlagEffect(tp,id)==0 end
end
-- e1的解决处理：登记本回合已使用的标识；在自己场上「秘仪之力」怪兽召唤/反转召唤/特殊召唤成功时设置连锁限制，使对方不能发动效果，并在连锁结束时处理维护。
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 给己方玩家注册1个结束阶段重置的flag(id)，用于记录本回合已发动过①效果。
	Duel.RegisterFlagEffect(tp,id,RESET_PHASE+PHASE_END,0,1)
	-- 这个回合，在自己场上有「秘仪之力」怪兽召唤·反转召唤·特殊召唤时对方不能把效果发动。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCondition(s.limcon)
	e1:SetOperation(s.limop)
	-- 将特殊召唤成功时触发限制的连续效果注册到该回合的场上环境，作用于己方。
	Duel.RegisterEffect(e1,tp)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	-- 将通常召唤成功时触发限制的连续效果注册到场上环境。
	Duel.RegisterEffect(e2,tp)
	local e3=e1:Clone()
	e3:SetCode(EVENT_FLIP_SUMMON_SUCCESS)
	-- 将反转召唤成功时触发限制的连续效果注册到场上环境。
	Duel.RegisterEffect(e3,tp)
	-- 这个回合，在自己场上有「秘仪之力」怪兽召唤·反转召唤·特殊召唤时对方不能把效果发动。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e4:SetCode(EVENT_CHAIN_END)
	e4:SetOperation(s.limop2)
	-- 注册一个连锁结束时处理的连续效果，用于在连锁结束后决定是否补设或清除限制。
	Duel.RegisterEffect(e4,tp)
end
-- 限制触发过滤器：判定怪兽是己方控制的表侧表示的「秘仪之力」怪兽。
function s.limfilter(c,tp)
	return c:IsControler(tp) and c:IsFaceup() and c:IsSetCard(0x5)
end
-- 触发条件：本次召唤/特殊召唤/反转召唤成功的怪兽中存在满足限制触发条件的「秘仪之力」怪兽。
function s.limcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.limfilter,1,nil,tp)
end
-- 限制处理：若当前不在连锁中，直接设置直到连锁结束的限制；若当前正处在第1个连锁中，则登记临时标识并监听后续连锁事件，以便在适当时候补设或清除限制。
function s.limop(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前是否没有正在处理的连锁，此时可直接施加对方不能把效果发动的连锁限制。
	if Duel.GetCurrentChain()==0 then
		-- 设置直到当前连锁结束为止的连锁限制条件，使对方无法再发动效果。
		Duel.SetChainLimitTillChainEnd(s.chainlm)
	-- 如果当前已经有1个连锁，例如召唤是由正在处理的效果导致的，则需要走特殊标记处理，不能简单地直接设限。
	elseif Duel.GetCurrentChain()==1 then
		-- 登记一个在标准离场或重置事件时清除的临时标识，用于记录这次召唤需要被施加限制的状态。
		Duel.RegisterFlagEffect(tp,id+o,RESET_EVENT+RESETS_STANDARD,0,1)
		-- ①：把这张卡从手卡丢弃才能发动。这个回合，在自己场上有「秘仪之力」怪兽召唤·反转召唤·特殊召唤时对方不能把效果发动。②：这张卡召唤·反转召唤·特殊召唤的场合发动。进行1次投掷硬币，那个里表的以下效果适用。●表：同名怪兽不在自己的场上·墓地存在的1只4星以下的「秘仪之力」怪兽从卡组特殊召唤。●里：从卡组把1只「秘仪之力」怪兽在对方场上特殊召唤。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_CHAINING)
		e1:SetOperation(s.resetop)
		-- 注册一个监听新的连锁发动的连续效果，用于在必要时清除临时标识，避免限制残留到错误的时点。
		Duel.RegisterEffect(e1,tp)
		local e2=e1:Clone()
		e2:SetCode(EVENT_BREAK_EFFECT)
		e2:SetReset(RESET_CHAIN)
		-- 注册一个监听效果处理中断或解除的连续效果，并让它在当前连锁结束时自动重置。
		Duel.RegisterEffect(e2,tp)
	end
end
-- 清除临时标识并让监听效果自身失效；用于新的连锁发生或效果中断时需要取消临时标记的场景。
function s.resetop(e,tp,eg,ep,ev,re,r,rp)
	-- 移除之前登记的临时标识(id+o)。
	Duel.ResetFlagEffect(tp,id+o)
	e:Reset()
end
-- 连锁结束后的收尾：若临时标识仍存在，则补设直到连锁结束的对方不能发动效果的限制；然后清除临时标识。
function s.limop2(e,tp,eg,ep,ev,re,r,rp)
	-- 判断临时标识是否仍然存在，存在才需要在此刻补设连锁限制。
	if Duel.GetFlagEffect(tp,id+o)~=0 then
		-- 补设直到连锁结束的连锁限制，只允许己方发动效果。
		Duel.SetChainLimitTillChainEnd(s.chainlm)
	end
	-- 无论是否补设限制，都清除临时标识，防止影响后续连锁。
	Duel.ResetFlagEffect(tp,id+o)
end
-- 连锁限制的实际判定：只有当前准备发动效果的一方为自己(tp)时放行，即对方不能把效果发动。
function s.chainlm(e,rp,tp)
	return tp==rp
end
-- ②效果的发动条件函数：召唤成功时必然可发动，不取对象；同时设置本次操作包含投掷硬币。
function s.cointg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 向系统登记本次效果处理含有投掷硬币操作，数量为1，供效果发动与连锁判定使用。
	Duel.SetOperationInfo(0,CATEGORY_COIN,nil,0,tp,1)
end
-- 表侧效果的特召对象过滤器：卡组里的「秘仪之力」、4星以下、可被特殊召唤，并且不存在同名卡在己方场上表侧表示或墓地。
function s.spfilter(c,e,tp)
	return c:IsSetCard(0x5) and c:IsLevelBelow(4) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		-- 追加排除条件：己方场上表侧表示或墓地已存在同名卡，即卡号相同，则该卡不能选为表侧效果对象。
		and not Duel.IsExistingMatchingCard(aux.AND(Card.IsFaceup,Card.IsCode),tp,LOCATION_MZONE+LOCATION_GRAVE,0,1,nil,c:GetCode())
end
-- 里侧效果的特召对象过滤器：卡组里的「秘仪之力」怪兽，且能够被己方表侧表示特殊召唤到对方场上。
function s.spfilter2(c,e,tp)
	return c:IsSetCard(0x5) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP,1-tp)
end
-- ②效果的结算：先判断是否受【光之结界】影响；若生效则不投硬币改由玩家选表或里，否则投1次硬币；随后按表或里分别从卡组特殊召唤到己方或对方场上。
function s.coinop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local res=-1
	-- 检测【光之结界】(73206827)的效果是否生效中。若在生效中，自己的「秘仪之力」怪兽的召唤·反转召唤·特殊召唤时发动的效果不进行投掷硬币而选里表的其中1个适用。
	if Duel.IsPlayerAffectedByEffect(tp,73206827) then
		-- 计算表侧选项是否可行：己方主怪兽区有空位且卡组中存在符合表侧条件的「秘仪之力」怪兽。
		local b1=Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp)
		-- 计算里侧选项是否可行：对方主怪兽区有空位且卡组中存在符合里侧条件的「秘仪之力」怪兽。
		local b2=Duel.GetLocationCount(1-tp,LOCATION_MZONE)>0 and Duel.IsExistingMatchingCard(s.spfilter2,tp,LOCATION_DECK,0,1,nil,e,tp)
		if b1 and not b2 then
			-- 向对方玩家提示己方选择了表侧效果，60为对应提示文本编号。
			Duel.Hint(HINT_OPSELECTED,1-tp,60)
			res=1
		end
		if b2 and not b1 then
			-- 向对方玩家提示己方选择了里侧效果，61为对应提示文本编号。
			Duel.Hint(HINT_OPSELECTED,1-tp,61)
			res=0
		end
		if b1 and b2 then
			-- 当表里两个选项都可行时，让己方玩家在这两个选项中选择一个，并记录结果：1为表，0为里。
			res=aux.SelectFromOptions(tp,
				{b1,60,1},
				{b2,61,0})
		end
	else
		-- 投掷1枚硬币，正面为1即表，反面为0即里，用随机结果决定适用表侧还是里侧效果。
		res=Duel.TossCoin(tp,1)
	end
	if res==1 then
		-- 己方怪兽区域没有可用空位时，表侧效果无法特殊召唤，直接终止后续处理。
		if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
		-- 弹出从卡组选择特殊召唤怪兽的提示信息，说明接下来要选择要特殊召唤的卡。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 从己方卡组中选择1张满足表侧条件的「秘仪之力」怪兽。
		local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
		if g:GetCount()>0 then
			-- 将选择的怪兽表侧表示特殊召唤到自己场上。
			Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
		end
	elseif res==0 then
		-- 对方怪兽区域没有可用空位时，里侧效果无法特殊召唤，直接终止后续处理。
		if Duel.GetLocationCount(1-tp,LOCATION_MZONE)<=0 then return end
		-- 弹出选择提示，让己方从卡组选择要特殊召唤到对方场上的「秘仪之力」怪兽。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 从己方卡组中选择1张满足里侧条件的「秘仪之力」怪兽。
		local g=Duel.SelectMatchingCard(tp,s.spfilter2,tp,LOCATION_DECK,0,1,1,nil,e,tp)
		if g:GetCount()>0 then
			-- 将选择的怪兽表侧表示特殊召唤到对方场上。
			Duel.SpecialSummon(g,0,tp,1-tp,false,false,POS_FACEUP)
		end
	end
end
