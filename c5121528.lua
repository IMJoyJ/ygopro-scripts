--巨大戦艦 デリンジャー・コア
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：把手卡1只其他的「巨大战舰」怪兽给对方观看才能发动。这张卡从手卡特殊召唤。那之后，给这张卡放置3个指示物。
-- ②：自己·对方的主要阶段，可以把这张卡1个指示物取除，从以下效果选择1个发动。
-- ●把1张「头目连战」或者有那个卡名记述的魔法·陷阱卡从卡组加入手卡。
-- ●从自己墓地把1只9星以下的「巨大战舰」怪兽特殊召唤。
local s,id,o=GetID()
-- 卡片的初始效果注册函数：登记卡名「头目连战」并允许放置指示物，随后注册①的起动效果（展示手卡其他「巨大战舰」怪兽从手卡特殊召唤并放置3个指示物）和②的诱发即时效果（取除1个指示物选择检索或特殊召唤）。
function s.initial_effect(c)
	-- 将卡号66947414（「头目连战」）登记为这张卡效果文本中记述的卡名，以便检索时识别「有那个卡名记述的魔法·陷阱卡」。
	aux.AddCodeList(c,66947414)
	c:EnableCounterPermit(0x1f)
	-- 对应效果原文：这个卡名的①②的效果1回合各能使用1次。①：把手卡1只其他的「巨大战舰」怪兽给对方观看才能发动。这张卡从手卡特殊召唤。那之后，给这张卡放置3个指示物。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_COUNTER)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id)
	e1:SetCost(s.spcost)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	-- 对应效果原文：这个卡名的①②的效果1回合各能使用1次。②：自己·对方的主要阶段，可以把这张卡1个指示物取除，从以下效果选择1个发动。●把1张「头目连战」或者有那个卡名记述的魔法·陷阱卡从卡组加入手卡。●从自己墓地把1只9星以下的「巨大战舰」怪兽特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"选择效果"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_SEARCH+CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,id+o)
	e2:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_MAIN_END)
	e2:SetCondition(s.thcon)
	e2:SetCost(s.thcost)
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)
end
-- 过滤函数：用于选择手卡中满足条件的「巨大战舰」怪兽——属于卡名带有「巨大战舰」字段、是怪兽卡、且当前不是公开状态。
function s.cfilter(c)
	return c:IsSetCard(0x15) and c:IsType(TYPE_MONSTER) and not c:IsPublic()
end
-- 效果①的发动代价：从手卡选择1只其他的「巨大战舰」怪兽展示给对方，然后洗切手卡。chk==0时只检查是否存在可选卡。
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 代价检查：确认手卡中存在至少1张除了发动效果的本卡以外的「巨大战舰」怪兽可以展示。
	if chk==0 then return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_HAND,0,1,e:GetHandler()) end
	-- 显示选择提示，让玩家选择一张手卡给对方确认。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)  --"请选择给对方确认的卡"
	-- 从手卡选择1张符合条件的「巨大战舰」怪兽（通过排除参数排除本卡自身）。
	local g=Duel.SelectMatchingCard(tp,s.cfilter,tp,LOCATION_HAND,0,1,1,e:GetHandler())
	-- 将选择的手卡展示给对方玩家确认。
	Duel.ConfirmCards(1-tp,g)
	-- 因为展示了手卡，处理完成后洗切手卡，避免信息泄露。
	Duel.ShuffleHand(tp)
end
-- 效果①的发动条件：自己场上有可用的怪兽区域，且这张卡自身满足特殊召唤条件。
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己主要怪兽区是否有空缺，保证特殊召唤不会因无格而失败。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置操作信息：本次效果将特殊召唤这张卡1张，用于连锁相关判定。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 效果①的处理：若这张卡仍然与连锁相关，将其特殊召唤；成功后若还能放置指示物，则中断效果后给这张卡放置3个指示物。
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToChain()
		-- 执行特殊召唤并检查是否成功（返回值不为0）。
		and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)~=0
		and c:IsCanAddCounter(0x1f,3) then
		-- 中断当前效果处理，使后续的放置指示物处理视为另开时点，避免同一次效果处理中产生错误联动。
		Duel.BreakEffect()
		c:AddCounter(0x1f,3)
	end
