--魔救の調律者
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡在手卡存在的场合，从手卡让1张其他的「魔救」卡回到卡组最上面才能发动。这张卡特殊召唤。
-- ②：自己主要阶段才能发动。从自己卡组上面把5张卡翻开。可以从那之中选1只4星以下的岩石族怪兽特殊召唤。剩余用喜欢的顺序回到卡组下面。
local s,id,o=GetID()
-- 注册①②两个效果：e1为手卡发动的起动效果，分类为特殊召唤，1回合1次（id计数）；e2为怪兽区发动的起动效果，分类为特殊召唤+卡组相关，1回合1次（id+o计数）
function s.initial_effect(c)
	-- 这个卡名的①的效果1回合只能使用1次。①：这张卡在手卡存在的场合，从手卡让1张其他的「魔救」卡回到卡组最上面才能发动。这张卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id)
	e1:SetCost(s.spcost)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	-- 这个卡名的②的效果1回合只能使用1次。②：自己主要阶段才能发动。从自己卡组上面把5张卡翻开。可以从那之中选1只4星以下的岩石族怪兽特殊召唤。剩余用喜欢的顺序回到卡组下面。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"翻卡组"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_DECKDES)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,id+o)
	e2:SetTarget(s.sptg2)
	e2:SetOperation(s.spop2)
	c:RegisterEffect(e2)
end
-- 过滤函数：判断卡片是否为「魔救」卡（系列0x140）且可以作为代价回到卡组
function s.cfilter(c)
	return c:IsSetCard(0x140) and c:IsAbleToDeckAsCost()
end
-- ①效果的代价处理：确认手卡中存在这张卡以外的可回到卡组的「魔救」卡，让玩家选择1张，给对方确认后将其作为代价送回卡组最上面
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动条件检查：自己手卡中是否存在这张卡以外的至少1张可作为代价回到卡组的「魔救」卡
	if chk==0 then return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_HAND,0,1,e:GetHandler()) end
	-- 提示玩家选择要返回卡组的卡（请选择要返回卡组的卡）
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 让玩家从自己手卡选择1张这张卡以外的可作为代价回到卡组的「魔救」卡
	local g=Duel.SelectMatchingCard(tp,s.cfilter,tp,LOCATION_HAND,0,1,1,e:GetHandler())
	-- 将选中的卡给对方玩家确认
	Duel.ConfirmCards(1-tp,g)
	-- 将选中的卡作为代价送回持有者卡组的最上面
	Duel.SendtoDeck(g,nil,SEQ_DECKTOP,REASON_COST)
end
-- ①效果的目标处理：检查自己主要怪兽区是否有空格，且这张卡是否可以被特殊召唤
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动条件检查：自己主要怪兽区必须存在可用空格，且这张卡可以被特殊召唤
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置连锁操作信息：确定要特殊召唤的卡为这张卡（1张），用于星尘龙等效果的发动检测
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- ①效果的处理：若这张卡仍与当前连锁关联，则将这张卡特殊召唤
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToChain() then
		-- 将这张卡以正面表示特殊召唤到自己场上
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- ②效果的目标处理：发动条件检查，自己卡组的卡必须多于4张（至少5张）
function s.sptg2(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动条件检查：自己卡组中必须存在5张以上的卡
	if chk==0 then return Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)>4 end
end
-- 过滤函数：判断卡片是否为4星以下的岩石族怪兽且可以被特殊召唤
function s.spfilter(c,e,tp)
	return c:IsRace(RACE_ROCK) and c:IsLevelBelow(4) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- ②效果的处理：翻开自己卡组最上方5张卡，若其中有4星以下可特殊召唤的岩石族怪兽且场上主要怪兽区有空格，询问玩家是否特殊召唤，是则从其中选1只特殊召唤，并更新剩余卡数量
function s.spop2(e,tp,eg,ep,ev,re,r,rp)
	-- 确认（翻开）自己卡组最上方的5张卡
	Duel.ConfirmDecktop(tp,5)
	-- 取得自己卡组最上方5张卡组成的卡片组
	local g=Duel.GetDecktopGroup(tp,5)
	local ct=g:GetCount()
	-- 条件判断：翻开卡不为空、主要怪兽区有空格，且翻开的卡中存在至少1只可特殊召唤的4星以下岩石族怪兽
	if ct>0 and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and g:FilterCount(s.spfilter,nil,e,tp)>0
		-- 询问玩家是否特殊召唤怪兽（是否特殊召唤怪兽？），选择是则进入特殊召唤处理
		and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then  --"是否特殊召唤怪兽？"
		-- 禁用下一次操作的洗卡组检测，避免从卡组中间取卡后系统自动洗牌
		Duel.DisableShuffleCheck()
		-- 提示玩家选择要特殊召唤的卡（请选择要特殊召唤的卡）
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		local sg=g:FilterSelect(tp,s.spfilter,1,1,nil,e,tp)
		-- 将选中的怪兽以正面表示特殊召唤到自己场上
		Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)
		ct=g:GetCount()-sg:GetCount()
	end
	if ct>0 then
		-- 让玩家将剩余的卡按喜欢的顺序排序（最先选的放在最上面）
		Duel.SortDecktop(tp,tp,ct)
		for i=1,ct do
			-- 取得卡组最上方的1张卡
			local mg=Duel.GetDecktopGroup(tp,1)
			-- 将该卡移动到卡组最下面（依次把剩余卡按排序结果放到卡组下方）
			Duel.MoveSequence(mg:GetFirst(),SEQ_DECKBOTTOM)
		end
	end
end
