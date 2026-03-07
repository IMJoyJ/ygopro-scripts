--スピードリフト
-- 效果：
-- ①：自己场上的怪兽只有调整1只的场合才能发动。从卡组把1只4星以下的「疾行机人」怪兽特殊召唤。在那次特殊召唤成功时双方不能把魔法·陷阱·怪兽的效果发动。
function c36730805.initial_effect(c)
	-- 创建效果对象并设置其分类为特殊召唤、类型为发动、代码为自由连锁、条件为c36730805.condition、目标为c36730805.target、效果处理为c36730805.activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCondition(c36730805.condition)
	e1:SetTarget(c36730805.target)
	e1:SetOperation(c36730805.activate)
	c:RegisterEffect(e1)
end
-- 效果发动条件：自己场上的怪兽只有调整1只的场合才能发动
function c36730805.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 获取自己场上的怪兽组
	local g=Duel.GetFieldGroup(tp,LOCATION_MZONE,0)
	if g:GetCount()~=1 then return false end
	local c=g:GetFirst()
	return c:IsFaceup() and c:IsType(TYPE_TUNER)
end
-- 筛选函数：判断是否为4星以下的「疾行机人」怪兽且可以特殊召唤
function c36730805.spfilter(c,e,tp)
	return c:IsSetCard(0x2016) and c:IsLevelBelow(4) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 设置发动时的处理目标：确认自己场上存在空位且卡组中存在满足条件的怪兽
function c36730805.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 确认自己场上存在空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 确认卡组中存在满足条件的怪兽
		and Duel.IsExistingMatchingCard(c36730805.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置操作信息：准备特殊召唤1只来自卡组的怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 效果处理函数：检查场上是否有空位，提示选择卡组中的怪兽进行特殊召唤，并在满足条件时注册连锁限制效果
function c36730805.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 若自己场上没有空位则不执行效果
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从卡组中选择满足条件的怪兽
	local g=Duel.SelectMatchingCard(tp,c36730805.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	local tc=g:GetFirst()
	if tc then
		-- 判断当前连锁是否为第一个连锁
		if Duel.GetCurrentChain()==1 then
			-- 创建一个在连锁结束时触发的效果，用于限制双方不能发动魔法·陷阱·怪兽效果
			local e2=Effect.CreateEffect(e:GetHandler())
			e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
			e2:SetCode(EVENT_CHAIN_END)
			e2:SetOperation(c36730805.limitop)
			e2:SetCountLimit(1)
			e2:SetReset(RESET_PHASE+PHASE_END)
			-- 将该效果注册到玩家场上
			Duel.RegisterEffect(e2,tp)
		end
		-- 将选中的怪兽特殊召唤到场上
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 连锁限制效果处理函数：设置连锁限制直到连锁结束
function c36730805.limitop(e,tp,eg,ep,ev,re,r,rp)
	-- 设置连锁限制直到连锁结束
	Duel.SetChainLimitTillChainEnd(aux.FALSE)
end
