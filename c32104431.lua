--破壊剣の追憶
-- 效果：
-- ①：从手卡丢弃1张「破坏剑」卡才能发动。从卡组把1只「破坏之剑士」怪兽特殊召唤。
-- ②：把墓地的这张卡除外才能发动。「龙破坏的剑士-破坏之剑士」决定的融合素材怪兽从自己墓地除外，把那1只融合怪兽从额外卡组融合召唤。
function c32104431.initial_effect(c)
	-- ①：从手卡丢弃1张「破坏剑」卡才能发动。从卡组把1只「破坏之剑士」怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCost(c32104431.cost)
	e1:SetTarget(c32104431.target)
	e1:SetOperation(c32104431.operation)
	c:RegisterEffect(e1)
	-- ②：把墓地的这张卡除外才能发动。「龙破坏的剑士-破坏之剑士」决定的融合素材怪兽从自己墓地除外，把那1只融合怪兽从额外卡组融合召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetHintTiming(0,TIMINGS_CHECK_MONSTER)
	e2:SetRange(LOCATION_GRAVE)
	-- 设置效果的发动代价为把墓地中的这张卡除外（aux.bfgcost实现了除外自身作为COST）。
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(c32104431.fusiontg)
	e2:SetOperation(c32104431.fusionop)
	c:RegisterEffect(e2)
end
-- 定义丢弃代价的筛选条件：手卡中的卡属于「破坏剑」字段（0xd6）且可以丢弃。
function c32104431.costfilter(c)
	return c:IsSetCard(0xd6) and c:IsDiscardable()
end
-- 效果的发动代价检查与执行：chk==0时检查是否存在可丢弃的「破坏剑」卡；实际发动时从手卡丢弃1张符合条件的卡作为代价。
function c32104431.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 代价检查：确认手卡中存在至少1张可丢弃且不属于效果卡自身的「破坏剑」卡。
	if chk==0 then return Duel.IsExistingMatchingCard(c32104431.costfilter,tp,LOCATION_HAND,0,1,e:GetHandler()) end
	-- 执行代价：让玩家从手卡选择1张满足costfilter的卡，以COST和DISCARD原因丢弃。
	Duel.DiscardHand(tp,c32104431.costfilter,1,1,REASON_COST+REASON_DISCARD)
end
-- 定义特殊召唤的筛选条件：卡属于「破坏之剑士」字段（0xd7）且可以被玩家tp用效果e特殊召唤。
function c32104431.spfilter(c,e,tp)
	return c:IsSetCard(0xd7) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果发动目标检查：主要怪兽区域有空位，且卡组中存在可特殊召唤的「破坏之剑士」怪兽。
