--第５５次GMX試験報告
-- 效果：
-- 这个卡名的①②的效果1回合只能有1次使用其中任意1个。
-- ①：自己的手卡·场上的怪兽作为融合素材，把1只恐龙族融合怪兽融合召唤。对方场上有怪兽存在的场合，自己卡组的「基因组混合」怪兽也能有最多1只作为融合素材。
-- ②：自己主要阶段把墓地的这张卡除外才能发动。直到「基因组混合」卡出现为止从自己卡组上面翻卡，那张「基因组混合」卡加入手卡。剩余回到卡组。
local s,id,o=GetID()
-- 初始化卡片效果：注册①效果（发动型自由时点效果，分类为特殊召唤+融合召唤+卡组送墓，描述为融合召唤，1回合1次，目标函数s.fstg，处理函数s.fsop）和②效果（墓地发动的启动效果，分类为检索+加入手卡+回到卡组，以除外墓地的这张卡为代价，1回合1次，目标函数s.digtg，处理函数s.digop）
function s.initial_effect(c)
	-- ①：自己的手卡·场上的怪兽作为融合素材，把1只恐龙族融合怪兽融合召唤。对方场上有怪兽存在的场合，自己卡组的「基因组混合」怪兽也能有最多1只作为融合素材。
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
	-- ②：自己主要阶段把墓地的这张卡除外才能发动。直到「基因组混合」卡出现为止从自己卡组上面翻卡，那张「基因组混合」卡加入手卡。剩余回到卡组。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"翻卡"
	e2:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND+CATEGORY_TODECK)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,id)
	-- 将②效果的发动代价设定为把墓地的这张卡除外
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(s.digtg)
	e2:SetOperation(s.digop)
	c:RegisterEffect(e2)
end
-- 融合素材过滤器：从卡组作为融合素材的卡须为「基因组混合」怪兽、可以作为融合素材且可以送去墓地
function s.matdeckfilter(c)
	return c:IsSetCard(0x1dd) and c:IsType(TYPE_MONSTER) and c:IsCanBeFusionMaterial() and c:IsAbleToGrave()
end
-- 素材过滤器：不能成为融合素材的卡是对此效果免疫的卡
function s.matfilter1(c,e)
	return not c:IsImmuneToEffect(e)
end
-- 判断对方场上是否有怪兽存在的函数
function s.oppmonster(tp)
	-- 检查对方场上是否存在至少1只怪兽
	return Duel.IsExistingMatchingCard(aux.TRUE,tp,0,LOCATION_MZONE,1,nil)
end
-- 可融合召唤怪兽的过滤器：须为恐龙族融合怪兽、满足额外条件f、可以以融合召唤方式特殊召唤且用当前素材组能够凑齐融合素材
function s.fusionfilter(c,e,tp,m,f,chkf)
	return c:IsType(TYPE_FUSION) and c:IsRace(RACE_DINOSAUR) and (not f or f(c))
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_FUSION,tp,false,false) and c:CheckFusionMaterial(m,nil,chkf)
end
-- 附加融合素材检查：所选素材组中来自卡组的素材最多只能有1只
function s.fcheck(tp,sg,fc)
	return sg:FilterCount(Card.IsLocation,nil,LOCATION_DECK)<=1
end
-- 附加素材组检查：素材组中位于卡组的卡的数量不超过1张
function s.gcheck(sg)
	return sg:FilterCount(Card.IsLocation,nil,LOCATION_DECK)<=1
