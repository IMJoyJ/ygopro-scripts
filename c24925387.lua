--魔救の調律者
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡在手卡存在的场合，从手卡让1张其他的「魔救」卡回到卡组最上面才能发动。这张卡特殊召唤。
-- ②：自己主要阶段才能发动。从自己卡组上面把5张卡翻开。可以从那之中选1只4星以下的岩石族怪兽特殊召唤。剩余用喜欢的顺序回到卡组下面。
local s,id,o=GetID()
-- 初始化「魔救之调律者」(24925387)：注册①从手卡回卡组顶特召自身的起动效果与②翻开卡组上方5张特召岩石族怪兽的起动效果
function s.initial_effect(c)
	-- 这个卡名的①②的效果1回合各能使用1次。①：这张卡在手卡存在的场合，从手卡让1张其他的「魔救」卡回到卡组最上面才能发动。这张卡特殊召唤。
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
	-- ②：自己主要阶段才能发动。从自己卡组上面把5张卡翻开。可以从那之中选1只4星以下的岩石族怪兽特殊召唤。剩余用喜欢的顺序回到卡组下面。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"翻卡组"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_DECKDES+CATEGORY_DECK_SPSUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,id+o)
	e2:SetTarget(s.sptg2)
	e2:SetOperation(s.spop2)
	c:RegisterEffect(e2)
end
-- 过滤函数：筛选手卡中属于「魔救」(0x140)字段且可作为代价返回卡组的卡片
function s.cfilter(c)
	return c:IsSetCard(0x140) and c:IsAbleToDeckAsCost()
end
-- 效果①的Cost函数：检查手卡中除自身外是否有其他「魔救」卡，选择1张向对方确认后放回卡组最上面
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动检测时确认己方手卡中除这张卡外存在至少1张可返回卡组的「魔救」卡
	if chk==0 then return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_HAND,0,1,e:GetHandler()) end
	-- 向己方玩家发送选择要返回卡组的卡片提示
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 从己方手卡中选择1张除这张卡外的「魔救」卡
	local g=Duel.SelectMatchingCard(tp,s.cfilter,tp,LOCATION_HAND,0,1,1,e:GetHandler())
	-- 向对方玩家公开确认所选作为代价返回卡组的「魔救」卡
	Duel.ConfirmCards(1-tp,g)
	-- 将选中的「魔救」卡作为发动代价放回持有者卡组最上方
	Duel.SendtoDeck(g,nil,SEQ_DECKTOP,REASON_COST)
end
-- 效果①的Target函数：检测己方怪兽区有空位且这张卡可被特殊召唤，并设置特殊召唤操作信息
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动检测时确认己方主要怪兽区至少有1个可用空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置将手卡中的这张卡特殊召唤的操作信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 效果①的Operation函数：确认这张卡仍与当前连锁关联后，将其从手卡表侧特殊召唤到己方场上
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToChain() then
		-- 将这张卡以表侧表示特殊召唤到己方场上
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 效果②的Target函数：检测己方卡组剩余卡片数量是否至少有5张
function s.sptg2(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动检测时确认己方卡组中至少有5张卡（数量大于4）
	if chk==0 then return Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)>4 end
end
-- 过滤函数：筛选岩石族、4星以下且可以被效果特殊召唤的怪兽
function s.spfilter(c,e,tp)
	return c:IsRace(RACE_ROCK) and c:IsLevelBelow(4) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果②的Operation函数：翻开己方卡组最上方5张卡，可从中选择1只4星以下岩石族怪兽特殊召唤
function s.spop2(e,tp,eg,ep,ev,re,r,rp)
	-- 翻开并确认己方卡组最上方的5张卡
	Duel.ConfirmDecktop(tp,5)
	-- 获取己方卡组最上方这5张卡组成的卡片组
	local g=Duel.GetDecktopGroup(tp,5)
	local ct=g:GetCount()
	-- 检查己方怪兽区有空位且翻开的卡中存在可特殊召唤的4星以下岩石族怪兽
	if ct>0 and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and g:FilterCount(s.spfilter,nil,e,tp)>0
		-- 询问己方玩家是否要从翻开的卡中特殊召唤怪兽
		and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then  --"是否特殊召唤怪兽？"
		-- 禁用紧接着的特殊召唤操作后的自动洗切卡组检测，以保持翻开卡的顺序
		Duel.DisableShuffleCheck()
		-- 向己方玩家发送选择要特殊召唤的怪兽提示
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		local sg=g:FilterSelect(tp,s.spfilter,1,1,nil,e,tp)
		-- 将选中的4星以下岩石族怪兽以表侧表示特殊召唤到己方场上
		Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)
		ct=g:GetCount()-sg:GetCount()
	end
	if ct>0 then
		-- 让己方玩家对剩余的ct张卡组顶端卡片按喜欢的顺序排列
		Duel.SortDecktop(tp,tp,ct)
		for i=1,ct do
			-- 获取当前位于己方卡组最上方的1张卡
			local mg=Duel.GetDecktopGroup(tp,1)
			-- 将该卡移动到己方卡组最下面，循环执行从而按顺序放回卡组底端
			Duel.MoveSequence(mg:GetFirst(),SEQ_DECKBOTTOM)
		end
	end
end
