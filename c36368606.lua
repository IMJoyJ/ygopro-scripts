--サイバネット・リフレッシュ
-- 效果：
-- ①：对方的电子界族怪兽的攻击宣言时才能发动。双方的主要怪兽区域的怪兽全部破坏。这个回合的结束阶段把这个效果破坏的电子界族连接怪兽尽可能从墓地往持有者场上特殊召唤。
-- ②：对方怪兽的效果发动时，把墓地的这张卡除外才能发动。自己场上的电子界族连接怪兽直到回合结束时不受自身以外的卡的效果影响。
function c36368606.initial_effect(c)
	-- ①：对方的电子界族怪兽的攻击宣言时才能发动。双方的主要怪兽区域的怪兽全部破坏。这个回合的结束阶段把这个效果破坏的电子界族连接怪兽尽可能从墓地往持有者场上特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY+CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_ATTACK_ANNOUNCE)
	e1:SetCondition(c36368606.condition)
	e1:SetTarget(c36368606.target)
	e1:SetOperation(c36368606.activate)
	c:RegisterEffect(e1)
	-- ②：对方怪兽的效果发动时，把墓地的这张卡除外才能发动。自己场上的电子界族连接怪兽直到回合结束时不受自身以外的卡的效果影响。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_CHAINING)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCondition(c36368606.immcon)
	-- 设置②效果的发动代价：把墓地的这张卡除外（通过aux.bfgcost实现）。
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(c36368606.immtg)
	e2:SetOperation(c36368606.immop)
	c:RegisterEffect(e2)
end
-- ①效果的发动条件：在对方回合且攻击宣言的怪兽为电子界族怪兽时才能发动。
function c36368606.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前回合玩家不是这张卡的持有者（即对方回合），且攻击怪兽是电子界族。
	return Duel.GetTurnPlayer()~=tp and Duel.GetAttacker():IsRace(RACE_CYBERSE)
end
-- 该过滤器用于筛选位于主要怪兽区域的怪兽：c:GetSequence()<5表示仅选择主要怪兽区（0-4号区域），排除额外怪兽区。
function c36368606.desfilter(c)
	return c:GetSequence()<5
