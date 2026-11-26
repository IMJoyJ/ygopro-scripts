--死神官－スーパイ
-- 效果：
-- 这个卡名的效果1回合只能使用1次。
-- ①：把这张卡以外的1张手卡丢弃才能发动。这张卡从手卡守备表示特殊召唤。那之后，可以从手卡·卡组把1只「苏帕伊」特殊召唤。这个效果发动的回合，自己不是同调怪兽不能从额外卡组特殊召唤。
function c17315396.initial_effect(c)
	-- 这个卡名的效果1回合只能使用1次。 ①：把这张卡以外的1张手卡丢弃才能发动。这张卡从手卡守备表示特殊召唤。那之后，可以从手卡·卡组把1只「苏帕伊」特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(17315396,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_DECKDES+CATEGORY_DECK_SPSUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,17315396)
	e1:SetCost(c17315396.cost)
	e1:SetTarget(c17315396.sptg)
	e1:SetOperation(c17315396.spop)
	c:RegisterEffect(e1)
	-- 注册自定义特殊召唤行动计数器，用于检测本回合是否从额外卡组特殊召唤过非同调怪兽
	Duel.AddCustomActivityCounter(17315396,ACTIVITY_SPSUMMON,c17315396.counterfilter)
end
-- 计数器过滤函数，若怪兽并非从额外卡组特殊召唤，或为表侧表示的同调怪兽则不计入限制
function c17315396.counterfilter(c)
	return not c:IsSummonLocation(LOCATION_EXTRA) or c:IsType(TYPE_SYNCHRO) and c:IsFaceup()
end
-- 发动代价与誓约检查，确认手卡有其他可丢弃的卡且未违反额外卡组特召限制，施加誓约限制并丢弃1张手卡
function c17315396.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 检查自己手卡是否存在这张卡以外至少1张可丢弃的卡
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,c)
		-- 检查本回合是否尚未从额外卡组特殊召唤过同调怪兽以外的怪兽
		and Duel.GetCustomActivityCount(17315396,tp,ACTIVITY_SPSUMMON)==0 end
	-- 这个效果发动的回合，自己不是同调怪兽不能从额外卡组特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetTargetRange(1,0)
	e1:SetTarget(c17315396.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 为自己注册持续至回合结束的额外卡组特殊召唤誓约限制
	Duel.RegisterEffect(e1,tp)
	-- 将这张卡以外的1张手卡作为发动代价丢弃
	Duel.DiscardHand(tp,Card.IsDiscardable,1,1,REASON_COST+REASON_DISCARD,c)
end
-- 限制条件，禁止将非同调怪兽从额外卡组特殊召唤
function c17315396.splimit(e,c,sump,sumtype,sumpos,targetp,se)
	return not c:IsType(TYPE_SYNCHRO) and c:IsLocation(LOCATION_EXTRA)
end
-- 过滤函数，检查是否为卡号78552773（「苏帕伊」）且可特殊召唤的怪兽
function c17315396.spfilter(c,e,tp)
	return c:IsCode(78552773) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 检查怪兽区是否有空位且此卡可守备表示特殊召唤，并设置操作信息
function c17315396.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己怪兽区是否至少有1个空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE) end
	-- 设置将手卡的这张卡特殊召唤的操作信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,tp,LOCATION_HAND)
end
-- 效果处理，将手卡的这张卡表侧守备表示特殊召唤，之后可从手卡·卡组特殊召唤1只「苏帕伊」
function c17315396.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 将这张卡从手卡表侧守备表示特殊召唤并判断是否成功
	if Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP_DEFENSE)~=0 then
		-- 检查自己怪兽区是否还有空位以供后续特殊召唤
		if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
		-- 获取自己手卡·卡组中所有可特殊召唤的「苏帕伊」
		local g=Duel.GetMatchingGroup(c17315396.spfilter,tp,LOCATION_DECK+LOCATION_HAND,0,nil,e,tp)
		-- 若存在可特殊召唤的「苏帕伊」，询问控制者是否将其特殊召唤
		if g:GetCount()>0 and Duel.SelectYesNo(tp,aux.Stringid(17315396,1)) then  --"是否特殊召唤「苏帕伊」？"
			-- 中断当前效果处理，使后续「苏帕伊」的特殊召唤视为不同时处理
			Duel.BreakEffect()
			-- 提示控制者选择要特殊召唤的「苏帕伊」
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
			local sg=g:Select(tp,1,1,nil)
			if sg:GetCount()>0 then
				-- 将选中的「苏帕伊」表侧表示特殊召唤到自己场上
				Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)
			end
		end
	end
end
