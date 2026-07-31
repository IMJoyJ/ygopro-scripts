--第５５次GMX試験報告
-- 效果：
-- 自己手卡·场上的怪兽作为融合素材，把1只恐龙族融合怪兽从额外卡组融合召唤。对方场上有怪兽存在的场合，自己卡组的「GMX」怪兽也能有最多1只作为融合素材。
-- 自己主要阶段：可以把墓地的这张卡除外；直到「GMX」卡出现为止从自己卡组上面翻卡，那张「GMX」卡加入手卡，剩下的卡回到卡组。 
-- 「GMX第55次试验报告」的效果1回合只能有1次使用其中任意1个。
local s,id,o=GetID()
-- 初始化两张效果：融合召唤和翻卡
function s.initial_effect(c)
	-- 自己手卡·场上的怪兽作为融合素材，把1只恐龙族融合怪兽从额外卡组融合召唤。对方场上有怪兽存在的场合，自己卡组的「GMX」怪兽也能有最多1只作为融合素材。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"融合召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON+CATEGORY_DECKDES)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.fstg)
	e1:SetOperation(s.fsop)
	c:RegisterEffect(e1)
	-- 自己主要阶段：可以把墓地的这张卡除外；直到「GMX」卡出现为止从自己卡组上面翻卡，那张「GMX」卡加入手卡，剩下的卡回到卡组。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"翻卡"
	e2:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND+CATEGORY_TODECK)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,id)
	-- 设置cost为将墓地的这张卡除外
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(s.digtg)
	e2:SetOperation(s.digop)
	c:RegisterEffect(e2)
end
-- 筛选卡组中可作为融合素材的GMX怪兽（需为怪兽、能作融合素材、能送墓）
function s.matdeckfilter(c)
	return c:IsSetCard(0x1dd) and c:IsType(TYPE_MONSTER) and c:IsCanBeFusionMaterial() and c:IsAbleToGrave()
end
-- 筛选不受效果影响的怪兽（用于融合素材过滤）
function s.matfilter1(c,e)
	return not c:IsImmuneToEffect(e)
end
-- 判断对方场上是否存在怪兽
function s.oppmonster(tp)
	-- 检查对方场上是否有怪兽
	return Duel.IsExistingMatchingCard(aux.TRUE,tp,0,LOCATION_MZONE,1,nil)
end
-- 筛选恐龙族融合怪兽且可用融合素材召唤
function s.fusionfilter(c,e,tp,m,f,chkf)
	return c:IsType(TYPE_FUSION) and c:IsRace(RACE_DINOSAUR) and (not f or f(c))
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_FUSION,tp,false,false) and c:CheckFusionMaterial(m,nil,chkf)
end
-- 融合素材检查：卡组素材不超过1张
function s.fcheck(tp,sg,fc)
	return sg:FilterCount(Card.IsLocation,nil,LOCATION_DECK)<=1
end
-- 融合素材检查：卡组素材不超过1张
function s.gcheck(sg)
	return sg:FilterCount(Card.IsLocation,nil,LOCATION_DECK)<=1
end
-- 融合召唤效果的目标处理
function s.fstg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local chkf=tp
		-- 获取玩家可用的融合素材（手卡·场上怪兽）
		local mg1=Duel.GetFusionMaterial(tp):Filter(s.matfilter1,nil,e)
		if s.oppmonster(tp) then
			-- 获取卡组中可作为融合素材的GMX怪兽
			local mg2=Duel.GetMatchingGroup(s.matdeckfilter,tp,LOCATION_DECK,0,nil)
			if mg2:GetCount()>0 then
				mg1:Merge(mg2)
				-- 设置融合素材额外检查（限制卡组素材最多1张）
				aux.FCheckAdditional=s.fcheck
				-- 设置融合素材额外检查（限制卡组素材最多1张）
				aux.GCheckAdditional=s.gcheck
			end
		end
		-- 检查额外卡组是否有恐龙族融合怪兽可特殊召唤
		local res=Duel.IsExistingMatchingCard(s.fusionfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg1,nil,chkf)
		-- 清除融合素材额外检查
		aux.FCheckAdditional=nil
		-- 清除融合素材额外检查
		aux.GCheckAdditional=nil
		if not res then
			-- 获取连锁素材效果
			local ce=Duel.GetChainMaterial(tp)
			if ce~=nil then
				local fgroup=ce:GetTarget()
				local mg3=fgroup(ce,e,tp)
				local mf=ce:GetValue()
				-- 使用连锁素材检查恐龙族融合怪兽
				res=Duel.IsExistingMatchingCard(s.fusionfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg3,mf,chkf)
			end
		end
		return res
	end
	-- 设置特殊召唤操作信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- 融合召唤效果的处理操作
