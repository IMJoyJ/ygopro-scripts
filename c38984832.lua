--GMX 55th Experiment Report
-- 效果：
-- 自己手卡·场上的怪兽作为融合素材，把1只恐龙族融合怪兽从额外卡组融合召唤。对方场上有怪兽存在的场合，自己卡组的「GMX」怪兽也能有最多1只作为融合素材。
-- 自己主要阶段：可以把墓地的这张卡除外；直到「GMX」卡出现为止从自己卡组上面翻卡，那张「GMX」卡加入手卡，剩下的卡回到卡组。 
-- 「GMX第55次试验报告」的效果1回合只能有1次使用其中任意1个。
local s,id,o=GetID()
-- 注册卡片效果：①自己手卡·场上或卡组最多1只「GMX」怪兽作为素材融合召唤恐龙族融合怪兽；②主要阶段墓地除外，直到「GMX」卡出现从卡组上面翻卡，那张「GMX」卡加入手卡，剩下的卡回到卡组且洗牌
function s.initial_effect(c)
	-- ①：自己手卡·场上的怪兽作为融合素材，把1只恐龙族融合怪兽从额外卡组融合召唤。对方场上有怪兽存在的场合，自己卡组的「GMX」怪兽也能有最多1只作为融合素材。
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
	-- 设置发动代价：将墓地的这张卡自身除外
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(s.digtg)
	e2:SetOperation(s.digop)
	c:RegisterEffect(e2)
end
-- 过滤条件：卡组中属于「GMX」系列的怪兽，且可作为融合素材并送去墓地
function s.matdeckfilter(c)
	return c:IsSetCard(0x1dd) and c:IsType(TYPE_MONSTER) and c:IsCanBeFusionMaterial() and c:IsAbleToGrave()
end
-- 过滤条件：不受效果影响的融合素材怪兽
function s.matfilter1(c,e)
	return not c:IsImmuneToEffect(e)
end
-- 过滤条件：对方场上是否存在怪兽
function s.oppmonster(tp)
	-- 检查对方场上是否存在至少1只怪兽
	return Duel.IsExistingMatchingCard(aux.TRUE,tp,0,LOCATION_MZONE,1,nil)
end
-- 过滤条件：恐龙族融合怪兽，能被特殊召唤且能使用指定融合素材进行融合召唤
function s.fusionfilter(c,e,tp,m,f,chkf)
	return c:IsType(TYPE_FUSION) and c:IsRace(RACE_DINOSAUR) and (not f or f(c))
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_FUSION,tp,false,false) and c:CheckFusionMaterial(m,nil,chkf)
end
-- 融合素材数量校验条件：限制从卡组选择的素材数量最多为1张
function s.fcheck(tp,sg,fc)
	return sg:FilterCount(Card.IsLocation,nil,LOCATION_DECK)<=1
end
-- 融合素材组校验条件：限制从卡组选择的素材数量最多为1张
function s.gcheck(sg)
	return sg:FilterCount(Card.IsLocation,nil,LOCATION_DECK)<=1
end
-- 效果1的发动准备与合法性检查：检查自己手卡、场上或卡组（满足条件时）的素材是否满足特殊召唤额外卡组恐龙族融合怪兽的条件，并声明特殊召唤的操作信息
function s.fstg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local chkf=tp
		-- 获取玩家可用的手卡和场上的融合素材怪兽组
		local mg1=Duel.GetFusionMaterial(tp):Filter(s.matfilter1,nil,e)
		if s.oppmonster(tp) then
			-- 获取卡组中可以作为融合素材的「GMX」怪兽组
			local mg2=Duel.GetMatchingGroup(s.matdeckfilter,tp,LOCATION_DECK,0,nil)
			if mg2:GetCount()>0 then
				mg1:Merge(mg2)
				-- 将从卡组选择素材的附加校验条件（最多1张）绑定 to 融合辅助系统
				aux.FCheckAdditional=s.fcheck
				-- 将从卡组选择素材的附加校验条件（最多1张）绑定 to 融合辅助组系统
				aux.GCheckAdditional=s.gcheck
			end
		end
		-- 检查额外卡组中是否存在符合融合召唤条件的恐龙族融合怪兽
		local res=Duel.IsExistingMatchingCard(s.fusionfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg1,nil,chkf)
		-- 清空融合辅助系统的额外校验条件
		aux.FCheckAdditional=nil
		-- 清空融合辅助组系统的额外校验条件
		aux.GCheckAdditional=nil
		if not res then
			-- 获取玩家受到的连锁素材效果（如「连锁物质」）
			local ce=Duel.GetChainMaterial(tp)
			if ce~=nil then
				local fgroup=ce:GetTarget()
				local mg3=fgroup(ce,e,tp)
				local mf=ce:GetValue()
				-- 在连锁素材效果影响下检查是否存在可融合召唤的怪兽
				res=Duel.IsExistingMatchingCard(s.fusionfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg3,mf,chkf)
			end
		end
		return res
	end
	-- 设置操作信息：从额外卡组特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- 效果1的实际处理：根据场上和对方怪兽情况获取融合素材范围，让玩家选择要融合召唤的怪兽并挑选对应素材，最后将其送入墓地并进行融合召唤
