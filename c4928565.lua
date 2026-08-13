--ティアラメンツ・クシャトリラ
-- 效果：
-- 这个卡名的①②③的效果1回合各能使用1次。
-- ①：自己·对方的主要阶段才能发动。这张卡从手卡特殊召唤，从自己的手卡·墓地选1张「俱舍怒威族」卡或者「珠泪哀歌族」卡除外。
-- ②：这张卡召唤·特殊召唤成功的场合才能发动。从自己或者对方的卡组上面把3张卡送去墓地。
-- ③：这张卡被效果送去墓地的场合才能发动。从自己卡组上面把2张卡送去墓地。
local s,id,o=GetID()
-- 初始化并注册全部效果：e1为①的从手卡发动的主要阶段特殊召唤并除外的诱发即时效果；e2/e3为②的召唤/特殊召唤成功时从双方卡组顶丢3张卡的诱发效果；e4为③的被效果送去墓地时从自己卡组顶丢2张卡的诱发效果。
function s.initial_effect(c)
	-- ①：自己·对方的主要阶段才能发动。这张卡从手卡特殊召唤，从自己的手卡·墓地选1张「俱舍怒威族」卡或者「珠泪哀歌族」卡除外。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_HAND)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_MAIN_END)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.spcon)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	-- ②：这张卡召唤·特殊召唤成功的场合才能发动。从自己或者对方的卡组上面把3张卡送去墓地。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_DECKDES)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:SetCountLimit(1,id+o)
	e2:SetTarget(s.ddtg)
	e2:SetOperation(s.ddop)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e3)
	-- ③：这张卡被效果送去墓地的场合才能发动。从自己卡组上面把2张卡送去墓地。
	local e4=Effect.CreateEffect(c)
	e4:SetCategory(CATEGORY_DECKDES)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_TO_GRAVE)
	e4:SetProperty(EFFECT_FLAG_DELAY)
	e4:SetCountLimit(1,id+o*2)
	e4:SetCondition(s.discon)
	e4:SetTarget(s.distg)
	e4:SetOperation(s.disop)
	c:RegisterEffect(e4)
end
-- ①效果的发动条件：当前阶段为主要阶段1或主要阶段2，对应“自己·对方的主要阶段才能发动”。
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前游戏阶段，用于判断是否处于主要阶段。
	local ph=Duel.GetCurrentPhase()
	return ph==PHASE_MAIN1 or ph==PHASE_MAIN2
end
-- 筛选手卡·墓地中满足“「俱舍怒威族」卡或者「珠泪哀歌族」卡”且可以除外的卡，作为①的除外对象。
function s.rmfilter(c)
	return c:IsSetCard(0x189,0x181) and c:IsAbleToRemove()
end
-- ①效果发动时的合法性检测：自己的怪兽区有空位、自身可以特殊召唤，并且手卡·墓地存在至少1张符合条件的除外对象。
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 判定自己场上是否有可用的怪兽区域空位，用于特殊召唤这张卡。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		-- 判定手卡·墓地是否存在至少1张满足除外条件的卡（排除这张卡自身），作为①效果除外的候选。
		and Duel.IsExistingMatchingCard(s.rmfilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,c) end
	-- 设定连锁操作信息：本效果将特殊召唤这张卡，数量1，对象为这张卡自身。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
	-- 设定连锁操作信息：本效果将从自己手卡·墓地除外1张卡，具体对象在处理时选择，因此targets为nil。
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,tp,LOCATION_HAND+LOCATION_GRAVE)
end
-- ①效果处理：先特殊召唤这张卡，成功后从自己手卡·墓地选择1张符合条件的「俱舍怒威族」或「珠泪哀歌族」卡除外。
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e)
		-- 实际执行特殊召唤，若特殊召唤成功（返回数量>0），才继续执行后续除外操作。
		and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)>0 then
		-- 显示选择提示，提示玩家选择要除外的卡。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
		-- 从自己手卡·墓地选择1张符合条件且不受王家长眠之谷影响的卡作为除外对象。
		local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.rmfilter),tp,LOCATION_HAND+LOCATION_GRAVE,0,1,1,nil)
		if #g>0 then
			-- 将选择的卡以表侧表示除外，原因为效果。
			Duel.Remove(g,POS_FACEUP,REASON_EFFECT)
		end
	end
