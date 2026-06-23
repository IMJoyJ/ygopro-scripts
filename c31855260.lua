--ミュートリアスの産声
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：自己·对方的主要阶段才能发动。从自己的场上·墓地的怪兽以及除外的自己怪兽之中让「秘异三变」融合怪兽卡决定的融合素材怪兽回到持有者卡组，把那1只融合怪兽从额外卡组融合召唤。
function c31855260.initial_effect(c)
	-- 创建效果，设置效果分类为送入卡组、特殊召唤、融合召唤，效果类型为发动，时点为自由连锁，发动次数限制为1次，提示时点为怪兽正面上场或主要阶段结束，效果条件为主要阶段，效果目标为选择融合怪兽，效果处理为发动融合召唤
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
-- 效果条件：当前阶段为主要阶段1或主要阶段2
function c31855260.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 当前阶段为主要阶段1或主要阶段2
	return Duel.GetCurrentPhase()==PHASE_MAIN1 or Duel.GetCurrentPhase()==PHASE_MAIN2
end
-- 过滤函数：满足位置在场上或墓地或表侧表示，且为怪兽卡，且可作为融合素材，且可送入卡组
function c31855260.filter0(c)
	return (c:IsLocation(LOCATION_ONFIELD+LOCATION_GRAVE) or c:IsFaceup()) and c:IsType(TYPE_MONSTER) and c:IsCanBeFusionMaterial() and c:IsAbleToDeck()
end
-- 过滤函数：满足位置在场上或墓地或表侧表示，且为怪兽卡，且可作为融合素材，且可送入卡组，且不受该效果影响
function c31855260.filter1(c,e)
	return (c:IsLocation(LOCATION_ONFIELD+LOCATION_GRAVE) or c:IsFaceup()) and c:IsType(TYPE_MONSTER) and c:IsCanBeFusionMaterial() and c:IsAbleToDeck() and not c:IsImmuneToEffect(e)
end
-- 过滤函数：满足为融合怪兽卡，且为秘异三变卡组，且可特殊召唤，且可检查融合素材
function c31855260.filter2(c,e,tp,m,f,chkf)
	return c:IsType(TYPE_FUSION) and c:IsSetCard(0x157) and (not f or f(c))
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_FUSION,tp,false,false) and c:CheckFusionMaterial(m,nil,chkf)
end
-- 效果目标：检查是否存在满足条件的融合怪兽，若不存在则检查连锁素材是否存在满足条件的融合怪兽，若存在则返回true
function c31855260.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local chkf=tp
		-- 获取满足条件的怪兽组，位置为场上、墓地、除外区
		local mg=Duel.GetMatchingGroup(c31855260.filter0,tp,LOCATION_ONFIELD+LOCATION_GRAVE+LOCATION_REMOVED,0,nil)
		-- 检查是否存在满足条件的融合怪兽
		local res=Duel.IsExistingMatchingCard(c31855260.filter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg,nil,chkf)
		if not res then
			-- 获取当前玩家受到的连锁素材效果
			local ce=Duel.GetChainMaterial(tp)
			if ce~=nil then
				local fgroup=ce:GetTarget()
				local mg3=fgroup(ce,e,tp)
				local mf=ce:GetValue()
				-- 检查是否存在满足连锁素材条件的融合怪兽
				res=Duel.IsExistingMatchingCard(c31855260.filter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg3,mf,chkf)
			end
		end
		return res
	end
	-- 设置操作信息：特殊召唤1只融合怪兽到玩家场上
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
	-- 设置操作信息：将1只怪兽送入卡组
	Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,1,tp,LOCATION_ONFIELD+LOCATION_GRAVE+LOCATION_REMOVED)
end
-- 效果处理：获取满足条件的融合怪兽组，若存在则选择1只融合怪兽进行融合召唤，否则使用连锁素材进行融合召唤
function c31855260.activate(e,tp,eg,ep,ev,re,r,rp)
	local chkf=tp
	-- 获取满足条件的怪兽组，位置为场上、墓地、除外区，且不受王家长眠之谷影响
	local mg=Duel.GetMatchingGroup(aux.NecroValleyFilter(c31855260.filter1),tp,LOCATION_ONFIELD+LOCATION_GRAVE+LOCATION_REMOVED,0,nil,e)
	-- 获取满足条件的融合怪兽组，位置为额外卡组
	local sg1=Duel.GetMatchingGroup(c31855260.filter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg,nil,chkf)
	local mg3=nil
	local sg2=nil
	-- 获取当前玩家受到的连锁素材效果
	local ce=Duel.GetChainMaterial(tp)
	if ce~=nil then
		local fgroup=ce:GetTarget()
		mg3=fgroup(ce,e,tp)
		local mf=ce:GetValue()
		-- 获取满足连锁素材条件的融合怪兽组
		sg2=Duel.GetMatchingGroup(c31855260.filter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg3,mf,chkf)
	end
	if sg1:GetCount()>0 or (sg2~=nil and sg2:GetCount()>0) then
		local sg=sg1:Clone()
		if sg2 then sg:Merge(sg2) end
		-- 提示玩家选择要特殊召唤的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		local tg=sg:Select(tp,1,1,nil)
		local tc=tg:GetFirst()
		-- 判断是否使用原融合怪兽进行融合召唤，若使用则继续处理，否则使用连锁素材进行融合召唤
		if sg1:IsContains(tc) and (sg2==nil or not sg2:IsContains(tc) or not Duel.SelectYesNo(tp,ce:GetDescription())) then
			-- 选择融合怪兽的融合素材
			local mat=Duel.SelectFusionMaterial(tp,tc,mg,nil,chkf)
			tc:SetMaterial(mat)
			if mat:IsExists(Card.IsFacedown,1,nil) then
				local cg=mat:Filter(Card.IsFacedown,nil)
				-- 确认对方玩家看到被选为融合素材的卡
				Duel.ConfirmCards(1-tp,cg)
			end
			if mat:Filter(c31855260.cfilter,nil):GetCount()>0 then
				local cg=mat:Filter(c31855260.cfilter,nil)
				-- 显示被选为融合素材的卡
				Duel.HintSelection(cg)
			end
			-- 将融合素材送入卡组
			Duel.SendtoDeck(mat,nil,SEQ_DECKSHUFFLE,REASON_EFFECT+REASON_MATERIAL+REASON_FUSION)
			-- 中断当前效果
			Duel.BreakEffect()
			-- 将融合怪兽特殊召唤到场上
			Duel.SpecialSummon(tc,SUMMON_TYPE_FUSION,tp,tp,false,false,POS_FACEUP)
		else
			-- 选择连锁素材的融合怪兽的融合素材
			local mat2=Duel.SelectFusionMaterial(tp,tc,mg3,nil,chkf)
			local fop=ce:GetOperation()
			fop(ce,e,tp,tc,mat2)
		end
		tc:CompleteProcedure()
	end
end
-- 过滤函数：满足位置在墓地或除外区，或位置在场上且表侧表示
function c31855260.cfilter(c)
	return c:IsLocation(LOCATION_GRAVE+LOCATION_REMOVED) or (c:IsLocation(LOCATION_MZONE) and c:IsFaceup())
end