end
-- ①效果的目标函数：发动条件检测时，先取得自己可用的融合素材（手卡·场上，且不对效果免疫），若对方场上有怪兽则把卡组中符合条件的「基因组混合」怪兽并入素材组并设置卡组素材最多1只的附加检查，再检查额外卡组是否存在可以用这些素材融合召唤的恐龙族融合怪兽，若不存在则再尝试用连锁素材效果的素材检查，最后设置将从额外卡组特殊召唤1只怪兽的操作信息
function s.fstg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local chkf=tp
		-- 取得自己可用的融合素材（手卡·场上不受此效果影响的怪兽）作为素材组mg1
		local mg1=Duel.GetFusionMaterial(tp):Filter(s.matfilter1,nil,e)
		if s.oppmonster(tp) then
			-- 从卡组检索可以作为融合素材且可以送去墓地的「基因组混合」怪兽，作为素材组mg2
			local mg2=Duel.GetMatchingGroup(s.matdeckfilter,tp,LOCATION_DECK,0,nil)
			if mg2:GetCount()>0 then
				mg1:Merge(mg2)
				-- 设置附加融合素材检查函数，限制卡组素材最多1只
				aux.FCheckAdditional=s.fcheck
				-- 设置附加素材组检查函数，限制素材组中卡组素材最多1只
				aux.GCheckAdditional=s.gcheck
			end
		end
		-- 检查额外卡组是否存在1只可以用mg1中的素材融合召唤的恐龙族融合怪兽
		local res=Duel.IsExistingMatchingCard(s.fusionfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg1,nil,chkf)
		-- 清除附加融合素材检查函数
		aux.FCheckAdditional=nil
		-- 清除附加素材组检查函数
		aux.GCheckAdditional=nil
		if not res then
			-- 取得自己受到的连锁素材效果
			local ce=Duel.GetChainMaterial(tp)
			if ce~=nil then
				local fgroup=ce:GetTarget()
				local mg3=fgroup(ce,e,tp)
				local mf=ce:GetValue()
				-- 改用连锁素材效果提供的素材组mg3再次检查额外卡组是否存在可融合召唤的恐龙族融合怪兽
				res=Duel.IsExistingMatchingCard(s.fusionfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg3,mf,chkf)
			end
		end
		return res
	end
	-- 设置操作信息：将从额外卡组特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- ①效果的处理函数：重新取得素材组，若对方场上有怪兽则并入卡组的「基因组混合」怪兽素材并启用卡组素材最多1只的附加检查，取得额外卡组中可用这些素材融合召唤的恐龙族融合怪兽组sg1；若自己受到连锁素材效果影响则另外取得对应素材组和可融合召唤怪兽组sg2；存在可融合召唤的怪兽时让玩家选择1只，若通过常规素材进行则让玩家选择融合素材、将素材送去墓地、中断效果处理后将该怪兽以融合召唤方式特殊召唤，否则使用连锁素材效果的操作完成融合召唤，最后完成该怪兽的召唤手续
function s.fsop(e,tp,eg,ep,ev,re,r,rp)
	local chkf=tp
	-- 取得自己可用的融合素材（手卡·场上不受此效果影响的怪兽）作为素材组mg1
	local mg1=Duel.GetFusionMaterial(tp):Filter(s.matfilter1,nil,e)
	local exmat=false
	if s.oppmonster(tp) then
		-- 从卡组检索可以作为融合素材且可以送去墓地的「基因组混合」怪兽，作为素材组mg2
		local mg2=Duel.GetMatchingGroup(s.matdeckfilter,tp,LOCATION_DECK,0,nil)
		if mg2:GetCount()>0 then
			mg1:Merge(mg2)
			exmat=true
		end
	end
	if exmat then
		-- 设置附加融合素材检查函数，限制卡组素材最多1只
		aux.FCheckAdditional=s.fcheck
		-- 设置附加素材组检查函数，限制素材组中卡组素材最多1只
		aux.GCheckAdditional=s.gcheck
	end
	-- 取得额外卡组中所有可以用mg1中的素材融合召唤的恐龙族融合怪兽，作为候选组sg1
	local sg1=Duel.GetMatchingGroup(s.fusionfilter,tp,LOCATION_EXTRA,0,nil,e,tp,mg1,nil,chkf)
	-- 清除附加融合素材检查函数
	aux.FCheckAdditional=nil
	-- 清除附加素材组检查函数
	aux.GCheckAdditional=nil
	local mg3=nil
	local sg2=nil
	-- 取得自己受到的连锁素材效果
	local ce=Duel.GetChainMaterial(tp)
	if ce~=nil then
		local fgroup=ce:GetTarget()
		mg3=fgroup(ce,e,tp)
		local mf=ce:GetValue()
		-- 用连锁素材效果提供的素材组mg3取得额外卡组中可融合召唤的恐龙族融合怪兽，作为候选组sg2
		sg2=Duel.GetMatchingGroup(s.fusionfilter,tp,LOCATION_EXTRA,0,nil,e,tp,mg3,mf,chkf)
	end
	if sg1:GetCount()>0 or (sg2~=nil and sg2:GetCount()>0) then
		local sg=sg1:Clone()
		if sg2 then sg:Merge(sg2) end
		-- 提示玩家选择要特殊召唤的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		local tg=sg:Select(tp,1,1,nil)
		local tc=tg:GetFirst()
		mg1:RemoveCard(tc)
		-- 判断使用哪种素材路线：若所选怪兽在sg1中，且（不存在sg2候选，或所选怪兽不在sg2中，或玩家不选择使用连锁素材效果），则走常规融合素材路线
		if sg1:IsContains(tc) and (sg2==nil or not sg2:IsContains(tc) or not (ce and Duel.SelectYesNo(tp,ce:GetDescription()))) then
			if exmat then
				-- 设置附加融合素材检查函数，限制卡组素材最多1只
				aux.FCheckAdditional=s.fcheck
				-- 设置附加素材组检查函数，限制素材组中卡组素材最多1只
				aux.GCheckAdditional=s.gcheck
			end
			-- 让玩家从mg1中选择用于融合召唤所选怪兽的一组融合素材mat1
			local mat1=Duel.SelectFusionMaterial(tp,tc,mg1,nil,chkf)
			-- 清除附加融合素材检查函数
			aux.FCheckAdditional=nil
			-- 清除附加素材组检查函数
			aux.GCheckAdditional=nil
			tc:SetMaterial(mat1)
			-- 将所选融合素材作为融合素材因效果送去墓地
			Duel.SendtoGrave(mat1,REASON_EFFECT+REASON_MATERIAL+REASON_FUSION)
			-- 中断当前效果处理，使之后的特殊召唤与送墓不作为同时处理
			Duel.BreakEffect()
			-- 将所选恐龙族融合怪兽以融合召唤方式在自己场上正面表示特殊召唤
			Duel.SpecialSummon(tc,SUMMON_TYPE_FUSION,tp,tp,false,false,POS_FACEUP)
		elseif ce and mg3 then
			-- 让玩家从连锁素材效果提供的素材组mg3中选择用于融合召唤的一组素材mat2
			local mat2=Duel.SelectFusionMaterial(tp,tc,mg3,nil,chkf)
			local fop=ce:GetOperation()
			if fop then fop(ce,e,tp,tc,mat2) end
		end
		if tc then tc:CompleteProcedure() end
	end
