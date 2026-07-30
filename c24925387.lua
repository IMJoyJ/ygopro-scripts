--魔救の調律者
local s,id,o=GetID()
-- 定义一个函数s.initial_effect(c)，用于注册卡片的效果。
function s.initial_effect(c)
	-- 创建效果e1，描述为aux.Stringid(id,0)（从字符串ID表中获取描述），类别为特殊召唤，类型为起动效果，发动条件为手牌中存在此卡，限制每回合一次，设置代价函数s.spcost，目标选择函数s.sptg，操作函数s.spop，并将效果注册到卡片c。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id)
	e1:SetCost(s.spcost)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	-- 创建效果e2，描述为aux.Stringid(id,1)（从字符串ID表中获取描述），类别为特殊召唤和卡组送墓，类型为起动效果，发动条件为主怪兽区存在此卡，限制每回合一次，设置目标选择函数s.sptg2，操作函数s.spop2，并将效果注册到卡片c。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_DECKDES)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,id+o)
	e2:SetTarget(s.sptg2)
	e2:SetOperation(s.spop2)
	c:RegisterEffect(e2)
end
-- 定义一个过滤函数s.cfilter(c)，用于判断一张卡是否为岩石族且可以作为代价送入卡组。
function s.cfilter(c)
	return c:IsSetCard(0x140) and c:IsAbleToDeckAsCost()
end
-- 定义代价函数s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)，检查是否有满足条件的卡片，提示玩家选择要返回卡组的卡，让玩家选择卡片，确认选择结果，并将选中的卡送入卡组顶端。
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 如果检查标志为0，则判断手牌中是否存在满足s.cfilter过滤器的卡片。
	if chk==0 then return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_HAND,0,1,e:GetHandler()) end
	-- 向玩家提示需要选择要返回卡组的卡片。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 让玩家从手牌中选择一张满足s.cfilter过滤器的卡片。
	local g=Duel.SelectMatchingCard(tp,s.cfilter,tp,LOCATION_HAND,0,1,1,e:GetHandler())
	-- 确认对方玩家所选的卡片。
	Duel.ConfirmCards(1-tp,g)
	-- 将选中的卡送入卡组顶端，原因设置为代价。
	Duel.SendtoDeck(g,nil,SEQ_DECKTOP,REASON_COST)
end
-- 定义目标选择函数s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)，用于判断是否可以特殊召唤此卡。
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 如果检查标志为0，则判断主怪兽区是否有空位。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置操作信息，表示进行特殊召唤的效果。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 定义操作函数s.spop(e,tp,eg,ep,ev,re,r,rp)，用于执行特殊召唤的操作。如果卡片处于连锁中，则将其特殊召唤到场上正面表示。
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToChain() then
		-- 将卡片c特殊召唤到玩家tp的场上，以0方式（通常召唤），正面表示。
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 定义目标选择函数s.sptg2(e,tp,eg,ep,ev,re,r,rp,chk)，用于判断是否可以发动第二个效果。
function s.sptg2(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 如果检查标志为0，则判断卡组中是否有超过4张卡片。
	if chk==0 then return Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)>4 end
end
-- 定义过滤函数s.spfilter(c,e,tp)，用于判断一张卡是否为岩石族、等级低于4且可以特殊召唤。
function s.spfilter(c,e,tp)
	return c:IsRace(RACE_ROCK) and c:IsLevelBelow(4) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 定义操作函数s.spop2(e,tp,eg,ep,ev,re,r,rp)，用于执行第二个效果。确认卡组顶端5张卡，获取卡组顶端的5张卡，计算卡片数量，如果满足条件且玩家选择是，则禁用洗牌检查，提示玩家选择要特殊召唤的卡，让玩家从符合条件的卡中选择一张，将其特殊召唤到场上正面表示，更新卡片数量。
function s.spop2(e,tp,eg,ep,ev,re,r,rp)
	-- 确认玩家tp的卡组顶端5张卡。
	Duel.ConfirmDecktop(tp,5)
	-- 获取玩家tp卡组顶端的5张卡。
	local g=Duel.GetDecktopGroup(tp,5)
	local ct=g:GetCount()
	-- 如果卡组中存在卡片、主怪兽区有空位且符合s.spfilter过滤器的卡片数量大于0，则进行后续操作。
	if ct>0 and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and g:FilterCount(s.spfilter,nil,e,tp)>0
		-- 询问玩家是否要执行特殊召唤。
		and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then
		-- 禁用洗牌检查，防止在效果处理结束后自动洗牌。
		Duel.DisableShuffleCheck()
		-- 提示玩家选择要特殊召唤的卡片。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		local sg=g:FilterSelect(tp,s.spfilter,1,1,nil,e,tp)
		-- 将选中的卡特殊召唤到场上正面表示。
		Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)
		ct=g:GetCount()-sg:GetCount()
	end
	if ct>0 then
		-- 对卡组顶端的剩余卡片进行排序。
		Duel.SortDecktop(tp,tp,ct)
		for i=1,ct do
			-- 获取玩家tp卡组顶端的一张卡。
			local mg=Duel.GetDecktopGroup(tp,1)
			-- 将该卡移动到卡组最底部。
			Duel.MoveSequence(mg:GetFirst(),SEQ_DECKBOTTOM)
		end
	end
end