function c32104431.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家tp的主要怪兽区域是否有空闲位置用于特殊召唤。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查卡组中是否存在至少1只满足spfilter的「破坏之剑士」怪兽。
		and Duel.IsExistingMatchingCard(c32104431.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置操作信息：声明本效果将从卡组特殊召唤1只怪兽。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 效果处理：若主要怪兽区域无空位则终止；提示玩家选择要特殊召唤的卡，从卡组选1只「破坏之剑士」怪兽以表侧表示特殊召唤。
function c32104431.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 如果主要怪兽区域没有空位，则直接结束效果处理。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 向玩家显示“请选择要特殊召唤的卡”的提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从卡组中选择1张满足spfilter的「破坏之剑士」怪兽。
	local g=Duel.SelectMatchingCard(tp,c32104431.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选择的怪兽以表侧表示特殊召唤到玩家tp的场上。
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 定义墓地融合素材候选的过滤条件：必须是怪兽、可作为融合素材、可以被除外。
function c32104431.filter0(c)
	return c:IsType(TYPE_MONSTER) and c:IsCanBeFusionMaterial() and c:IsAbleToRemove()
end
-- 定义效果处理时墓地融合素材的过滤条件：在filter0基础上增加不免疫此效果。
function c32104431.filter1(c,e)
	return c:IsType(TYPE_MONSTER) and c:IsCanBeFusionMaterial() and c:IsAbleToRemove() and not c:IsImmuneToEffect(e)
end
-- 定义额外卡组融合怪兽的过滤条件：必须是融合怪兽且卡号为86240887、满足融合素材条件、并能以融合召唤方式特殊召唤。
function c32104431.filter2(c,e,tp,m,f,chkf)
	return c:IsType(TYPE_FUSION) and c:IsCode(86240887) and (not f or f(c))
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_FUSION,tp,false,false) and c:CheckFusionMaterial(m,nil,chkf)
end
-- 融合召唤的效果发动目标检查：检查能否用墓地素材（或连锁素材）融合召唤「龙破坏的剑士-破坏之剑士」，并设置操作信息。
function c32104431.fusiontg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local chkf=tp
		-- 获取自己墓地的所有可作为融合素材的怪兽。
		local mg1=Duel.GetMatchingGroup(c32104431.filter0,tp,LOCATION_GRAVE,0,nil)
		-- 检查额外卡组是否存在能用这些墓地素材融合召唤的「龙破坏的剑士-破坏之剑士」。
		local res=Duel.IsExistingMatchingCard(c32104431.filter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg1,nil,chkf)
		if not res then
			-- 获取玩家tp适用的连锁素材效果（若存在）。
			local ce=Duel.GetChainMaterial(tp)
			if ce~=nil then
				local fgroup=ce:GetTarget()
				local mg2=fgroup(ce,e,tp)
				local mf=ce:GetValue()
				-- 检查用连锁素材提供的替代素材时，额外卡组是否存在可融合召唤的对象。
				res=Duel.IsExistingMatchingCard(c32104431.filter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg2,mf,chkf)
			end
		end
		return res
	end
	-- 设置操作信息：本次效果将进行额外卡组的特殊召唤。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
	-- 设置操作信息：本次效果将除外自己墓地的卡。
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,tp,LOCATION_GRAVE)
end
-- 融合召唤处理：获取墓地素材和额外怪兽，结合连锁素材的替代素材，选择要融合召唤的怪兽并执行对应的素材选取、除外、特殊召唤流程。
function c32104431.fusionop(e,tp,eg,ep,ev,re,r,rp)
	local chkf=tp
	-- 获取墓地中可作为融合素材且不免疫此效果的怪兽。
	local mg1=Duel.GetMatchingGroup(c32104431.filter1,tp,LOCATION_GRAVE,0,nil,e)
	-- 获取额外卡组中能用这些墓地素材融合召唤的「龙破坏的剑士-破坏之剑士」。
	local sg1=Duel.GetMatchingGroup(c32104431.filter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg1,nil,chkf)
	local mg2=nil
	local sg2=nil
	-- 获取连锁素材效果，用于后续替代素材判定。
	local ce=Duel.GetChainMaterial(tp)
	if ce~=nil then
		local fgroup=ce:GetTarget()
		mg2=fgroup(ce,e,tp)
		local mf=ce:GetValue()
		-- 获取用连锁素材提供的替代素材可融合召唤的「龙破坏的剑士-破坏之剑士」集合。
		sg2=Duel.GetMatchingGroup(c32104431.filter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg2,mf,chkf)
	end
	if sg1:GetCount()>0 or (sg2~=nil and sg2:GetCount()>0) then
		local sg=sg1:Clone()
		if sg2 then sg:Merge(sg2) end
		-- 提示玩家选择要特殊召唤的融合怪兽。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		local tg=sg:Select(tp,1,1,nil)
		local tc=tg:GetFirst()
		-- 判断选中的融合怪兽是否走通常墓地融合路线：当它来自普通素材组，且（不在连锁素材组中或玩家选择不使用连锁素材时）执行通常流程；否则使用连锁素材流程。
		if sg1:IsContains(tc) and (sg2==nil or not sg2:IsContains(tc) or not Duel.SelectYesNo(tp,ce:GetDescription())) then
			-- 从墓地素材组中选择用于融合召唤当前怪兽的融合素材。
			local mat1=Duel.SelectFusionMaterial(tp,tc,mg1,nil,chkf)
			tc:SetMaterial(mat1)
			-- 将选择的融合素材除外，原因为效果、融合素材、融合召唤。
			Duel.Remove(mat1,POS_FACEUP,REASON_EFFECT+REASON_MATERIAL+REASON_FUSION)
			-- 中断当前效果处理，使之后的特殊召唤视为不同时处理，避免时点错误。
			Duel.BreakEffect()
			-- 将融合怪兽以融合召唤方式特殊召唤到玩家tp的场上。
			Duel.SpecialSummon(tc,SUMMON_TYPE_FUSION,tp,tp,false,false,POS_FACEUP)
		else
			-- 从连锁素材提供的替代素材组中选择用于融合召唤当前怪兽的融合素材。
			local mat2=Duel.SelectFusionMaterial(tp,tc,mg2,nil,chkf)
			local fop=ce:GetOperation()
			fop(ce,e,tp,tc,mat2)
		end
		tc:CompleteProcedure()
	end
end
