--使神官－アスカトル
-- 效果：
-- 这个卡名的效果1回合只能使用1次，这个效果发动的回合，自己不是同调怪兽不能从额外卡组特殊召唤。
-- ①：把这张卡以外的1张手卡丢弃才能发动。这张卡从手卡守备表示特殊召唤。那之后，可以从手卡·卡组把1只「赤蚁」特殊召唤。
function c71821687.initial_effect(c)
	-- 这个卡名的效果1回合只能使用1次，这个效果发动的回合，自己不是同调怪兽不能从额外卡组特殊召唤。①：把这张卡以外的1张手卡丢弃才能发动。这张卡从手卡守备表示特殊召唤。那之后，可以从手卡·卡组把1只「赤蚁」特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(71821687,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_DECKDES)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,71821687)
	e1:SetCost(c71821687.cost)
	e1:SetTarget(c71821687.sptg)
	e1:SetOperation(c71821687.spop)
	c:RegisterEffect(e1)
	-- 添加特殊召唤活动计数器，用于检测该回合是否从额外卡组特殊召唤过同调怪兽以外的怪兽
	Duel.AddCustomActivityCounter(71821687,ACTIVITY_SPSUMMON,c71821687.counterfilter)
end
-- 计数器的过滤函数，检测特殊召唤的怪兽是否为非额外卡组怪兽或表侧表示的同调怪兽
function c71821687.counterfilter(c)
	return not c:IsSummonLocation(LOCATION_EXTRA) or c:IsType(TYPE_SYNCHRO) and c:IsFaceup()
end
-- 效果发动的代价检查，确认手牌中存在这张卡以外的可丢弃卡片，且本回合没有从额外卡组特殊召唤过同调怪兽以外的怪兽
function c71821687.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 检查手牌中是否存在这张卡以外的1张可以丢弃的卡
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,c)
		-- 检查本回合自己是否没有从额外卡组特殊召唤过同调怪兽以外的怪兽
		and Duel.GetCustomActivityCount(71821687,tp,ACTIVITY_SPSUMMON)==0 end
	-- 这个效果发动的回合，自己不是同调怪兽不能从额外卡组特殊召唤。①：把这张卡以外的1张手卡丢弃才能发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetTargetRange(1,0)
	e1:SetTarget(c71821687.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 为玩家注册发动的回合不能从额外卡组特殊召唤同调怪兽以外怪兽的限制效果
	Duel.RegisterEffect(e1,tp)
	-- 从手牌丢弃这张卡以外的1张卡作为发动的代价
	Duel.DiscardHand(tp,Card.IsDiscardable,1,1,REASON_COST+REASON_DISCARD,c)
end
-- 限制特殊召唤怪兽的过滤函数，限定不能从额外卡组特殊召唤非同调怪兽
function c71821687.splimit(e,c,sump,sumtype,sumpos,targetp,se)
	return not c:IsType(TYPE_SYNCHRO) and c:IsLocation(LOCATION_EXTRA)
end
-- 过滤手牌或卡组中符合召唤条件的「赤蚁」
function c71821687.spfilter(c,e,tp)
	return c:IsCode(78275321) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果发动目标检查，确认自己场上有空怪兽区域且手牌中的这张卡可以特殊召唤
function c71821687.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否存在空置的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE) end
	-- 设置效果处理的操作信息，为特殊召唤手牌中的这张卡做准备
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,tp,LOCATION_HAND)
end
-- 效果处理函数，特殊召唤这张卡，并可以从手牌或卡组将1只「赤蚁」特殊召唤
function c71821687.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 尝试将这张卡从手牌守备表示特殊召唤并判断是否召唤成功
	if Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP_DEFENSE)~=0 then
		-- 检查自己场上的空置怪兽格，若无空置怪兽格则不再进行后续处理
		if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
		-- 获取手牌和卡组中所有符合特殊召唤条件的「赤蚁」
		local g=Duel.GetMatchingGroup(c71821687.spfilter,tp,LOCATION_DECK+LOCATION_HAND,0,nil,e,tp)
		-- 若存在可特殊召唤的卡，询问玩家是否选择进行特殊召唤
		if g:GetCount()>0 and Duel.SelectYesNo(tp,aux.Stringid(71821687,1)) then  --"是否特殊召唤「赤蚁」？"
			-- 中断当前效果，使特殊召唤「赤蚁」的处理与前述特殊召唤不视为同时进行
			Duel.BreakEffect()
			-- 提示玩家选择要特殊召唤的怪兽
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
			local sg=g:Select(tp,1,1,nil)
			if sg:GetCount()>0 then
				-- 将选中的怪兽表侧表示特殊召唤
				Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)
			end
		end
	end
end
