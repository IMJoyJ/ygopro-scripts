--W星雲隕石
-- 效果：
-- 场上里侧表示存在的怪兽全部变成表侧守备表示。这个回合的结束阶段时自己场上表侧表示存在的爬虫类族·光属性怪兽全部变成里侧守备表示，自己从卡组抽出那个数量的卡。那之后，可以从自己卡组把1只7星以上的爬虫类族·光属性怪兽特殊召唤。
function c90075978.initial_effect(c)
	-- 场上里侧表示存在的怪兽全部变成表侧守备表示。这个回合的结束阶段时自己场上表侧表示存在的爬虫类族·光属性怪兽全部变成里侧守备表示，自己从卡组抽出那个数量的卡。那之后，可以从自己卡组把1只7星以上的爬虫类族·光属性怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_POSITION+CATEGORY_SPECIAL_SUMMON+CATEGORY_DRAW+CATEGORY_DECKDES+CATEGORY_MSET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e1:SetTarget(c90075978.target)
	e1:SetOperation(c90075978.activate)
	c:RegisterEffect(e1)
end
-- 效果发动的目标确认与操作信息设置
function c90075978.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查场上是否存在里侧表示的怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsFacedown,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 获取场上所有的里侧表示怪兽
	local g=Duel.GetMatchingGroup(Card.IsFacedown,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	-- 设置操作信息为改变表示形式
	Duel.SetOperationInfo(0,CATEGORY_POSITION,g,g:GetCount(),0,0)
end
-- 效果处理：将里侧怪兽变为表侧守备表示，并注册回合结束阶段的处理效果
function c90075978.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取场上所有的里侧表示怪兽
	local g=Duel.GetMatchingGroup(Card.IsFacedown,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	if g:GetCount()>0 then
		-- 将获取到的里侧怪兽全部变成表侧守备表示
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
	-- 注册在回合结束阶段触发的延迟效果
	Duel.RegisterEffect(e1,tp)
end
-- 过滤条件：自己场上表侧表示、可以变成里侧表示的爬虫类族·光属性怪兽
function c90075978.sfilter(c)
	return c:IsFaceup() and c:IsAttribute(ATTRIBUTE_LIGHT) and c:IsRace(RACE_REPTILE) and c:IsCanTurnSet()
end
-- 过滤条件：卡组中可以特殊召唤的7星以上的爬虫类族·光属性怪兽
function c90075978.spfilter(c,e,tp)
	return c:IsAttribute(ATTRIBUTE_LIGHT) and c:IsRace(RACE_REPTILE) and c:IsLevelAbove(7)
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 检查结束阶段时自己场上是否存在满足条件的爬虫类族·光属性怪兽
function c90075978.setcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否存在至少1只表侧表示的爬虫类族·光属性怪兽
	return Duel.IsExistingMatchingCard(c90075978.sfilter,tp,LOCATION_MZONE,0,1,nil)
end
-- 结束阶段的具体效果处理：将怪兽变里侧、抽卡、并可选特殊召唤
function c90075978.setop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取自己场上所有表侧表示的爬虫类族·光属性怪兽
	local g=Duel.GetMatchingGroup(c90075978.sfilter,tp,LOCATION_MZONE,0,nil)
	if g:GetCount()>0 then
		-- 将这些怪兽全部变成里侧守备表示
		Duel.ChangePosition(g,POS_FACEDOWN_DEFENSE)
		-- 玩家从卡组抽出与变成里侧守备表示的怪兽数量相同的卡
		local dt=Duel.Draw(tp,g:GetCount(),REASON_EFFECT)
		-- 若没有成功抽卡或自己场上没有空余的怪兽区域，则结束效果处理
		if dt==0 or Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
		-- 获取卡组中所有满足特殊召唤条件的7星以上的爬虫类族·光属性怪兽
		local sg=Duel.GetMatchingGroup(c90075978.spfilter,tp,LOCATION_DECK,0,nil,e,tp)
		-- 若存在可特殊召唤的怪兽，询问玩家是否选择进行特殊召唤
		if sg:GetCount()>0 and Duel.SelectYesNo(tp,aux.Stringid(90075978,0)) then  --"是否要特殊召唤7星以上的爬虫类族·光属性怪兽？"
			-- 划分效果处理时点，使后续的特殊召唤不与抽卡同时处理
			Duel.BreakEffect()
			-- 提示玩家选择要特殊召唤的怪兽
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
			-- 玩家选择1只怪兽并以表侧表示特殊召唤到自己场上
			Duel.SpecialSummon(sg:Select(tp,1,1,nil),0,tp,tp,false,false,POS_FACEUP)
		end
	end
end