function s.fsop(e,tp,eg,ep,ev,re,r,rp)
	local chkf=tp
	-- 获取玩家可用的手卡和场上的融合素材怪兽组
	local mg1=Duel.GetFusionMaterial(tp):Filter(s.matfilter1,nil,e)
	local exmat=false
	if s.oppmonster(tp) then
		-- 获取卡组中可以作为融合素材的「GMX」怪兽组
		local mg2=Duel.GetMatchingGroup(s.matdeckfilter,tp,LOCATION_DECK,0,nil)
		if mg2:GetCount()>0 then
			mg1:Merge(mg2)
			exmat=true
		end
	end
	if exmat then
		-- 将从卡组选择素材的附加校验条件（最多1张）绑定 to 融合辅助系统
		aux.FCheckAdditional=s.fcheck
		-- 将从卡组选择素材的附加校验条件（最多1张）绑定 to 融合辅助组系统
		aux.GCheckAdditional=s.gcheck
	end
	-- 获取额外卡组中所有符合融合召唤条件的恐龙族融合怪兽
	local sg1=Duel.GetMatchingGroup(s.fusionfilter,tp,LOCATION_EXTRA,0,nil,e,tp,mg1,nil,chkf)
	-- 清空融合辅助系统的额外校验条件
	aux.FCheckAdditional=nil
	-- 清空融合辅助组系统的额外校验条件
	aux.GCheckAdditional=nil
	local mg3=nil
	local sg2=nil
	-- 获取玩家受到的连锁素材效果（如「连锁物质」）
	local ce=Duel.GetChainMaterial(tp)
	if ce~=nil then
		local fgroup=ce:GetTarget()
		mg3=fgroup(ce,e,tp)
		local mf=ce:GetValue()
		-- 获取在连锁素材效果影响下所有可以融合召唤的怪兽
		sg2=Duel.GetMatchingGroup(s.fusionfilter,tp,LOCATION_EXTRA,0,nil,e,tp,mg3,mf,chkf)
	end
	if sg1:GetCount()>0 or (sg2~=nil and sg2:GetCount()>0) then
		local sg=sg1:Clone()
		if sg2 then sg:Merge(sg2) end
		-- 向玩家提示选择要特殊召唤的卡片
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		local tg=sg:Select(tp,1,1,nil)
		local tc=tg:GetFirst()
		mg1:RemoveCard(tc)
		-- 判断是否选择以自身效果（而非连锁素材效果）进行正常的融合召唤
		if sg1:IsContains(tc) and (sg2==nil or not sg2:IsContains(tc) or not (ce and Duel.SelectYesNo(tp,ce:GetDescription()))) then
			if exmat then
				-- 将从卡组选择素材的附加校验条件（最多1张）绑定 to 融合辅助系统
				aux.FCheckAdditional=s.fcheck
				-- 将从卡组选择素材的附加校验条件（最多1张）绑定 to 融合辅助组系统
				aux.GCheckAdditional=s.gcheck
			end
			-- 玩家选择融合召唤所需的融合素材（包含手卡、场上和可选的卡组怪兽）
			local mat1=Duel.SelectFusionMaterial(tp,tc,mg1,nil,chkf)
			-- 清空融合辅助系统的额外校验条件
			aux.FCheckAdditional=nil
			-- 清空融合辅助组系统的额外校验条件
			aux.GCheckAdditional=nil
			tc:SetMaterial(mat1)
			-- 将选中的融合素材送去墓地
			Duel.SendtoGrave(mat1,REASON_EFFECT+REASON_MATERIAL+REASON_FUSION)
			-- 中断当前效果，使之后的融合召唤特殊召唤动作视为不同时处理
			Duel.BreakEffect()
			-- 将该融合怪兽以融合召唤的方式在自己场上表侧表示特殊召唤
			Duel.SpecialSummon(tc,SUMMON_TYPE_FUSION,tp,tp,false,false,POS_FACEUP)
		elseif ce and mg3 then
			-- 在连锁素材效果（如「连锁物质」）影响下选择融合素材
			local mat2=Duel.SelectFusionMaterial(tp,tc,mg3,nil,chkf)
			local fop=ce:GetOperation()
			if fop then fop(ce,e,tp,tc,mat2) end
		end
		if tc then tc:CompleteProcedure() end
	end
