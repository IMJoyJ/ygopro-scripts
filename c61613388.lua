--U.A.ターンオーバー・タクティクス
-- 效果：
-- 「超级运动员换人战术」在1回合只能发动1张。
-- ①：自己场上有「超级运动员」怪兽2种类以上存在的场合才能发动。场上的怪兽全部回到持有者卡组。那之后，自己把最多有这个效果回到自己卡组的卡数量的「超级运动员」怪兽从卡组特殊召唤（同名卡最多1张）。这个效果让自己特殊召唤的怪兽在这个回合不能攻击。那之后，对方可以把最多有这个效果回到对方卡组的卡数量的怪兽从卡组特殊召唤。
function c61613388.initial_effect(c)
	-- 「超级运动员换人战术」在1回合只能发动1张。①：自己场上有「超级运动员」怪兽2种类以上存在的场合才能发动。场上的怪兽全部回到持有者卡组。那之后，自己把最多有这个效果回到自己卡组的卡数量的「超级运动员」怪兽从卡组特殊召唤（同名卡最多1张）。这个效果让自己特殊召唤的怪兽在这个回合不能攻击。那之后，对方可以把最多有这个效果回到对方卡组的卡数量的怪兽从卡组特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TODECK+CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,61613388+EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(c61613388.condition)
	e1:SetTarget(c61613388.target)
	e1:SetOperation(c61613388.activate)
	c:RegisterEffect(e1)
end
-- 过滤条件：自己场上表侧表示的「超级运动员」怪兽
function c61613388.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0xb2)
end
-- 检测是否满足发动条件：自己场上有「超级运动员」怪兽2种类以上存在
function c61613388.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 获取自己场上所有表侧表示的「超级运动员」怪兽
	local g=Duel.GetMatchingGroup(c61613388.cfilter,tp,LOCATION_MZONE,0,nil)
	return g:GetClassCount(Card.GetCode)>=2
end
-- 过滤条件：卡组中可以特殊召唤的「超级运动员」怪兽
function c61613388.filter(c,e,tp)
	return c:IsSetCard(0xb2) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 检测是否满足发动条件以及是否存在可操作的卡片
function c61613388.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查场上是否存在可以回到卡组的怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsAbleToDeck,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil)
		-- 检查自己卡组是否存在可以特殊召唤的「超级运动员」怪兽
		and Duel.IsExistingMatchingCard(c61613388.filter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 获取场上所有可以回到卡组的怪兽
	local g=Duel.GetMatchingGroup(Card.IsAbleToDeck,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	-- 设置操作信息：将场上的怪兽全部回到持有者卡组
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,g:GetCount(),0,0)
	-- 设置操作信息：从卡组特殊召唤怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 过滤条件：回到指定玩家卡组的卡片
function c61613388.locfilter(c,sp)
	return c:IsLocation(LOCATION_DECK) and c:IsControler(sp)
end
-- 效果处理的执行函数
function c61613388.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取场上所有可以回到卡组的怪兽
	local tg=Duel.GetMatchingGroup(Card.IsAbleToDeck,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	-- 将场上的怪兽全部回到持有者卡组
	Duel.SendtoDeck(tg,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	-- 洗切自己的卡组
	Duel.ShuffleDeck(tp)
	-- 计算回到自己卡组的卡片数量
	local ct1=Duel.GetOperatedGroup():FilterCount(c61613388.locfilter,nil,tp)
	-- 计算回到对方卡组的卡片数量
	local ct2=Duel.GetOperatedGroup():FilterCount(c61613388.locfilter,nil,1-tp)
	-- 限制自己特殊召唤的数量不超过自己场上的可用怪兽区域数量
	if ct1>Duel.GetLocationCount(tp,LOCATION_MZONE) then ct1=Duel.GetLocationCount(tp,LOCATION_MZONE) end
	-- 限制对方特殊召唤的数量不超过对方场上的可用怪兽区域数量
	if ct2>Duel.GetLocationCount(1-tp,LOCATION_MZONE) then ct2=Duel.GetLocationCount(1-tp,LOCATION_MZONE) end
	if ct1<=0 then return end
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if Duel.IsPlayerAffectedByEffect(tp,59822133) then ct1=1 end
	-- 获取自己卡组中所有可以特殊召唤的「超级运动员」怪兽
	local g=Duel.GetMatchingGroup(c61613388.filter,tp,LOCATION_DECK,0,nil,e,tp)
	if g:GetCount()==0 then return end
	-- 中断当前效果，使之后的效果处理（特殊召唤）视为不同时处理
	Duel.BreakEffect()
	-- 提示玩家选择要特殊召唤的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从卡组选择最多等同于回到卡组卡片数量的、卡名各不相同的「超级运动员」怪兽
	local sg=g:SelectSubGroup(tp,aux.dncheck,false,1,ct1)
	local sc=sg:GetFirst()
	while sc do
		-- 尝试将选中的怪兽以表侧表示特殊召唤到自己场上
		if Duel.SpecialSummonStep(sc,0,tp,tp,false,false,POS_FACEUP) then
			-- 这个效果让自己特殊召唤的怪兽在这个回合不能攻击。
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_CANNOT_ATTACK)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			sc:RegisterEffect(e1)
		end
		sc=sg:GetNext()
	end
	-- 完成自己怪兽的特殊召唤流程
	Duel.SpecialSummonComplete()
	-- 检查对方是否可以从卡组特殊召唤怪兽
	if ct2>0 and Duel.IsExistingMatchingCard(Card.IsCanBeSpecialSummoned,tp,0,LOCATION_DECK,1,nil,e,0,1-tp,false,false)
		-- 询问对方是否要从卡组特殊召唤怪兽
		and Duel.SelectYesNo(1-tp,aux.Stringid(61613388,1)) then  --"是否从卡组特殊召唤怪兽？"
		-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
		if Duel.IsPlayerAffectedByEffect(1-tp,59822133) then ct2=1 end
		-- 中断当前效果，使之后的效果处理（特殊召唤）视为不同时处理
		Duel.BreakEffect()
		-- 提示对方玩家选择要特殊召唤的怪兽
		Duel.Hint(HINT_SELECTMSG,1-tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 让对方玩家从卡组选择最多等同于回到对方卡组卡片数量的怪兽
		local sg2=Duel.SelectMatchingCard(1-tp,Card.IsCanBeSpecialSummoned,tp,0,LOCATION_DECK,1,ct2,nil,e,0,1-tp,false,false)
		if sg2:GetCount()>0 then
			-- 对方将选中的怪兽特殊召唤到其场上
			Duel.SpecialSummon(sg2,0,1-tp,1-tp,false,false,POS_FACEUP)
		end
	end
end