end
-- ①效果的发动目标处理：检查场上是否存在至少1只位于主要怪兽区域的怪兽；若可以发动，则取双方主要怪兽区域的所有怪兽，并设置破坏信息。
function c36368606.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在效果发动时进行合法性检查：确认场上存在至少1只位于主要怪兽区域的怪兽（用于判定能否发动）。
	if chk==0 then return Duel.IsExistingMatchingCard(c36368606.desfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 取得双方场上所有位于主要怪兽区域的怪兽，作为将被破坏的卡组。
	local g=Duel.GetMatchingGroup(c36368606.desfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	-- 设置本次效果的处理信息为“破坏”：记录将破坏的卡组和数量，供后续连锁或效果检测使用。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
end
-- ①效果的处理：破坏双方主要怪兽区域的所有怪兽；若实际破坏了怪兽，则把被破坏的卡组记录下来，并在结束阶段设置一个处理效果。
function c36368606.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 处理时再次取得双方主要怪兽区域的所有怪兽（此时为待破坏的卡组）。
	local g=Duel.GetMatchingGroup(c36368606.desfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	-- 如果存在应破坏的怪兽，则以效果原因将它们全部破坏；只有实际破坏了至少1张怪兽时才继续执行后续处理。
	if g:GetCount()>0 and Duel.Destroy(g,REASON_EFFECT)~=0 then
		-- 获取刚才破坏操作实际破坏的卡片组（og），用于后续结束阶段的特殊召唤。
		local og=Duel.GetOperatedGroup()
		og:KeepAlive()
		-- 这个回合的结束阶段把这个效果破坏的电子界族连接怪兽尽可能从墓地往持有者场上特殊召唤。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_PHASE+PHASE_END)
		e1:SetCountLimit(1)
		e1:SetReset(RESET_PHASE+PHASE_END)
		e1:SetLabelObject(og)
		e1:SetOperation(c36368606.spop)
		-- 将结束阶段执行特殊召唤的效果注册到当前玩家tp，并设定该效果仅在本回合内有效（随后在结束阶段触发）。
		Duel.RegisterEffect(e1,tp)
	end
end
-- 定义特殊召唤的筛选条件：被破坏的电子界族连接怪兽，且位于墓地、可以被当前效果特殊召唤到其持有者场上。
function c36368606.spfilter(c,e,tp)
	return c:IsRace(RACE_CYBERSE) and c:IsType(TYPE_LINK) and c:IsLocation(LOCATION_GRAVE)
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP,c:GetControler())
end
-- 结束阶段时，将被破坏的电子界族连接怪兽尽可能从墓地特殊召唤到各自持有者场上；若某一方场地空格不足，则由发动者选择可召唤的数量。
function c36368606.spop(e,tp,eg,ep,ev,re,r,rp)
	local g=e:GetLabelObject():Filter(c36368606.spfilter,nil,e,tp)
	if g:GetCount()==0 then return end
	-- 遍历当前回合玩家和对方玩家，依次为双方进行特殊召唤处理。
	for p in aux.TurnPlayers() do
		local tg=g:Filter(Card.IsControler,nil,p)
		-- 获取玩家p的主要怪兽区域空闲格数，用于限制该玩家可以特殊召唤的数量。
		local ft=Duel.GetLocationCount(p,LOCATION_MZONE)
		-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
		if ft>1 and Duel.IsPlayerAffectedByEffect(p,59822133) then ft=1 end
		if tg:GetCount()>ft then
			tg=tg:Select(tp,ft,ft,nil)
		end
		-- 遍历筛选出的要特殊召唤的怪兽，逐个执行特殊召唤步骤。
		for tc in aux.Next(tg) do
			-- 将怪兽tc以表侧表示特殊召唤到玩家p的场上，且不检查召唤条件与苏生限制（因为原效果明确允许从墓地特殊召唤连接怪兽）。
			Duel.SpecialSummonStep(tc,0,tp,p,false,false,POS_FACEUP)
		end
	end
	-- 结束所有特殊召唤步骤并统一处理特殊召唤成功时的场合，完成整个特殊召唤操作。
	Duel.SpecialSummonComplete()
end
-- ②效果的发动条件：对方发动怪兽效果时才能发动（即连锁对方怪兽效果的发动）。
function c36368606.immcon(e,tp,eg,ep,ev,re,r,rp)
	return rp==1-tp and re:IsActiveType(TYPE_MONSTER)
end
-- 筛选自己场上表侧表示且为电子界族的连接怪兽，这些怪兽将获得效果免疫。
function c36368606.immfilter(c)
	return c:IsFaceup() and c:IsRace(RACE_CYBERSE) and c:IsType(TYPE_LINK)
end
-- ②效果的发动目标处理：确认自己场上存在至少1只符合条件的电子界族连接怪兽，满足发动条件。
function c36368606.immtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动时检查自己场上是否有表侧表示的电子界族连接怪兽，用于判定能否发动②效果。
	if chk==0 then return Duel.IsExistingMatchingCard(c36368606.immfilter,tp,LOCATION_MZONE,0,1,nil) end
end
-- ②效果的处理：给自己场上所有表侧表示的电子界族连接怪兽赋予“不受自身以外的卡的效果影响”的免疫效果，持续到回合结束。
function c36368606.immop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得自己场上所有符合条件的电子界族连接怪兽（表侧表示）。
	local g=Duel.GetMatchingGroup(c36368606.immfilter,tp,LOCATION_MZONE,0,nil)
	local tc=g:GetFirst()
	while tc do
		-- 自己场上的电子界族连接怪兽直到回合结束时不受自身以外的卡的效果影响。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
		e1:SetCode(EFFECT_IMMUNE_EFFECT)
		e1:SetRange(LOCATION_MZONE)
		e1:SetValue(c36368606.efilter)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
		tc=g:GetNext()
	end
end
-- 该函数作为免疫效果的判定条件：当效果来源的卡与要免疫的怪兽不是同一张卡时，返回真，即免疫对方的效果。
function c36368606.efilter(e,te,c)
	return te:GetOwner()~=c
end
