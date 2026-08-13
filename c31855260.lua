--ミュートリアスの産声
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：自己·对方的主要阶段才能发动。从自己的场上·墓地的怪兽以及除外的自己怪兽之中让「秘异三变」融合怪兽卡决定的融合素材怪兽回到持有者卡组，把那1只融合怪兽从额外卡组融合召唤。
function c31855260.initial_effect(c)
	-- 这个卡名的卡在1回合只能发动1张。①：自己·对方的主要阶段才能发动。从自己的场上·墓地的怪兽以及除外的自己怪兽之中让「秘异三变」融合怪兽卡决定的融合素材怪兽回到持有者卡组，把那1只融合怪兽从额外卡组融合召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TODECK+CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,31855260+EFFECT_COUNT_CODE_OATH)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_MAIN_END)
	e1:SetCondition(c31855260.condition)
	e1:SetTarget(c31855260.target)
	e1:SetOperation(c31855260.activate)
	c:RegisterEffect(e1)
end
-- 定义效果发动条件的函数：仅当当前阶段为主要阶段1或主要阶段2时，该效果才能发动。
function c31855260.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前阶段是否为主要阶段1或主要阶段2。
	return Duel.GetCurrentPhase()==PHASE_MAIN1 or Duel.GetCurrentPhase()==PHASE_MAIN2
end
-- 定义发动时检索可用融合素材的过滤条件：位于自己场上·墓地的怪兽，或表侧表示除外的自己怪兽，且为怪兽、可作为融合素材、可回到持有者卡组。
function c31855260.filter0(c)
	return (c:IsLocation(LOCATION_ONFIELD+LOCATION_GRAVE) or c:IsFaceup()) and c:IsType(TYPE_MONSTER) and c:IsCanBeFusionMaterial() and c:IsAbleToDeck()
end
-- 定义效果处理时实际选择融合素材的过滤条件：在可回卡组、可作为融合素材的怪兽基础上，追加要求不免疫当前效果。
function c31855260.filter1(c,e)
	return (c:IsLocation(LOCATION_ONFIELD+LOCATION_GRAVE) or c:IsFaceup()) and c:IsType(TYPE_MONSTER) and c:IsCanBeFusionMaterial() and c:IsAbleToDeck() and not c:IsImmuneToEffect(e)
end
-- 定义可融合召唤的「秘异三变」融合怪兽的过滤条件：额外卡组的融合怪兽，字段为「秘异三变」，可用候选素材进行融合召唤，并且满足特殊召唤限制。
function c31855260.filter2(c,e,tp,m,f,chkf)
	return c:IsType(TYPE_FUSION) and c:IsSetCard(0x157) and (not f or f(c))
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_FUSION,tp,false,false) and c:CheckFusionMaterial(m,nil,chkf)
end
-- 效果发动时的目标判定与操作信息：检查是否存在能用自己场上·墓地·除外的素材融合召唤的「秘异三变」融合怪兽，并设置回卡组与特殊召唤的操作信息。
function c31855260.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local chkf=tp
		-- 获取所有可作为融合素材的候选怪兽群，包括自己场上·墓地的怪兽以及表侧表示的除外自己怪兽。
		local mg=Duel.GetMatchingGroup(c31855260.filter0,tp,LOCATION_ONFIELD+LOCATION_GRAVE+LOCATION_REMOVED,0,nil)
		-- 检查额外卡组中是否存在至少1只能用该素材组进行融合召唤的「秘异三变」融合怪兽。
		local res=Duel.IsExistingMatchingCard(c31855260.filter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg,nil,chkf)
		if not res then
			-- 获取当前玩家适用的连锁素材效果（若有），用于判断是否可以使用连锁素材提供的替代融合素材组。
			local ce=Duel.GetChainMaterial(tp)
			if ce~=nil then
				local fgroup=ce:GetTarget()
				local mg3=fgroup(ce,e,tp)
				local mf=ce:GetValue()
				-- 使用连锁素材效果提供的素材组，再次检查额外卡组中是否存在可融合召唤的「秘异三变」融合怪兽。
				res=Duel.IsExistingMatchingCard(c31855260.filter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg3,mf,chkf)
			end
		end
		return res
	end
	-- 设置操作信息：本次效果将特殊召唤额外卡组的1只怪兽。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
	-- 设置操作信息：本次效果将把来源为自己场上·墓地·除外区的融合素材送回持有者卡组。
	Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,1,tp,LOCATION_ONFIELD+LOCATION_GRAVE+LOCATION_REMOVED)
