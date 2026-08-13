--スピードリフト
-- 效果：
-- ①：自己场上的怪兽只有调整1只的场合才能发动。从卡组把1只4星以下的「疾行机人」怪兽特殊召唤。在那次特殊召唤成功时双方不能把魔法·陷阱·怪兽的效果发动。
function c36730805.initial_effect(c)
	-- ①：自己场上的怪兽只有调整1只的场合才能发动。从卡组把1只4星以下的「疾行机人」怪兽特殊召唤。在那次特殊召唤成功时双方不能把魔法·陷阱·怪兽的效果发动。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCondition(c36730805.condition)
	e1:SetTarget(c36730805.target)
	e1:SetOperation(c36730805.activate)
	c:RegisterEffect(e1)
end
-- 发动条件判定：获取自己场上的怪兽，若怪兽数量不是1只则不能发动；那1只必须是表侧表示且为调整怪兽。
function c36730805.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 获取自己场上主要怪兽区域的全部怪兽。
	local g=Duel.GetFieldGroup(tp,LOCATION_MZONE,0)
	if g:GetCount()~=1 then return false end
	local c=g:GetFirst()
	return c:IsFaceup() and c:IsType(TYPE_TUNER)
end
-- 特殊召唤候选过滤：卡名属于「疾行机人」、等级4以下且可以被当前效果特殊召唤。
function c36730805.spfilter(c,e,tp)
	return c:IsSetCard(0x2016) and c:IsLevelBelow(4) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果发动时的目标判定：检查自己场上是否有空位，以及卡组中是否存在符合特殊召唤条件的「疾行机人」怪兽。
function c36730805.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动时确认自己场上有可用的主要怪兽区空格。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 同时确认卡组中存在至少1张满足spfilter条件的「疾行机人」怪兽。
		and Duel.IsExistingMatchingCard(c36730805.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 设定这次效果的操作信息：从卡组特殊召唤1只怪兽，用于连锁相关的效果检测。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 效果处理：从卡组选择符合条件的「疾行机人」怪兽特殊召唤；若此卡在连锁1发动，则在特殊召唤后设置双方不能发动效果的封锁。
function c36730805.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 如果效果处理时自己场上没有可用怪兽区域，则特殊召唤处理不执行。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 向当前玩家显示选择要特殊召唤的卡的提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从卡组选择1张满足spfilter条件的「疾行机人」怪兽。
	local g=Duel.SelectMatchingCard(tp,c36730805.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	local tc=g:GetFirst()
	if tc then
		-- 判断当前连锁序号是否为1，即此效果是否作为连锁1发动，以决定是否需要设置后续的特殊召唤成功时的效果封锁。
		if Duel.GetCurrentChain()==1 then
			-- 在那次特殊召唤成功时双方不能把魔法·陷阱·怪兽的效果发动。
			local e2=Effect.CreateEffect(e:GetHandler())
			e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
			e2:SetCode(EVENT_CHAIN_END)
			e2:SetOperation(c36730805.limitop)
			e2:SetCountLimit(1)
			e2:SetReset(RESET_PHASE+PHASE_END)
			-- 将封锁效果注册到当前玩家，该效果持续到结束阶段。
			Duel.RegisterEffect(e2,tp)
		end
		-- 将选择的怪兽以表侧表示特殊召唤到自己场上。
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 连锁结束时（特殊召唤成功后的连锁处理完毕时）执行限制操作，设置直到连锁结束双方不能发动效果。
function c36730805.limitop(e,tp,eg,ep,ev,re,r,rp)
	-- 设置连锁限制为全部拒绝，即双方不能再把任何魔法·陷阱·怪兽的效果发动。
	Duel.SetChainLimitTillChainEnd(aux.FALSE)
end