end
-- 效果②的发动条件：仅在自己或对方的主要阶段可以发动。
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前是否为主要阶段。
	return Duel.IsMainPhase()
end
-- 效果②的发动代价：取除这张卡上的1个指示物作为发动成本。
function s.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsCanRemoveCounter(tp,0x1f,1,REASON_COST) end
	e:GetHandler():RemoveCounter(tp,0x1f,1,REASON_COST)
end
-- 过滤函数：检索目标为「头目连战」本身，或效果文本中记述了「头目连战」的魔法·陷阱卡，且该卡可以加入手卡。
function s.thfilter(c)
	-- 具体判定：卡名是66947414，或是记述了66947414的魔法·陷阱卡，并且不受“不能加入手卡”限制。
	return (c:IsCode(66947414) or aux.IsCodeOrListed(c,66947414) and c:IsType(TYPE_SPELL+TYPE_TRAP)) and c:IsAbleToHand()
end
-- 过滤函数：从墓地选择可特殊召唤的「巨大战舰」怪兽，要求等级在9星以下且符合特殊召唤条件。
function s.spfilter(c,e,tp)
	return c:IsSetCard(0x15) and c:IsLevelBelow(9) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果②的发动目标：分别判断‘检索’和‘特殊召唤’两个选项是否可用，让玩家选择，然后根据选择设置类别和操作信息。
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在满足检索条件的卡（「头目连战」或记述其卡名的魔法·陷阱卡）。
	local b1=Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil)
	-- 检查自己场上是否有空余的怪兽区域，用于特殊召唤选项。
	local b2=Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 同时检查墓地是否存在满足特殊召唤条件的「巨大战舰」怪兽。
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp)
	if chk==0 then return b1 or b2 end
	local op=0
	if b1 or b2 then
		-- 调用选择菜单，让玩家在两个可用效果中选择一个发动（1检索，2特殊召唤）。
		op=aux.SelectFromOptions(tp,
			{b1,aux.Stringid(id,2),1},  --"检索效果"
			{b2,aux.Stringid(id,3),2})  --"特殊召唤"
	end
	e:SetLabel(op)
	if op==1 then
		if e:IsCostChecked() then
			e:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
		end
		-- 当选择检索时，设置操作信息：从卡组将1张卡加入手卡。
		Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
	elseif op==2 then
		if e:IsCostChecked() then
			e:SetCategory(CATEGORY_SPECIAL_SUMMON)
		end
		-- 当选择特殊召唤时，设置操作信息：从墓地特殊召唤1只怪兽。
		Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE)
	end
end
-- 效果②的处理：根据目标阶段选择的标签，执行对应的检索加入手卡或从墓地特殊召唤。
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	if e:GetLabel()==1 then
		-- 提示玩家选择要加入手卡的卡。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
		-- 从卡组选择1张满足检索条件的卡。
		local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
		if g:GetCount()>0 then
			-- 将选择的卡加入其持有者的手卡。
			Duel.SendtoHand(g,nil,REASON_EFFECT)
			-- 将加入手卡的卡展示给对方玩家确认。
			Duel.ConfirmCards(1-tp,g)
		end
	elseif e:GetLabel()==2 then
		-- 提示玩家选择要特殊召唤的卡。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 从墓地选择1张满足条件的「巨大战舰」怪兽，并使用王家长眠之谷过滤器排除墓地效果被无效的卡。
		local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.spfilter),tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
		if g:GetCount()>0 then
			-- 将选择的怪兽以表侧攻击表示特殊召唤到自己场上。
			Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
		end
	end
end
