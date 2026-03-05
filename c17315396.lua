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
	-- 设置一个计数器，用于记录玩家在该回合中从额外卡组特殊召唤的次数，同调怪兽除外
	Duel.AddCustomActivityCounter(17315396,ACTIVITY_SPSUMMON,c17315396.counterfilter)
end
-- 计数器过滤函数，若卡片不是从额外卡组召唤或为同调怪兽，则不计入计数器
function c17315396.counterfilter(c)
	return not c:IsSummonLocation(LOCATION_EXTRA) or c:IsType(TYPE_SYNCHRO)
end
-- 效果发动时的费用处理，检查是否满足丢弃手卡并确保该效果未在本回合发动过
function c17315396.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 检查玩家手牌中是否存在可丢弃的卡片
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,c)
		-- 检查该玩家在本回合是否已发动过此效果
		and Duel.GetCustomActivityCount(17315396,tp,ACTIVITY_SPSUMMON)==0 end
	-- 创建并注册一个永续效果，使玩家在本回合不能从额外卡组特殊召唤非同调怪兽
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetTargetRange(1,0)
	e1:SetTarget(c17315396.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将上述效果注册给玩家
	Duel.RegisterEffect(e1,tp)
	-- 执行丢弃手牌的操作，作为发动效果的费用
	Duel.DiscardHand(tp,Card.IsDiscardable,1,1,REASON_COST+REASON_DISCARD,c)
end
-- 限制效果的目标函数，禁止非同调怪兽从额外卡组特殊召唤
function c17315396.splimit(e,c,sump,sumtype,sumpos,targetp,se)
	return not c:IsType(TYPE_SYNCHRO) and c:IsLocation(LOCATION_EXTRA)
end
-- 筛选函数，用于查找「苏帕伊」怪兽
function c17315396.spfilter(c,e,tp)
	return c:IsCode(78552773) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果的发动条件判断，检查玩家场上是否有足够的空间进行特殊召唤
function c17315396.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家场上是否有足够的空间进行特殊召唤
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE) end
	-- 设置效果处理时的操作信息，包括特殊召唤的卡和目标位置
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,tp,LOCATION_HAND)
end
-- 效果的处理函数，执行特殊召唤操作并处理后续的「苏帕伊」召唤选择
function c17315396.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 将该卡从手牌特殊召唤到场上
	if Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP_DEFENSE)~=0 then
		-- 检查场上是否还有空位，若无则不继续处理
		if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
		-- 获取玩家手牌和卡组中所有「苏帕伊」怪兽的集合
		local g=Duel.GetMatchingGroup(c17315396.spfilter,tp,LOCATION_DECK+LOCATION_HAND,0,nil,e,tp)
		-- 判断是否有「苏帕伊」怪兽可召唤，并询问玩家是否发动
		if g:GetCount()>0 and Duel.SelectYesNo(tp,aux.Stringid(17315396,1)) then  --"是否特殊召唤「苏帕伊」？"
			-- 中断当前连锁处理，使后续效果视为错时处理
			Duel.BreakEffect()
			-- 提示玩家选择要特殊召唤的「苏帕伊」怪兽
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
			local sg=g:Select(tp,1,1,nil)
			if sg:GetCount()>0 then
				-- 将选定的「苏帕伊」怪兽特殊召唤到场上
				Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)
			end
		end
	end
end
