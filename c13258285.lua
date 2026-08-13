--Uk－P.U.N.K.娑楽斎
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：支付600基本分才能发动。自己的手卡·场上的怪兽作为融合素材，把1只「朋克」融合怪兽融合召唤。
-- ②：对方回合，支付600基本分才能发动。进行1只「朋克」同调怪兽的同调召唤。
function c13258285.initial_effect(c)
	-- 这个卡名的①②的效果1回合各能使用1次。①：支付600基本分才能发动。自己的手卡·场上的怪兽作为融合素材，把1只「朋克」融合怪兽融合召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(13258285,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,13258285)
	e1:SetCost(c13258285.spcost)
	e1:SetTarget(c13258285.sptg)
	e1:SetOperation(c13258285.spop)
	c:RegisterEffect(e1)
	-- ②：对方回合，支付600基本分才能发动。进行1只「朋克」同调怪兽的同调召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(13258285,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,13258286)
	e2:SetCondition(c13258285.sccon)
	e2:SetCost(c13258285.sccost)
	e2:SetTarget(c13258285.sctarg)
	e2:SetOperation(c13258285.scop)
	c:RegisterEffect(e2)
end
-- 效果①的代价函数：先检查是否满足支付600基本分的条件，若满足则实际支付600基本分以发动。
function c13258285.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 代价检查：确认玩家当前能否支付600基本分（chk==0表示发动前合法性检查）。
	if chk==0 then return Duel.CheckLPCost(tp,600) end
	-- 实际扣除玩家600基本分作为发动代价。
	Duel.PayLPCost(tp,600)
end
-- 素材过滤函数：仅选择不受当前效果影响（即不免疫此效果）的怪兽，保证它们能作为融合素材被使用。
function c13258285.spfilter1(c,e)
	return not c:IsImmuneToEffect(e)
end
-- 融合怪兽候选过滤函数：检查额外卡组中的卡是否为「朋克」族融合怪兽、能否以给定素材（m）满足融合素材条件、并可以被融合召唤特殊召唤。
function c13258285.spfilter2(c,e,tp,m,f,chkf)
	return c:IsType(TYPE_FUSION) and c:IsSetCard(0x171) and (not f or f(c))
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_FUSION,tp,false,false) and c:CheckFusionMaterial(m,nil,chkf)
end
-- 效果①的发动条件/目标函数：验证是否存在可用当前素材进行融合召唤的「朋克」融合怪兽（包括连锁素材的情况），存在则效果可发动。
function c13258285.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local chkf=tp
		-- 获取玩家当前可用的全部融合素材，包含手卡、场上的怪兽以及受额外融合素材效果影响的卡。
		local mg1=Duel.GetFusionMaterial(tp)
		-- 用普通素材组检查额外卡组中是否存在至少1只满足spfilter2条件的「朋克」融合怪兽。
		local res=Duel.IsExistingMatchingCard(c13258285.spfilter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg1,nil,chkf)
		if not res then
			-- 获取当前玩家适用的连锁素材效果（若存在），用于扩展融合素材范围。
			local ce=Duel.GetChainMaterial(tp)
			if ce~=nil then
				local fgroup=ce:GetTarget()
				local mg2=fgroup(ce,e,tp)
				local mf=ce:GetValue()
				-- 使用连锁素材提供的素材组mg2及追加条件mf，再次检查额外卡组是否存在可融合召唤的「朋克」融合怪兽。
				res=Duel.IsExistingMatchingCard(c13258285.spfilter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg2,mf,chkf)
			end
		end
		return res
	end
	-- 设置效果操作信息：本次效果将执行特殊召唤，目标区域为额外卡组（用于发动时点检测）。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- 效果①处理：让玩家选择融合召唤的「朋克」融合怪兽，选择融合素材，将素材送入墓地并将怪兽融合召唤；若选择使用连锁素材，则按连锁素材效果处理。
