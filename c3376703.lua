--アルカナフォースⅤ－THE HIEROPHANT
-- 效果：
-- ①：把这张卡从手卡丢弃才能发动。这个回合，在自己场上有「秘仪之力」怪兽召唤·反转召唤·特殊召唤时对方不能把效果发动。
-- ②：这张卡召唤·反转召唤·特殊召唤的场合发动。进行1次投掷硬币，那个里表的以下效果适用。
-- ●表：同名怪兽不在自己的场上·墓地存在的1只4星以下的「秘仪之力」怪兽从卡组特殊召唤。
-- ●里：从卡组把1只「秘仪之力」怪兽在对方场上特殊召唤。
local s,id,o=GetID()
-- 初始化卡片效果，注册两个效果：①丢弃手牌发动，限制对方效果发动；②召唤/特殊召唤时投掷硬币决定特殊召唤效果
function s.initial_effect(c)
	-- 记录该卡与编号73206827的卡为同名卡
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
-- 支付丢弃手牌的代价
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsDiscardable() end
	-- 将此卡送去墓地作为代价
	Duel.SendtoGrave(c,REASON_COST+REASON_DISCARD)
end
-- 判断是否已发动过效果①
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 若未发动过效果①则可以发动
	if chk==0 then return Duel.GetFlagEffect(tp,id)==0 end
end
-- 效果①的发动处理，注册标识效果并注册连锁限制效果
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 注册一个回合内只能发动一次的效果标识
	Duel.RegisterFlagEffect(tp,id,RESET_PHASE+PHASE_END,0,1)
	-- 注册当自己场上召唤/反转召唤/特殊召唤怪兽时触发的连锁限制效果
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCondition(s.limcon)
	e1:SetOperation(s.limop)
	-- 注册召唤成功时的连锁限制效果
	Duel.RegisterEffect(e1,tp)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	-- 注册反转召唤成功时的连锁限制效果
	Duel.RegisterEffect(e2,tp)
	local e3=e1:Clone()
	e3:SetCode(EVENT_FLIP_SUMMON_SUCCESS)
	-- 注册特殊召唤成功时的连锁限制效果
	Duel.RegisterEffect(e3,tp)
	-- 注册连锁结束时的连锁限制效果
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e4:SetCode(EVENT_CHAIN_END)
	e4:SetOperation(s.limop2)
	-- 注册连锁结束时的连锁限制效果
	Duel.RegisterEffect(e4,tp)
end
-- 判断是否为「秘仪之力」怪兽
function s.limfilter(c,tp)
	return c:IsControler(tp) and c:IsFaceup() and c:IsSetCard(0x5)
end
-- 判断是否为「秘仪之力」怪兽
function s.limcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.limfilter,1,nil,tp)
end
-- 连锁限制效果的处理，根据当前连锁序号设置连锁限制
function s.limop(e,tp,eg,ep,ev,re,r,rp)
	-- 当前连锁为0时，设置连锁限制
	if Duel.GetCurrentChain()==0 then
		-- 设置连锁限制直到连锁结束
		Duel.SetChainLimitTillChainEnd(s.chainlm)
	-- 当前连锁为1时，注册标识并设置连锁重置效果
	elseif Duel.GetCurrentChain()==1 then
		-- 注册一个用于连锁重置的标识效果
		Duel.RegisterFlagEffect(tp,id+o,RESET_EVENT+RESETS_STANDARD,0,1)
		-- 注册连锁中触发效果
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_CHAINING)
		e1:SetOperation(s.resetop)
		-- 注册连锁中触发效果
		Duel.RegisterEffect(e1,tp)
		local e2=e1:Clone()
		e2:SetCode(EVENT_BREAK_EFFECT)
		e2:SetReset(RESET_CHAIN)
		-- 注册连锁中触发效果
		Duel.RegisterEffect(e2,tp)
	end
end
-- 重置标识效果并重置效果
function s.resetop(e,tp,eg,ep,ev,re,r,rp)
	-- 重置标识效果
	Duel.ResetFlagEffect(tp,id+o)
	e:Reset()
end
-- 连锁结束时处理连锁限制
function s.limop2(e,tp,eg,ep,ev,re,r,rp)
	-- 若标识效果存在则设置连锁限制
	if Duel.GetFlagEffect(tp,id+o)~=0 then
		-- 设置连锁限制直到连锁结束
		Duel.SetChainLimitTillChainEnd(s.chainlm)
	end
	-- 重置标识效果
	Duel.ResetFlagEffect(tp,id+o)
end
-- 连锁限制函数，仅允许自己发动
function s.chainlm(e,rp,tp)
	return tp==rp
end
-- 设置投掷硬币的操作信息
function s.cointg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置投掷硬币的操作信息
	Duel.SetOperationInfo(0,CATEGORY_COIN,nil,0,tp,1)
end
-- 筛选满足条件的4星以下「秘仪之力」怪兽
function s.spfilter(c,e,tp)
	return c:IsSetCard(0x5) and c:IsLevelBelow(4) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		-- 确保同名怪兽不在场上或墓地
		and not Duel.IsExistingMatchingCard(aux.AND(Card.IsFaceup,Card.IsCode),tp,LOCATION_MZONE+LOCATION_GRAVE,0,1,nil,c:GetCode())
end
-- 筛选满足条件的「秘仪之力」怪兽
function s.spfilter2(c,e,tp)
	return c:IsSetCard(0x5) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP,1-tp)
end
-- 投掷硬币后根据结果选择特殊召唤
function s.coinop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local res=-1
	-- 判断是否被效果73206827影响
	if Duel.IsPlayerAffectedByEffect(tp,73206827) then
		-- 判断自己卡组是否有满足条件的怪兽
		local b1=Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp)
		-- 判断对方卡组是否有满足条件的怪兽
		local b2=Duel.GetLocationCount(1-tp,LOCATION_MZONE)>0 and Duel.IsExistingMatchingCard(s.spfilter2,tp,LOCATION_DECK,0,1,nil,e,tp)
		if b1 and not b2 then
			-- 提示对方选择了表侧效果
			Duel.Hint(HINT_OPSELECTED,1-tp,60)
			res=1
		end
		if b2 and not b1 then
			-- 提示对方选择了里侧效果
			Duel.Hint(HINT_OPSELECTED,1-tp,61)
			res=0
		end
		if b1 and b2 then
			-- 选择效果选项
			res=aux.SelectFromOptions(tp,
				{b1,60,1},
				{b2,61,0})
		end
	else
		-- 投掷硬币
		res=Duel.TossCoin(tp,1)
	end
	if res==1 then
		-- 判断是否能特殊召唤
		if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
		-- 提示选择要特殊召唤的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 选择满足条件的卡
		local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
		if g:GetCount()>0 then
			-- 特殊召唤选择的卡
			Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
		end
	elseif res==0 then
		-- 判断是否能特殊召唤
		if Duel.GetLocationCount(1-tp,LOCATION_MZONE)<=0 then return end
		-- 提示选择要特殊召唤的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 选择满足条件的卡
		local g=Duel.SelectMatchingCard(tp,s.spfilter2,tp,LOCATION_DECK,0,1,1,nil,e,tp)
		if g:GetCount()>0 then
			-- 特殊召唤选择的卡
			Duel.SpecialSummon(g,0,tp,1-tp,false,false,POS_FACEUP)
		end
	end
end
