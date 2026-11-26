--使神官－アスカトル
-- 效果：
-- 这个卡名的效果1回合只能使用1次，这个效果发动的回合，自己不是同调怪兽不能从额外卡组特殊召唤。
-- ①：把这张卡以外的1张手卡丢弃才能发动。这张卡从手卡守备表示特殊召唤。那之后，可以从手卡·卡组把1只「赤蚁」特殊召唤。
function c71821687.initial_effect(c)
	-- 这个卡名的效果1回合只能使用1次，①：把这张卡以外的1张手卡丢弃才能发动。这张卡从手卡守备表示特殊召唤。那之后，可以从手卡·卡组把1只「赤蚁」特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(71821687,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_DECKDES+CATEGORY_DECK_SPSUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,71821687)
	e1:SetCost(c71821687.cost)
	e1:SetTarget(c71821687.sptg)
	e1:SetOperation(c71821687.spop)
	c:RegisterEffect(e1)
	-- 注册自定义特殊召唤计数器71821687，记录玩家本回合是否从额外卡组特殊召唤过非同调怪兽
	Duel.AddCustomActivityCounter(71821687,ACTIVITY_SPSUMMON,c71821687.counterfilter)
end
-- 自定义活动计数器过滤函数：仅当特殊召唤的怪兽不是来自额外卡组，或为表侧表示的同调怪兽时返回true（否则计数加1）
function c71821687.counterfilter(c)
	return not c:IsSummonLocation(LOCATION_EXTRA) or c:IsType(TYPE_SYNCHRO) and c:IsFaceup()
end
-- 发动代价函数：检查手卡中是否有其他可丢弃卡片且本回合未从额外卡组特召过非同调怪兽
function c71821687.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 发动检测时确认己方手卡中除这张卡外存在至少1张可丢弃的卡
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,c)
		-- 且确认己方玩家本回合尚未从额外卡组特殊召唤过非同调怪兽（满足誓约条件）
		and Duel.GetCustomActivityCount(71821687,tp,ACTIVITY_SPSUMMON)==0 end
	-- 这个效果发动的回合，自己不是同调怪兽不能从额外卡组特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetTargetRange(1,0)
	e1:SetTarget(c71821687.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 为己方玩家注册持续到回合结束阶段的誓约限制效果（禁止从额外卡组特召非同调怪兽）
	Duel.RegisterEffect(e1,tp)
	-- 令己方玩家选择除这张卡外的1张手卡，以代价丢弃方式送去墓地
	Duel.DiscardHand(tp,Card.IsDiscardable,1,1,REASON_COST+REASON_DISCARD,c)
end
-- 誓约限制Target函数：禁止从额外卡组(LOCATION_EXTRA)特殊召唤非同调怪兽(TYPE_SYNCHRO)
function c71821687.splimit(e,c,sump,sumtype,sumpos,targetp,se)
	return not c:IsType(TYPE_SYNCHRO) and c:IsLocation(LOCATION_EXTRA)
end
-- 过滤函数：筛选手卡·卡组中可被特殊召唤的「赤蚁」(78275321)
function c71821687.spfilter(c,e,tp)
	return c:IsCode(78275321) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果Target函数：检测己方怪兽区有空位且这张卡可表侧守备表示特召，并设置特召自身的操作信息
function c71821687.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动检测时确认己方主要怪兽区至少有1个可用空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE) end
	-- 设置将手卡中的这张卡特殊召唤的操作信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,tp,LOCATION_HAND)
end
-- 效果Operation函数：将这张卡从手卡表侧守备表示特召后，若有空位可询问玩家从手卡·卡组特召1只「赤蚁」
function c71821687.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 将这张卡从手卡以表侧守备表示特殊召唤到己方场上，若特召失败则终止后续处理
	if Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP_DEFENSE)~=0 then
		-- 检查己方主要怪兽区是否仍有可用空位，若无空位则结束处理
		if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
		-- 获取己方卡组和手卡中所有可特殊召唤的「赤蚁」
		local g=Duel.GetMatchingGroup(c71821687.spfilter,tp,LOCATION_DECK+LOCATION_HAND,0,nil,e,tp)
		-- 若存在可特召的「赤蚁」，询问己方玩家是否要进行特殊召唤
		if g:GetCount()>0 and Duel.SelectYesNo(tp,aux.Stringid(71821687,1)) then  --"是否特殊召唤「赤蚁」？"
			-- 中断当前处理步骤，使后续「赤蚁」的特殊召唤与这张卡自身的特殊召唤视为不同时处理（“那之后”）
			Duel.BreakEffect()
			-- 向己方玩家发送选择要特殊召唤的「赤蚁」提示
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
			local sg=g:Select(tp,1,1,nil)
			if sg:GetCount()>0 then
				-- 将选中的「赤蚁」以表侧表示特殊召唤到己方场上
				Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)
			end
		end
	end
end