end
-- ②效果的目标判定：自己或对方的卡组顶端有至少3张卡可以送去墓地时才能发动，并设置相应操作信息。
function s.ddtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己卡组顶端是否有至少3张卡可以送去墓地。
	local b1=Duel.IsPlayerCanDiscardDeck(tp,3)
	-- 检查对方卡组顶端是否有至少3张卡可以送去墓地。
	local b2=Duel.IsPlayerCanDiscardDeck(1-tp,3)
	if chk==0 then return b1 or b2 end
	-- 设定连锁操作信息：本效果涉及从卡组顶丢弃3张卡，具体由自己或对方承担（PLAYER_ALL）在处理时决定。
	Duel.SetOperationInfo(0,CATEGORY_DECKDES,nil,0,PLAYER_ALL,3)
end
-- ②效果处理：根据双方卡组是否可送墓，决定从自己或对方卡组顶把3张卡送去墓地；若双方均可则由玩家选择。
function s.ddop(e,tp,eg,ep,ev,re,r,rp)
	-- 再次检查自己卡组能否将顶端3张送去墓地，用于生成选项。
	local b1=Duel.IsPlayerCanDiscardDeck(tp,3)
	-- 再次检查对方卡组能否将顶端3张送去墓地，用于生成选项。
	local b2=Duel.IsPlayerCanDiscardDeck(1-tp,3)
	if not b1 and not b2 then return end
	local opt=0
	if b1 and not b2 then
		-- 当只有自己卡组可送墓时，弹出“从自己卡组上面把3张卡送去墓地”的选项，选择后opt为0。
		opt=Duel.SelectOption(tp,aux.Stringid(id,1))  --"从自己卡组上面把3张卡送去墓地"
	end
	if not b1 and b2 then
		-- 当只有对方卡组可送墓时，弹出“从对方卡组上面把3张卡送去墓地”的选项，选择结果+1使opt为1。
		opt=Duel.SelectOption(tp,aux.Stringid(id,2))+1  --"从对方卡组上面把3张卡送去墓地"
	end
	if b1 and b2 then
		-- 当双方卡组都可送墓时，弹出两个选项，让玩家选择从自己还是对方卡组送墓，返回值0表示自己，1表示对方。
		opt=Duel.SelectOption(tp,aux.Stringid(id,1),aux.Stringid(id,2))  --"从自己卡组上面把3张卡送去墓地/从对方卡组上面把3张卡送去墓地"
	end
	if opt==0 then
		-- 选0时，将自己卡组顶3张卡送去墓地，原因为效果。
		Duel.DiscardDeck(tp,3,REASON_EFFECT)
	else
		-- 选1时，将对方卡组顶3张卡送去墓地，原因为效果。
		Duel.DiscardDeck(1-tp,3,REASON_EFFECT)
	end
end
-- ③效果发动条件：这张卡是被效果（而非战斗等）送去墓地的场合。
function s.discon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsReason(REASON_EFFECT)
end
-- ③效果的目标判定：检查自己卡组顶端是否有至少2张卡可以送去墓地，并设置目标玩家和参数。
function s.distg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判定自己卡组顶端是否有至少2张卡可以送去墓地。
	if chk==0 then return Duel.IsPlayerCanDiscardDeck(tp,2) end
	-- 将当前连锁的目标玩家设置为自己，表示之后从自己卡组送墓。
	Duel.SetTargetPlayer(tp)
	-- 将当前连锁的目标参数设置为2，表示要送去墓地的卡数量。
	Duel.SetTargetParam(2)
	-- 设定连锁操作信息：本效果将2张卡从自己卡组送去墓地。
	Duel.SetOperationInfo(0,CATEGORY_DECKDES,nil,0,tp,2)
end
-- ③效果处理：读取之前设定的目标玩家和卡数，将对应玩家的卡组顶端相应数量的卡送去墓地。
function s.disop(e,tp,eg,ep,ev,re,r,rp)
	-- 从当前连锁信息中取出目标玩家（p）和目标参数（d），即“从谁卡组丢几张”。
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 按取得的信息，将玩家p卡组顶d张卡送去墓地，原因为效果。
	Duel.DiscardDeck(p,d,REASON_EFFECT)
end
