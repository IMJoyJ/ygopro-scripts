--Uk－P.U.N.K.娑楽斎
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：支付600基本分才能发动。自己的手卡·场上的怪兽作为融合素材，把1只「朋克」融合怪兽融合召唤。
-- ②：对方回合，支付600基本分才能发动。进行1只「朋克」同调怪兽的同调召唤。
function c13258285.initial_effect(c)
	-- ①：支付600基本分才能发动。自己的手卡·场上的怪兽作为融合素材，把1只「朋克」融合怪兽融合召唤。
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
-- 支付600基本分的费用处理函数
function c13258285.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否能支付600基本分
	if chk==0 then return Duel.CheckLPCost(tp,600) end
	-- 支付600基本分
	Duel.PayLPCost(tp,600)
end
-- 过滤函数，用于判断怪兽是否免疫效果
function c13258285.spfilter1(c,e)
	return not c:IsImmuneToEffect(e)
end
-- 过滤函数，用于筛选满足融合召唤条件的「朋克」融合怪兽
function c13258285.spfilter2(c,e,tp,m,f,chkf)
	return c:IsType(TYPE_FUSION) and c:IsSetCard(0x171) and (not f or f(c))
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_FUSION,tp,false,false) and c:CheckFusionMaterial(m,nil,chkf)
end
-- 设置①效果的发动目标处理函数
function c13258285.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local chkf=tp
		-- 获取玩家可用的融合素材组
		local mg1=Duel.GetFusionMaterial(tp)
		-- 检查是否存在满足条件的融合怪兽
		local res=Duel.IsExistingMatchingCard(c13258285.spfilter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg1,nil,chkf)
		if not res then
			-- 获取当前连锁的融合素材效果
			local ce=Duel.GetChainMaterial(tp)
			if ce~=nil then
				local fgroup=ce:GetTarget()
				local mg2=fgroup(ce,e,tp)
				local mf=ce:GetValue()
				-- 检查是否存在满足连锁融合素材条件的融合怪兽
				res=Duel.IsExistingMatchingCard(c13258285.spfilter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg2,mf,chkf)
			end
		end
		return res
	end
	-- 设置连锁操作信息，准备特殊召唤融合怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- 设置①效果的发动处理函数
function c13258285.spop(e,tp,eg,ep,ev,re,r,rp)
	local chkf=tp
	-- 过滤融合素材组中未被免疫的卡片
	local mg1=Duel.GetFusionMaterial(tp):Filter(c13258285.spfilter1,nil,e)
	-- 获取满足融合召唤条件的融合怪兽组
	local sg1=Duel.GetMatchingGroup(c13258285.spfilter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg1,nil,chkf)
	local mg2=nil
	local sg2=nil
	-- 获取当前连锁的融合素材效果
	local ce=Duel.GetChainMaterial(tp)
	if ce~=nil then
		local fgroup=ce:GetTarget()
		mg2=fgroup(ce,e,tp)
		local mf=ce:GetValue()
		-- 获取满足连锁融合素材条件的融合怪兽组
		sg2=Duel.GetMatchingGroup(c13258285.spfilter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg2,mf,chkf)
	end
	if sg1:GetCount()>0 or (sg2~=nil and sg2:GetCount()>0) then
		local sg=sg1:Clone()
		if sg2 then sg:Merge(sg2) end
		-- 提示玩家选择要特殊召唤的融合怪兽
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local tg=sg:Select(tp,1,1,nil)
		local tc=tg:GetFirst()
		-- 判断选择的怪兽是否来自基础融合素材组
		if sg1:IsContains(tc) and (sg2==nil or not sg2:IsContains(tc) or not Duel.SelectYesNo(tp,ce:GetDescription())) then
			-- 选择融合召唤所需的融合素材
			local mat1=Duel.SelectFusionMaterial(tp,tc,mg1,nil,chkf)
			tc:SetMaterial(mat1)
			-- 将融合素材送入墓地
			Duel.SendtoGrave(mat1,REASON_EFFECT+REASON_MATERIAL+REASON_FUSION)
			-- 中断当前效果处理
			Duel.BreakEffect()
			-- 特殊召唤融合怪兽
			Duel.SpecialSummon(tc,SUMMON_TYPE_FUSION,tp,tp,false,false,POS_FACEUP)
		else
			-- 选择连锁融合素材所需的融合素材
			local mat2=Duel.SelectFusionMaterial(tp,tc,mg2,nil,chkf)
			local fop=ce:GetOperation()
			fop(ce,e,tp,tc,mat2)
		end
		tc:CompleteProcedure()
	end
end
-- ②效果的发动条件处理函数
function c13258285.sccon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前回合玩家是否为对手
	return Duel.GetTurnPlayer()~=tp
end
-- 支付600基本分的费用处理函数
function c13258285.sccost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否能支付600基本分
	if chk==0 then return Duel.CheckLPCost(tp,600) end
	-- 支付600基本分
	Duel.PayLPCost(tp,600)
end
-- 过滤函数，用于筛选满足同调召唤条件的「朋克」同调怪兽
function c13258285.syncfilter(c)
	return c:IsSetCard(0x171) and c:IsSynchroSummonable(nil)
end
-- 设置②效果的发动目标处理函数
function c13258285.sctarg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否存在满足条件的同调怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c13258285.syncfilter,tp,LOCATION_EXTRA,0,1,nil) end
	-- 设置连锁操作信息，准备特殊召唤同调怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- 设置②效果的发动处理函数
function c13258285.scop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取满足同调召唤条件的同调怪兽组
	local g=Duel.GetMatchingGroup(c13258285.syncfilter,tp,LOCATION_EXTRA,0,nil)
	if g:GetCount()>0 then
		-- 提示玩家选择要特殊召唤的同调怪兽
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local sg=g:Select(tp,1,1,nil)
		-- 进行同调召唤手续
		Duel.SynchroSummon(tp,sg:GetFirst(),nil)
	end
end