end
-- 效果处理：从可用素材中为选定的「秘异三变」融合怪兽选择融合素材，将素材送回持有者卡组并洗牌，然后把该融合怪兽融合召唤；若玩家选择使用连锁素材效果，则按连锁素材效果执行融合。
function c31855260.activate(e,tp,eg,ep,ev,re,r,rp)
	local chkf=tp
	-- 获取效果处理时可用的融合素材怪兽群，同时排除因王家长眠之谷等效果无法回卡组、以及免疫本效果的卡。
	local mg=Duel.GetMatchingGroup(aux.NecroValleyFilter(c31855260.filter1),tp,LOCATION_ONFIELD+LOCATION_GRAVE+LOCATION_REMOVED,0,nil,e)
	-- 获取额外卡组中所有能用普通素材组进行融合召唤的「秘异三变」融合怪兽。
	local sg1=Duel.GetMatchingGroup(c31855260.filter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg,nil,chkf)
	local mg3=nil
	local sg2=nil
	-- 获取当前玩家适用的连锁素材效果（若有），用于决定是否走连锁素材的融合处理流程。
	local ce=Duel.GetChainMaterial(tp)
	if ce~=nil then
		local fgroup=ce:GetTarget()
		mg3=fgroup(ce,e,tp)
		local mf=ce:GetValue()
		-- 若存在连锁素材效果，获取额外卡组中所有能用连锁素材提供的素材组进行融合召唤的「秘异三变」融合怪兽。
		sg2=Duel.GetMatchingGroup(c31855260.filter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg3,mf,chkf)
	end
	if sg1:GetCount()>0 or (sg2~=nil and sg2:GetCount()>0) then
		local sg=sg1:Clone()
		if sg2 then sg:Merge(sg2) end
		-- 提示玩家从候选中选择1只要特殊召唤的「秘异三变」融合怪兽。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		local tg=sg:Select(tp,1,1,nil)
		local tc=tg:GetFirst()
		-- 若选中的融合怪兽可使用普通素材进行融合召唤，且玩家未选择使用连锁素材效果，则按通常融合召唤处理；否则改用连锁素材效果处理。
		if sg1:IsContains(tc) and (sg2==nil or not sg2:IsContains(tc) or not Duel.SelectYesNo(tp,ce:GetDescription())) then
			-- 让玩家从普通素材组中为选定的融合怪兽选择一组融合素材。
			local mat=Duel.SelectFusionMaterial(tp,tc,mg,nil,chkf)
			tc:SetMaterial(mat)
			if mat:IsExists(Card.IsFacedown,1,nil) then
				local cg=mat:Filter(Card.IsFacedown,nil)
				-- 将所选的里侧表示融合素材展示给对手确认，以确保回卡组操作公开。
				Duel.ConfirmCards(1-tp,cg)
			end
			if mat:Filter(c31855260.cfilter,nil):GetCount()>0 then
				local cg=mat:Filter(c31855260.cfilter,nil)
				-- 为位于墓地、除外区或场上表侧的融合素材播放选中提示，并记录这些卡被作为融合素材。
				Duel.HintSelection(cg)
			end
			-- 将融合素材送回持有者卡组，并标记洗牌，送回原因是效果、作为融合素材及融合召唤。
			Duel.SendtoDeck(mat,nil,SEQ_DECKSHUFFLE,REASON_EFFECT+REASON_MATERIAL+REASON_FUSION)
			-- 中断当前效果处理，将素材回卡组与后续特殊召唤视为不同时处理，避免时点被错过。
			Duel.BreakEffect()
			-- 将选定的融合怪兽以融合召唤的方式特殊召唤到己方场上，表示形式为表侧攻击表示。
			Duel.SpecialSummon(tc,SUMMON_TYPE_FUSION,tp,tp,false,false,POS_FACEUP)
		else
			-- 当使用连锁素材效果时，让玩家从连锁素材提供的素材组中选择融合素材。
			local mat2=Duel.SelectFusionMaterial(tp,tc,mg3,nil,chkf)
			local fop=ce:GetOperation()
			fop(ce,e,tp,tc,mat2)
		end
		tc:CompleteProcedure()
	end
end
-- 定义需要额外提示的融合素材来源：该素材位于墓地、除外区，或是场上表侧表示的怪兽，用于决定哪些卡需要展示/提示。
function c31855260.cfilter(c)
	return c:IsLocation(LOCATION_GRAVE+LOCATION_REMOVED) or (c:IsLocation(LOCATION_MZONE) and c:IsFaceup())
end
