--ウィッチクラフト・シュミッタ
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：自己·对方的主要阶段，把这张卡解放，从手卡丢弃1张魔法卡才能发动。从卡组把「魔女术工匠·锻造女巫」以外的1只「魔女术」怪兽特殊召唤。
-- ②：把墓地的这张卡除外才能发动。从卡组把「魔女术工匠·锻造女巫」以外的1张「魔女术」卡送去墓地。
function c21744288.initial_effect(c)
	-- 创建效果，设置描述为“特殊召唤”，类别为特殊召唤，类型为快速启动效果，提示时机为主阶段结束时，代码为自由连锁，生效范围为怪兽区，限制次数为每回合一次，条件为c21744288.spcon，费用为c21744288.spcost，目标为c21744288.sptg，操作为c21744288.spop。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(21744288,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetHintTiming(0,TIMING_MAIN_END)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,21744288)
	e1:SetCondition(c21744288.spcon)
	e1:SetCost(c21744288.spcost)
	e1:SetTarget(c21744288.sptg)
	e1:SetOperation(c21744288.spop)
	c:RegisterEffect(e1)
	-- 创建效果，设置描述为“送去墓地”，类别为送去墓地，类型为起动效果，生效范围为墓地，限制次数为每回合一次，费用为aux.bfgcost，目标为c21744288.tgtg，操作为c21744288.tgop。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(21744288,1))  --"送去墓地"
	e2:SetCategory(CATEGORY_TOGRAVE)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,21744289)
	-- 使用简写方法设置将这张卡除外的费用条件。
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(c21744288.tgtg)
	e2:SetOperation(c21744288.tgop)
	c:RegisterEffect(e2)
end
-- 定义特殊召唤效果的条件函数spcon，判断当前阶段是否为主阶段1或主阶段2。
function c21744288.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 返回当前阶段是否为主要阶段1或者主要阶段2
	return Duel.GetCurrentPhase()==PHASE_MAIN1 or Duel.GetCurrentPhase()==PHASE_MAIN2
end
-- 定义costfilter函数，用于过滤可作为特殊召唤费用的卡片。如果卡片在手牌区域，则检查是否为魔法卡且可以丢弃；否则，检查是否为面朝上表侧表示的卡片、能够作为费用送去墓地以及是否具有效果83289866（可能与特定机制相关），或者不为32353566，属于0x128系列卡组，是魔法或陷阱卡且可以丢弃，并且在卡组区域且res为真。
function c21744288.costfilter(c,tp,res)
	if c:IsLocation(LOCATION_HAND) then return c:IsType(TYPE_SPELL) and c:IsDiscardable() end
	return c:IsFaceup() and c:IsAbleToGraveAsCost() and c:IsHasEffect(83289866,tp)
		or not c:IsCode(32353566) and c:IsSetCard(0x128)
		and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsAbleToGraveAsCost()
		and c:IsLocation(LOCATION_DECK) and res
end
-- 定义特殊召唤效果的费用函数spcost。首先判断玩家是否受到效果32353566的影响以及当前处理的卡片是否属于0x128系列。如果chk为0，则返回当前处理的卡片是否可以解放，并且存在满足costfilter条件的卡片；
function c21744288.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家是否受到效果32353566的影响，并判断当前处理的卡片是否属于0x128系列。
	local res=Duel.IsPlayerAffectedByEffect(tp,32353566) and e:GetHandler():IsSetCard(0x128)
	if chk==0 then return e:GetHandler():IsReleasable()
		-- 如果chk为0，则返回当前处理的卡片是否可以解放，并且存在满足costfilter条件的卡片
		and Duel.IsExistingMatchingCard(c21744288.costfilter,tp,LOCATION_HAND+LOCATION_SZONE+LOCATION_DECK,0,1,nil,tp,res) end
	-- 获取满足costfilter条件的卡组。
	local g=Duel.GetMatchingGroup(c21744288.costfilter,tp,LOCATION_HAND+LOCATION_SZONE+LOCATION_DECK,0,nil,tp,res)
	-- 提示玩家选择要丢弃的手牌。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISCARD)  --"请选择要丢弃的手牌"
	local tc=g:Select(tp,1,1,nil):GetFirst()
	-- 以费用原因解放当前处理的卡片。
	Duel.Release(e:GetHandler(),REASON_COST)
	if not tc:IsLocation(LOCATION_HAND) then
		local te=tc:IsHasEffect(83289866,tp)
		if te then
			te:UseCountLimit(tp)
			-- 注册一个标识效果，用于标记特定代码的卡片，并在阶段结束时重置。
			Duel.RegisterFlagEffect(tp,tc:GetCode(),RESET_PHASE+PHASE_END,0,1)
		end
		-- 将选定的卡片送去墓地作为费用。
		Duel.SendtoGrave(tc,REASON_COST)
	else
		-- 如果选择的是手牌，则以丢弃和费用原因送去墓地；否则，以费用原因送去墓地。
		Duel.SendtoGrave(tc,REASON_COST+REASON_DISCARD)
	end
end
-- 定义spfilter函数，用于过滤可特殊召唤的卡片。检查卡片是否属于0x128系列、不为当前卡片的代码（21744288），以及是否可以被特殊召唤。
function c21744288.spfilter(c,e,tp)
	return c:IsSetCard(0x128) and not c:IsCode(21744288) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 定义sptg函数，作为特殊召唤效果的目标选择器。如果chk为0，则返回怪兽区数量大于0且存在满足spfilter条件的卡片。
function c21744288.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查怪兽区是否有空位
	if chk==0 then return Duel.GetMZoneCount(tp,e:GetHandler())>0
		-- 并且存在满足spfilter条件的卡片
		and Duel.IsExistingMatchingCard(c21744288.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置操作信息，表示当前处理的连锁是特殊召唤效果，目标数量为1，位置在卡组。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 定义特殊召唤效果的操作函数spop。如果怪兽区没有空位则返回。提示玩家选择要特殊召唤的卡片，然后从满足spfilter条件的卡组中选择一张并进行特殊召唤。
function c21744288.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 如果怪兽区已满则直接结束
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从满足spfilter条件的卡组中选择一张卡片
	local g=Duel.SelectMatchingCard(tp,c21744288.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选定的卡片以指定方式特殊召唤到场上。
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 定义tgfilter函数，用于过滤可送去墓地的卡片。检查卡片是否属于0x128系列、不为当前卡片的代码（21744288），以及是否可以送去墓地。
function c21744288.tgfilter(c)
	return c:IsSetCard(0x128) and not c:IsCode(21744288) and c:IsAbleToGrave()
end
-- 定义tgtg函数，作为送去墓地效果的目标选择器。如果chk为0，则返回存在满足tgfilter条件的卡片。
function c21744288.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否存在满足tgfilter条件的卡片
	if chk==0 then return Duel.IsExistingMatchingCard(c21744288.tgfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息，表示当前处理的连锁是送去墓地的效果，目标数量为1，位置在卡组。
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end
-- 定义送去墓地效果的操作函数tgop。提示玩家选择要送去墓地的卡片，然后从满足tgfilter条件的卡组中选择一张并送去墓地。
function c21744288.tgop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要送去墓地的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 从满足tgfilter条件的卡组中选择一张卡片
	local g=Duel.SelectMatchingCard(tp,c21744288.tgfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选定的卡片以效果原因送去墓地。
		Duel.SendtoGrave(g,REASON_EFFECT)
	end
end
