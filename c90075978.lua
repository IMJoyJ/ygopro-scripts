--W星雲隕石
-- 效果：
-- 场上里侧表示存在的怪兽全部变成表侧守备表示。这个回合的结束阶段时自己场上表侧表示存在的爬虫类族·光属性怪兽全部变成里侧守备表示，自己从卡组抽出那个数量的卡。那之后，可以从自己卡组把1只7星以上的爬虫类族·光属性怪兽特殊召唤。
function c90075978.initial_effect(c)
	-- 场上里侧表示存在的怪兽全部变成表侧守备表示。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_POSITION+CATEGORY_SPECIAL_SUMMON+CATEGORY_DRAW+CATEGORY_DECKDES+CATEGORY_DECK_SPSUMMON+CATEGORY_MSET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e1:SetTarget(c90075978.target)
	e1:SetOperation(c90075978.activate)
	c:RegisterEffect(e1)
end
-- 效果Target函数：检测场上是否存在至少1只里侧表示怪兽，并设置改变场上全部里侧怪兽表示形式的操作信息
function c90075978.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动检测时确认双方怪兽区存在至少1只里侧表示的怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsFacedown,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 获取双方怪兽区上的全部里侧表示怪兽
	local g=Duel.GetMatchingGroup(Card.IsFacedown,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	-- 设置将场上全部里侧表示怪兽改变表示形式的操作信息
	Duel.SetOperationInfo(0,CATEGORY_POSITION,g,g:GetCount(),0,0)
end
-- 效果处理函数：将场上全部里侧表示怪兽变为表侧守备表示，并注册持续至本回合结束阶段的延迟翻盖抽卡及特召效果
function c90075978.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取双方怪兽区上的全部里侧表示怪兽
	local g=Duel.GetMatchingGroup(Card.IsFacedown,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	if g:GetCount()>0 then
		-- 将场上所有里侧表示怪兽变为表侧守备表示
		Duel.ChangePosition(g,POS_FACEUP_DEFENSE)
	end
	-- 这个回合的结束阶段时自己场上表侧表示存在的爬虫类族·光属性怪兽全部变成里侧守备表示，自己从卡组抽出那个数量的卡。那之后，可以从自己卡组把1只7星以上的爬虫类族·光属性怪兽特殊召唤。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_PHASE+PHASE_END)
	e1:SetCountLimit(1)
	e1:SetReset(RESET_PHASE+PHASE_END)
	e1:SetCondition(c90075978.setcon)
	e1:SetOperation(c90075978.setop)
	-- 为己方玩家注册持续至本回合结束阶段触发的延迟效果e1
	Duel.RegisterEffect(e1,tp)
end
-- 过滤函数：筛选场上表侧表示、光属性、爬虫类族且可以变成里侧表示的怪兽
function c90075978.sfilter(c)
	return c:IsFaceup() and c:IsAttribute(ATTRIBUTE_LIGHT) and c:IsRace(RACE_REPTILE) and c:IsCanTurnSet()
end
-- 过滤函数：筛选卡组中光属性、爬虫类族、7星以上且可被特殊召唤的怪兽
function c90075978.spfilter(c,e,tp)
	return c:IsAttribute(ATTRIBUTE_LIGHT) and c:IsRace(RACE_REPTILE) and c:IsLevelAbove(7)
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 结束阶段延迟效果的Condition函数：检查自己怪兽区是否存在至少1只表侧表示且可变成里侧的光属性爬虫类族怪兽
function c90075978.setcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查己方怪兽区是否存在至少1只符合条件的光属性爬虫类族怪兽
	return Duel.IsExistingMatchingCard(c90075978.sfilter,tp,LOCATION_MZONE,0,1,nil)
end
-- 结束阶段延迟效果的Operation函数：将自己场上表侧光属性爬虫类族怪兽全部变成里侧守备表示并抽取等量卡片，之后可从卡组特召1只7星以上光属性爬虫类族怪兽
function c90075978.setop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取己方怪兽区上所有表侧表示且可变成里侧的光属性爬虫类族怪兽
	local g=Duel.GetMatchingGroup(c90075978.sfilter,tp,LOCATION_MZONE,0,nil)
	if g:GetCount()>0 then
		-- 将获取到的己方光属性爬虫类族怪兽全部变为里侧守备表示
		Duel.ChangePosition(g,POS_FACEDOWN_DEFENSE)
		-- 己方玩家以效果从卡组抽取等同于变为里侧守备表示怪兽数量的卡片，并记录实际抽卡数dt
		local dt=Duel.Draw(tp,g:GetCount(),REASON_EFFECT)
		-- 若实际抽卡数为0或己方主要怪兽区没有可用空位，则直接终止后续特召处理
		if dt==0 or Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
		-- 获取己方卡组中所有可特殊召唤的7星以上光属性爬虫类族怪兽
		local sg=Duel.GetMatchingGroup(c90075978.spfilter,tp,LOCATION_DECK,0,nil,e,tp)
		-- 若卡组存在可特召的7星以上光属性爬虫类族怪兽，询问己方玩家是否要进行特殊召唤
		if sg:GetCount()>0 and Duel.SelectYesNo(tp,aux.Stringid(90075978,0)) then  --"是否要特殊召唤7星以上的爬虫类族·光属性怪兽？"
			-- 中断当前处理步骤，使后续卡组特召与前面的翻盖抽卡视为不同时处理（“那之后”）
			Duel.BreakEffect()
			-- 向己方玩家发送选择要特殊召唤的7星以上光属性爬虫类族怪兽提示
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
			-- 从卡组选1只7星以上的光属性爬虫类族怪兽以表侧表示特殊召唤到己方场上
			Duel.SpecialSummon(sg:Select(tp,1,1,nil),0,tp,tp,false,false,POS_FACEUP)
		end
	end
end