function c13258285.spop(e,tp,eg,ep,ev,re,r,rp)
	local chkf=tp
	-- 处理时获取普通融合素材，并排除不受当前效果影响的卡，得到实际可用于融合的素材组mg1。
	local mg1=Duel.GetFusionMaterial(tp):Filter(c13258285.spfilter1,nil,e)
	-- 基于普通素材mg1，获取额外卡组中所有可融合召唤的「朋克」融合怪兽候选集合sg1。
	local sg1=Duel.GetMatchingGroup(c13258285.spfilter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg1,nil,chkf)
	local mg2=nil
	local sg2=nil
	-- 处理时再次获取连锁素材效果（ce），用于处理扩展素材的情况。
	local ce=Duel.GetChainMaterial(tp)
	if ce~=nil then
		local fgroup=ce:GetTarget()
		mg2=fgroup(ce,e,tp)
		local mf=ce:GetValue()
		-- 基于连锁素材提供的素材组mg2及条件mf，获取额外卡组中所有可融合召唤的「朋克」融合怪兽候选集合sg2。
		sg2=Duel.GetMatchingGroup(c13258285.spfilter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg2,mf,chkf)
	end
	if sg1:GetCount()>0 or (sg2~=nil and sg2:GetCount()>0) then
		local sg=sg1:Clone()
		if sg2 then sg:Merge(sg2) end
		-- 提示玩家从候选融合怪兽中选择1只要特殊召唤的卡。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		local tg=sg:Select(tp,1,1,nil)
		local tc=tg:GetFirst()
		-- 判断融合路径：若选中的怪兽在普通素材候选内且（不存在连锁素材候选或玩家拒绝使用连锁素材），则使用普通素材融合；否则使用连锁素材。
		if sg1:IsContains(tc) and (sg2==nil or not sg2:IsContains(tc) or not Duel.SelectYesNo(tp,ce:GetDescription())) then
			-- 让玩家从普通素材组中选择符合融合条件的一组素材，并确定作为本次融合召唤的素材。
			local mat1=Duel.SelectFusionMaterial(tp,tc,mg1,nil,chkf)
			tc:SetMaterial(mat1)
			-- 将选择的融合素材按效果·素材·融合召唤的原因（REASON_EFFECT+REASON_MATERIAL+REASON_FUSION）送入墓地。
			Duel.SendtoGrave(mat1,REASON_EFFECT+REASON_MATERIAL+REASON_FUSION)
			-- 中断当前效果链，使后续特殊召唤和之前的素材处理视为不同时处理，以免错过时点。
			Duel.BreakEffect()
			-- 将融合怪兽以表侧表示特殊召唤上场，作为融合召唤（SUMMON_TYPE_FUSION）完成融合召唤手续。
			Duel.SpecialSummon(tc,SUMMON_TYPE_FUSION,tp,tp,false,false,POS_FACEUP)
		else
			-- 当使用连锁素材时，让玩家从连锁素材提供的素材组中选择融合素材mat2。
			local mat2=Duel.SelectFusionMaterial(tp,tc,mg2,nil,chkf)
			local fop=ce:GetOperation()
			fop(ce,e,tp,tc,mat2)
		end
		tc:CompleteProcedure()
	end
end
-- 效果②的发动条件函数：仅当当前回合玩家不是自己（即对方回合）时，才允许发动②效果。
function c13258285.sccon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前回合玩家是否不是自己（即是否对方回合），是则满足②效果发动条件。
	return Duel.GetTurnPlayer()~=tp
end
-- 效果②的代价函数：先检查是否满足支付600基本分的条件，若满足则实际支付600基本分以发动。
function c13258285.sccost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 代价检查：确认玩家当前能否支付600基本分（②效果发动前合法性检查）。
	if chk==0 then return Duel.CheckLPCost(tp,600) end
	-- 实际扣除玩家600基本分作为②效果的发动代价。
	Duel.PayLPCost(tp,600)
end
-- 同调怪兽候选过滤函数：检查额外卡组中的卡是否为「朋克」同调怪兽，且当前能否以场上素材进行同调召唤。
function c13258285.syncfilter(c)
	return c:IsSetCard(0x171) and c:IsSynchroSummonable(nil)
end
-- 效果②的发动条件/目标函数：确认额外卡组存在能同调召唤的「朋克」同调怪兽，存在则效果可发动。
function c13258285.sctarg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在额外卡组中检索是否存在至少1只满足同调召唤条件的「朋克」同调怪兽（chk==0为发动前合法性检查）。
	if chk==0 then return Duel.IsExistingMatchingCard(c13258285.syncfilter,tp,LOCATION_EXTRA,0,1,nil) end
	-- 设置效果操作信息：本次效果将执行特殊召唤，目标区域为额外卡组。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- 效果②处理：选择一只「朋克」同调怪兽，使用场上素材进行同调召唤特殊召唤。
function c13258285.scop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取额外卡组中所有满足同调召唤条件的「朋克」同调怪兽的集合g。
	local g=Duel.GetMatchingGroup(c13258285.syncfilter,tp,LOCATION_EXTRA,0,nil)
	if g:GetCount()>0 then
		-- 提示玩家从同调候选怪兽中选择1只要特殊召唤的卡。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		local sg=g:Select(tp,1,1,nil)
		-- 执行同调召唤手续，将选择的同调怪兽以同调召唤方式特殊召唤到场上。
		Duel.SynchroSummon(tp,sg:GetFirst(),nil)
	end
end