end
-- 过滤条件：属于「GMX」系列的卡，且能加入手卡
function s.thfilter(c)
	return c:IsSetCard(0x1dd) and c:IsAbleToHand()
end
-- 过滤条件：属于「GMX」系列的卡
function s.deckgmx(c)
	return c:IsSetCard(0x1dd)
end
-- 辅助函数：向双方玩家展示卡组最上方特定数量的卡片
function s.confirm_decktop_s(tp,count)
	local max_decktop=5
	if count>max_decktop then
		-- 获取卡组最上方的特定数量的卡片组
		local g=Duel.GetDecktopGroup(tp,count)
		-- 向对方玩家确认这些卡片
		Duel.ConfirmCards(1-tp,g)
	else
		-- 确认自己卡组最上方的特定数量的卡片
		Duel.ConfirmDecktop(tp,count)
	end
end
-- 效果2的发动准备与合法性检查：检查卡组中是否存在可以检索的「GMX」卡，并声明检索与回卡组的操作信息
function s.digtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在可检索的「GMX」卡
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息：从卡组将1张卡加入手卡
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
	-- 设置操作信息：将卡片送回卡组
	Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,1,tp,LOCATION_DECK)
end
-- 效果2的实际处理：定位卡组中最上方的那张「GMX」卡，翻开其上方的所有卡片，将其加入手卡（或若无法加入手卡则送墓），最后洗切卡组
function s.digop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取玩家卡组的卡片总数
	local dcount=Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)
	if dcount==0 then return end
	-- 获取卡组中所有属于「GMX」系列的卡片
	local mg=Duel.GetMatchingGroup(s.deckgmx,tp,LOCATION_DECK,0,nil)
	if mg:GetCount()==0 then return end
	local seq=-1
	local qc=nil
	-- 遍历所有卡组中的「GMX」卡，找出在卡组中位置最靠上（Sequence最大）的那一张
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
		-- 触发自定义事件，用于处理某些卡片被检索时的相关配合效果
		Duel.RaiseEvent(e:GetHandler(),EVENT_CUSTOM+1595137,e,0,tp,tp,0)
	end
	-- 获取被翻开的卡片组（从卡组顶部到那张「GMX」卡）
	local g=Duel.GetDecktopGroup(tp,nflip)
	if g:GetCount()==0 then return end
	if qc:IsAbleToHand() then
		-- 将那张「GMX」卡加入玩家手卡
		Duel.SendtoHand(qc,nil,REASON_EFFECT)
		-- 向对方玩家确认加入手卡的该「GMX」卡
		Duel.ConfirmCards(1-tp,Group.FromCards(qc))
		-- 洗切玩家的手卡
		Duel.ShuffleHand(tp)
	else
		-- 若由于规则限制该「GMX」卡无法加入手卡，则因规则原因送去墓地
		Duel.SendtoGrave(qc,REASON_RULE)
	end
	-- 洗切玩家的卡组
	Duel.ShuffleDeck(tp)
end