function s.fsop(e,tp,eg,ep,ev,re,r,rp)
	local chkf=tp
	-- 获取玩家可用的融合素材（手卡·场上怪兽）
	local mg1=Duel.GetFusionMaterial(tp):Filter(s.matfilter1,nil,e)
	local exmat=false
	if s.oppmonster(tp) then
		-- 获取卡组中可作为融合素材的GMX怪兽
		local mg2=Duel.GetMatchingGroup(s.matdeckfilter,tp,LOCATION_DECK,0,nil)
		if mg2:GetCount()>0 then
			mg1:Merge(mg2)
			exmat=true
		end
	end
	if exmat then
		-- 设置融合素材额外检查（限制卡组素材最多1张）
		aux.FCheckAdditional=s.fcheck
		-- 设置融合素材额外检查（限制卡组素材最多1张）
		aux.GCheckAdditional=s.gcheck
	end
	-- 获取可融合召唤的恐龙族融合怪兽
	local sg1=Duel.GetMatchingGroup(s.fusionfilter,tp,LOCATION_EXTRA,0,nil,e,tp,mg1,nil,chkf)
	-- 清除融合素材额外检查
	aux.FCheckAdditional=nil
	-- 清除融合素材额外检查
	aux.GCheckAdditional=nil
	local mg3=nil
	local sg2=nil
	-- 获取连锁素材效果
	local ce=Duel.GetChainMaterial(tp)
	if ce~=nil then
		local fgroup=ce:GetTarget()
		mg3=fgroup(ce,e,tp)
		local mf=ce:GetValue()
		-- 使用连锁素材获取可融合召唤的恐龙族融合怪兽
		sg2=Duel.GetMatchingGroup(s.fusionfilter,tp,LOCATION_EXTRA,0,nil,e,tp,mg3,mf,chkf)
	end
	if sg1:GetCount()>0 or (sg2~=nil and sg2:GetCount()>0) then
		local sg=sg1:Clone()
		if sg2 then sg:Merge(sg2) end
		-- 提示玩家选择要特殊召唤的融合怪兽
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		local tg=sg:Select(tp,1,1,nil)
		local tc=tg:GetFirst()
		mg1:RemoveCard(tc)
		-- 判断是否使用常规融合素材（而非连锁素材）
		if sg1:IsContains(tc) and (sg2==nil or not sg2:IsContains(tc) or not (ce and Duel.SelectYesNo(tp,ce:GetDescription()))) then
			if exmat then
				-- 设置融合素材额外检查（限制卡组素材最多1张）
				aux.FCheckAdditional=s.fcheck
				-- 设置融合素材额外检查（限制卡组素材最多1张）
				aux.GCheckAdditional=s.gcheck
			end
			-- 玩家选择融合素材
			local mat1=Duel.SelectFusionMaterial(tp,tc,mg1,nil,chkf)
			-- 清除融合素材额外检查
			aux.FCheckAdditional=nil
			-- 清除融合素材额外检查
			aux.GCheckAdditional=nil
			tc:SetMaterial(mat1)
			-- 融合素材送去墓地
			Duel.SendtoGrave(mat1,REASON_EFFECT+REASON_MATERIAL+REASON_FUSION)
			-- 中断当前效果以进行特殊召唤
			Duel.BreakEffect()
			-- 特殊召唤融合怪兽
			Duel.SpecialSummon(tc,SUMMON_TYPE_FUSION,tp,tp,false,false,POS_FACEUP)
		elseif ce and mg3 then
			-- 玩家选择连锁素材作为融合素材
			local mat2=Duel.SelectFusionMaterial(tp,tc,mg3,nil,chkf)
			local fop=ce:GetOperation()
			if fop then fop(ce,e,tp,tc,mat2) end
		end
		if tc then tc:CompleteProcedure() end
	end
end
-- 筛选可加入手卡的GMX卡
function s.thfilter(c)
	return c:IsSetCard(0x1dd) and c:IsAbleToHand()
end
-- 筛选GMX怪兽
function s.deckgmx(c)
	return c:IsSetCard(0x1dd)
end
-- 确认卡组顶的卡（翻卡时展示给玩家）
function s.confirm_decktop_s(tp,count)
	local max_decktop=5
	if count>max_decktop then
		-- 获取卡组顶的卡
		local g=Duel.GetDecktopGroup(tp,count)
		-- 对方确认卡组顶的卡
		Duel.ConfirmCards(1-tp,g)
	else
		-- 玩家确认卡组顶的卡
		Duel.ConfirmDecktop(tp,count)
	end
end
-- 翻卡效果的目标处理
function s.digtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组是否有可加入手卡的GMX卡
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置加入手卡操作信息
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
	-- 设置回到卡组操作信息
	Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,1,tp,LOCATION_DECK)
end
-- 翻卡效果的处理操作
function s.digop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取卡组卡数量
	local dcount=Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)
	if dcount==0 then return end
	-- 获取卡组中所有GMX怪兽
	local mg=Duel.GetMatchingGroup(s.deckgmx,tp,LOCATION_DECK,0,nil)
	if mg:GetCount()==0 then return end
	local seq=-1
	local qc=nil
	-- 遍历GMX怪兽寻找最上面的一张
	for sc in aux.Next(mg) do
		if sc:GetSequence()>seq then
			seq=sc:GetSequence()
			qc=sc
		end
	end
	if not qc then return end
	local nflip=dcount-seq
	s.confirm_decktop_s(tp,nflip)
	if e:GetHandler():IsSetCard(0x1dd) then
		-- 触发自定义事件（处理翻卡后续）
		Duel.RaiseEvent(e:GetHandler(),EVENT_CUSTOM+1595137,e,0,tp,tp,0)
	end
	-- 获取要翻开的卡
	local g=Duel.GetDecktopGroup(tp,nflip)
	if g:GetCount()==0 then return end
	if qc:IsAbleToHand() then
		-- GMX卡加入手卡
		Duel.SendtoHand(qc,nil,REASON_EFFECT)
		-- 对方确认加入手卡的卡
		Duel.ConfirmCards(1-tp,Group.FromCards(qc))
		-- 洗切玩家手卡
		Duel.ShuffleHand(tp)
	else
		-- GMX卡不能加入手卡时送去墓地
		Duel.SendtoGrave(qc,REASON_RULE)
	end
	-- 洗切卡组
	Duel.ShuffleDeck(tp)
end