end
-- 加入手卡的过滤器：须为「基因组混合」卡且可以加入手卡
function s.thfilter(c)
	return c:IsSetCard(0x1dd) and c:IsAbleToHand()
end
-- 卡组中「基因组混合」卡的过滤器：属于「基因组混合」系列即可
function s.deckgmx(c)
	return c:IsSetCard(0x1dd)
end
-- 确认卡组上方卡片的辅助函数：若要翻开的数量超过5张，则取得卡组上方该数量的卡给对方确认；否则直接以确认卡组上方的方式确认
function s.confirm_decktop_s(tp,count)
	local max_decktop=5
	if count>max_decktop then
		-- 取得卡组最上方count张卡
		local g=Duel.GetDecktopGroup(tp,count)
		-- 给对方玩家确认这些卡
		Duel.ConfirmCards(1-tp,g)
	else
		-- 确认自己卡组最上方count张卡
		Duel.ConfirmDecktop(tp,count)
	end
end
-- ②效果的目标函数：发动条件为卡组中存在可以加入手卡的「基因组混合」卡；设置操作信息为从卡组把1张卡加入手卡以及从卡组把卡回到卡组
function s.digtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动条件检测：卡组中须存在至少1张可以加入手卡的「基因组混合」卡
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息：预计从卡组把1张卡加入手卡
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
	-- 设置操作信息：预计从卡组把卡回到卡组
	Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,1,tp,LOCATION_DECK)
end
-- ②效果的处理函数：取得自己卡组的数量，卡组为空则不处理；检索卡组中所有「基因组混合」卡，没有则不处理；遍历找出卡组中位置最靠上的那张「基因组混合」卡qc，计算需要翻开的卡数nflip并确认卡组上方相应数量的卡；若这张卡本身是「基因组混合」卡则触发对应的自定义事件；取得翻开的卡组上方卡片组，若qc可以加入手卡则将其加入手卡、给对方确认并洗切手卡，否则将其因规则送去墓地；最后洗切卡组
function s.digop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得自己卡组中卡的数量
	local dcount=Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)
	if dcount==0 then return end
	-- 检索卡组中所有的「基因组混合」卡
	local mg=Duel.GetMatchingGroup(s.deckgmx,tp,LOCATION_DECK,0,nil)
	if mg:GetCount()==0 then return end
	local seq=-1
	local qc=nil
	-- 遍历卡组中的「基因组混合」卡，以找出位置最靠上（序号最小方向之后序号最大的迭代比较）的那张
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
		-- 触发自定义事件，用于其他卡检测此卡作为「基因组混合」卡被翻开或处理的时点
		Duel.RaiseEvent(e:GetHandler(),EVENT_CUSTOM+1595137,e,0,tp,tp,0)
	end
	-- 取得卡组最上方nflip张卡作为翻开的卡片组
	local g=Duel.GetDecktopGroup(tp,nflip)
	if g:GetCount()==0 then return end
	if qc:IsAbleToHand() then
		-- 将那张「基因组混合」卡加入自己的手卡
		Duel.SendtoHand(qc,nil,REASON_EFFECT)
		-- 给对方玩家确认加入手卡的那张卡
		Duel.ConfirmCards(1-tp,Group.FromCards(qc))
		-- 洗切自己的手卡
		Duel.ShuffleHand(tp)
	else
		-- 那张卡不能加入手卡的场合，将其因规则送去墓地
		Duel.SendtoGrave(qc,REASON_RULE)
	end
	-- 洗切自己的卡组，使剩余的翻开的卡回到卡组
	Duel.ShuffleDeck(tp)
end
