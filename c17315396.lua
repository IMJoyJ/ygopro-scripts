--死神官－スーパイ
-- 效果：
-- 这个卡名的效果1回合只能使用1次。
-- ①：把这张卡以外的1张手卡丢弃才能发动。这张卡从手卡守备表示特殊召唤。那之后，可以从手卡·卡组把1只「苏帕伊」特殊召唤。这个效果发动的回合，自己不是同调怪兽不能从额外卡组特殊召唤。
function c17315396.initial_effect(c)
	-- ①：把这张卡以外的1张手卡丢弃才能发动。这张卡从手卡守备表示特殊召唤。那之后，可以从手卡·卡组把1只「苏帕伊」特殊召唤。这个效果发动的回合，自己不是同调怪兽不能从额外卡组特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(17315396,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_DECKDES)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,17315396)
	e1:SetCost(c17315396.cost)
	e1:SetTarget(c17315396.sptg)
	e1:SetOperation(c17315396.spop)
	c:RegisterEffect(e1)
	-- 添加自定义活动计数器，用于监控额外卡组特殊召唤的怪兽是否为同调怪兽
	Duel.AddCustomActivityCounter(17315396,ACTIVITY_SPSUMMON,c17315396.counterfilter)
end
-- 自定义计数器过滤条件：非额外卡组特殊召唤或额外卡组特殊召唤的同调怪兽
function c17315396.counterfilter(c)
	return not c:IsSummonLocation(LOCATION_EXTRA) or c:IsType(TYPE_SYNCHRO) and c:IsFaceup()
end
-- 代价检测：检查手牌中是否存在其他可丢弃的卡，且本回合没有从额外卡组特殊召唤过同调怪兽以外的怪兽
function c17315396.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 检测手牌中是否存在除自身以外可丢弃的卡
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,c)
		-- 并且检测本回合玩家是否未曾从额外卡组特殊召唤过同调怪兽以外的怪兽
		and Duel.GetCustomActivityCount(17315396,tp,ACTIVITY_SPSUMMON)==0 end
	-- ①：把这张卡以外的1张手卡丢弃才能发动。这张卡从手卡守备表示特殊召唤。那之后，可以从手卡·卡组把1只「苏帕伊」特殊召唤。这个效果发动的回合，自己不是同调怪兽不能从额外卡组特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetTargetRange(1,0)
	e1:SetTarget(c17315396.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 为玩家注册该回合内不能特殊召唤同调怪兽以外怪兽的誓约效果
	Duel.RegisterEffect(e1,tp)
	-- 丢弃手牌中除这张卡以外的1张卡作为发动代价
	Duel.DiscardHand(tp,Card.IsDiscardable,1,1,REASON_COST+REASON_DISCARD,c)
end
-- 特殊召唤限制：限制从额外卡组特殊召唤非同调怪兽
function c17315396.splimit(e,c,sump,sumtype,sumpos,targetp,se)
	return not c:IsType(TYPE_SYNCHRO) and c:IsLocation(LOCATION_EXTRA)
end
-- 特殊召唤过滤：筛选手牌或卡组中的「苏帕伊」
function c17315396.spfilter(c,e,tp)
	return c:IsCode(78552773) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果目标检测：检查自己场上是否有空余怪兽区域，以及这张卡是否能守备表示特殊召唤
function c17315396.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检测自己场上是否有空余的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE) end
	-- 设置操作信息：将手牌中的这张卡特殊召唤
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,tp,LOCATION_HAND)
end
-- 效果运行逻辑：守备表示特殊召唤这张卡，之后可以从手牌或卡组将一只「苏帕伊」特殊召唤
function c17315396.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 若这张卡守备表示特殊召唤成功
	if Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP_DEFENSE)~=0 then
		-- 若没有空余的怪兽区域，则直接结束效果
		if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
		-- 获取手牌或卡组中可以特殊召唤的「苏帕伊」
		local g=Duel.GetMatchingGroup(c17315396.spfilter,tp,LOCATION_DECK+LOCATION_HAND,0,nil,e,tp)
		-- 如果存在可特召卡片，询问玩家是否特殊召唤「苏帕伊」
		if g:GetCount()>0 and Duel.SelectYesNo(tp,aux.Stringid(17315396,1)) then  --"是否特殊召唤「苏帕伊」？"
			-- 中断当前效果处理（使前后特殊召唤不同时处理，造成错时点）
			Duel.BreakEffect()
			-- 向玩家提示选择要特殊召唤的卡
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
			local sg=g:Select(tp,1,1,nil)
			if sg:GetCount()>0 then
				-- 将选择的「苏帕伊」表侧表示特殊召唤
				Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)
			end
		end
	end
end
