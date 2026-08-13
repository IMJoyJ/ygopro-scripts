--大輪の魔導書
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：自己的卡组·墓地·除外状态的4只「灵使」怪兽加入手卡（相同属性最多1只）。那之后，选自己2张手卡回到卡组。
-- ②：把墓地的这张卡除外才能发动。自己的手卡·场上的「灵使」、「凭依装着」怪兽作为融合素材，把1只融合怪兽融合召唤。在那次融合召唤成功时对方不能把魔法·陷阱·怪兽的效果发动。
local s,id,o=GetID()
-- 创建并注册该卡的两个效果：①为发动时检索灵使并回卡组的效果，②为墓地除外自身进行融合召唤并封锁对方效果的起动效果。
function s.initial_effect(c)
	-- ①：自己的卡组·墓地·除外状态的4只「灵使」怪兽加入手卡（相同属性最多1只）。那之后，选自己2张手卡回到卡组。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"发动"
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_TODECK)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	-- ②：把墓地的这张卡除外才能发动。自己的手卡·场上的「灵使」、「凭依装着」怪兽作为融合素材，把1只融合怪兽融合召唤。在那次融合召唤成功时对方不能把魔法·陷阱·怪兽的效果发动。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"融合召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,id+o)
	-- 设置②效果的发动COST：把墓地中的这张卡除外（aux.bfgcost判断并执行除外）。
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(s.fustg)
	e2:SetOperation(s.fusop)
	c:RegisterEffect(e2)
end
-- 定义①效果检索对象的过滤条件：持有「灵使」字段的怪兽，且能够加入手卡（可表侧表示/可确认状态）。
function s.thfilter(c)
	return c:IsSetCard(0xbf) and c:IsType(TYPE_MONSTER) and c:IsFaceupEx() and c:IsAbleToHand()
end
-- ①效果的目标与发动条件判定：收集卡组·墓地·除外状态的「灵使」怪兽，若属性种类≥4则可发动；同时设定加入手卡4张、手卡返回卡组2张的操作信息。
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取当前玩家卡组·墓地·除外状态中所有满足thfilter的「灵使」怪兽。
	local g=Duel.GetMatchingGroup(s.thfilter,tp,LOCATION_DECK+LOCATION_GRAVE+LOCATION_REMOVED,0,nil)
	if chk==0 then return g:GetClassCount(Card.GetAttribute)>=4 end
	-- 设定本效果可能将4张卡加入手卡，检索区域为卡组·墓地·除外状态。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,4,tp,LOCATION_DECK+LOCATION_GRAVE+LOCATION_REMOVED)
	-- 设定本效果可能将2张手卡返回卡组。
	Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,2,tp,LOCATION_HAND)
end
-- ①效果处理：再次获取可用的「灵使」怪兽，若属性种类足够，让玩家选择4只不同属性的「灵使」加入手卡，展示给对方，然后选2张手卡返回卡组。
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 处理时重新获取候选组，并通过aux.NecroValleyFilter排除受王家长眠之谷效果影响的卡，避免从墓地·除外区加入手卡的卡被无效。
	local g=Duel.GetMatchingGroup(aux.NecroValleyFilter(s.thfilter),tp,LOCATION_DECK+LOCATION_GRAVE+LOCATION_REMOVED,0,nil)
	if g:GetClassCount(Card.GetAttribute)<4 then return end
	-- 显示选择提示，提示玩家选择要加入手卡的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从候选组中选择4张卡，且要求这4张卡属性互不相同（aux.dabcheck）。
	local sg=g:SelectSubGroup(tp,aux.dabcheck,false,4,4)
	-- 将选中的卡加入持有者手卡；若实际加入数量>0则继续后续处理。
	if Duel.SendtoHand(sg,nil,REASON_EFFECT)>0 then
		-- 将加入手卡的卡展示给对方玩家确认。
		Duel.ConfirmCards(1-tp,sg)
		-- 若选中的卡中有卡已加入手卡，且自己手卡数量>1，则执行选2张手卡返回卡组的处理。
		if sg:IsExists(Card.IsLocation,1,nil,LOCATION_HAND) and Duel.GetFieldGroupCount(tp,LOCATION_HAND,0)>1 then
			-- 显示选择提示，提示玩家选择要返回卡组的手卡。
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
			-- 让玩家从手卡中选择2张可以返回卡组的卡。
			local dg=Duel.SelectMatchingCard(tp,Card.IsAbleToDeck,tp,LOCATION_HAND,0,2,2,nil)
			-- 中断当前效果，使后续手卡返回卡组的处理成为独立处理，避免错过时点。
			Duel.BreakEffect()
			-- 洗切手卡，确保随机性并更新手卡状态。
			Duel.ShuffleHand(tp)
			-- 将选中的2张手卡返回持有者卡组并洗切。
			Duel.SendtoDeck(dg,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
		end
	end
end
-- 定义②效果可用的融合素材条件：必须是怪兽、可作为融合素材、不受该效果免疫、且属于「灵使」或「凭依装着」字段。
function s.filter0(c,e)
	return c:IsType(TYPE_MONSTER) and c:IsCanBeFusionMaterial() and not c:IsImmuneToEffect(e) and c:IsFusionSetCard(0xbf,0x10c0)
end
-- 定义②效果可选融合怪兽的条件：是融合怪兽、满足额外素材条件f、能以融合召唤方式特殊召唤、且能用给定素材m进行融合。
function s.filter2(c,e,tp,m,f,chkf)
	return c:IsType(TYPE_FUSION) and (not f or f(c))
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_FUSION,tp,false,false) and c:CheckFusionMaterial(m,nil,chkf)
end
-- ②效果的目标判定：检查是否存在可用常规素材或连锁素材融合召唤的融合怪兽；若可行，则设置特殊召唤的操作信息。
function s.fustg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local chkf=tp
		-- 获取当前玩家的可用融合素材并筛选出满足filter0的「灵使」/「凭依装着」怪兽。
		local mg1=Duel.GetFusionMaterial(tp):Filter(s.filter0,nil,e)
		-- 检查额外卡组中是否存在至少1只融合怪兽，能用常规素材mg1进行融合召唤。
		local res=Duel.IsExistingMatchingCard(s.filter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg1,nil,chkf)
		if not res then
			-- 获取当前玩家适用的连锁素材效果（如某些代替素材效果），用于扩展可用的融合素材。
			local ce=Duel.GetChainMaterial(tp)
			if ce~=nil then
				local fgroup=ce:GetTarget()
				local mg2=fgroup(ce,e,tp)
				local mf=ce:GetValue()
				-- 若常规素材无法融合，则利用连锁素材效果提供的素材组mg2再次检查能否融合召唤。
				res=Duel.IsExistingMatchingCard(s.filter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg2,mf,chkf)
			end
		end
		return res
	end
	-- 设定本效果可能从额外卡组特殊召唤1只融合怪兽（融合召唤）。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- ②效果处理：选择要融合召唤的融合怪兽，根据素材来源选择常规或连锁素材流程，送素材并特殊召唤；同时注册后续限制对方发动效果的监视效果。
function s.fusop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local chkf=tp
	-- 再次获取并筛选常规融合素材（手卡·场上及额外融合素材效果提供的）。
	local mg1=Duel.GetFusionMaterial(tp):Filter(s.filter0,nil,e)
	-- 获取所有能用常规素材mg1融合召唤的融合怪兽，作为候选组sg1。
	local sg1=Duel.GetMatchingGroup(s.filter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg1,nil,chkf)
	local mg2=nil
	local sg2=nil
	-- 获取当前玩家适用的连锁素材效果（若有），以便支持替代素材融合。
	local ce=Duel.GetChainMaterial(tp)
	if ce~=nil then
		local fgroup=ce:GetTarget()
		mg2=fgroup(ce,e,tp)
		local mf=ce:GetValue()
		-- 使用连锁素材效果提供的信息获取额外素材组mg2，并筛选出能用mg2融合召唤的融合怪兽作为候选组sg2。
		sg2=Duel.GetMatchingGroup(s.filter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg2,mf,chkf)
	end
	if sg1:GetCount()>0 or (sg2~=nil and sg2:GetCount()>0) then
		local sg=sg1:Clone()
		if sg2 then sg:Merge(sg2) end
		-- 显示选择提示，提示玩家选择要特殊召唤的融合怪兽。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		local tg=sg:Select(tp,1,1,nil)
		local tc=tg:GetFirst()
		-- 在那次融合召唤成功时对方不能把魔法·陷阱·怪兽的效果发动。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_SPSUMMON_SUCCESS)
		e1:SetLabelObject(tc)
		e1:SetCondition(s.sumcon)
		e1:SetOperation(s.sumop)
		-- 注册e1（特殊召唤成功监视效果）到场上，持续监听后续的融合召唤成功事件。
		Duel.RegisterEffect(e1,tp)
		-- 在那次融合召唤成功时对方不能把魔法·陷阱·怪兽的效果发动。
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e2:SetCode(EVENT_CHAIN_END)
		e2:SetLabelObject(e1)
		e2:SetOperation(s.cedop)
		-- 注册e2（连锁结束时的确认效果）到场上，用于在连锁结束时检查并补设限制。
		Duel.RegisterEffect(e2,tp)
		-- 判断融合流程：若选中的怪兽属于常规素材候选，且不使用连锁素材（或玩家选择不用），则执行常规融合；否则使用连锁素材流程。
		if sg1:IsContains(tc) and (sg2==nil or not sg2:IsContains(tc) or ce and not Duel.SelectYesNo(tp,ce:GetDescription())) then
			-- 让玩家从常规素材组mg1中选择一组足以融合召唤tc的素材。
			local mat1=Duel.SelectFusionMaterial(tp,tc,mg1,nil,chkf)
			tc:SetMaterial(mat1)
			-- 将选择的融合素材送入墓地，原因为效果·素材·融合。
			Duel.SendtoGrave(mat1,REASON_EFFECT+REASON_MATERIAL+REASON_FUSION)
			-- 中断当前效果，使融合召唤的特殊召唤独立处理，避免错过时点。
			Duel.BreakEffect()
			-- 以融合召唤方式将tc特殊召唤到tp的场上，表侧表示。
			Duel.SpecialSummon(tc,SUMMON_TYPE_FUSION,tp,tp,false,false,POS_FACEUP)
		elseif ce then
			-- 使用连锁素材流程时，从连锁素材组mg2中选择融合素材。
			local mat2=Duel.SelectFusionMaterial(tp,tc,mg2,nil,chkf)
			local fop=ce:GetOperation()
			fop(ce,e,tp,tc,mat2)
		end
		tc:CompleteProcedure()
	end
end
-- e1（特殊召唤成功监视）的触发条件：本次特殊召唤成功的怪兽中包含所选定的融合怪兽tc。
function s.sumcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsContains(e:GetLabelObject())
end
-- e1的操作：融合召唤成功时，若当前不在连锁中则直接设置连锁限制；若当前为连锁1则记录标志并监听后续效果发动，以保持“仅该时点”的封锁。
function s.sumop(e,tp,eg,ep,ev,re,r,rp)
	e:SetLabel(1)
	-- 判断当前是否有连锁正在处理：Duel.GetCurrentChain()==0表示当前没有连锁，可立即设置限制。
	if Duel.GetCurrentChain()==0 then
		-- 设置直到连锁结束的连锁限制：仅允许本卡发动者tp发动效果（对方不能发动）。
		Duel.SetChainLimitTillChainEnd(s.chainlm)
	-- 若当前连锁为1（本效果是连锁1），则需要等待后续处理，在融合召唤成功时通过标志和监听效果设置限制。
	elseif Duel.GetCurrentChain()==1 then
		e:GetHandler():RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD,0,1)
		-- 在那次融合召唤成功时对方不能把魔法·陷阱·怪兽的效果发动。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_CHAINING)
		e1:SetOperation(s.resetop)
		-- 注册监听后续连锁发动的效果e1，用于在对方尝试发动效果时重置标志，确保限制正确。
		Duel.RegisterEffect(e1,tp)
		local e2=e1:Clone()
		e2:SetCode(EVENT_BREAK_EFFECT)
		e2:SetReset(RESET_CHAIN)
		-- 注册e1的克隆效果，监听效果中断事件，用于在不入连锁的效果中断时也重置标志。
		Duel.RegisterEffect(e2,tp)
	end
end
-- 当后续效果发动或效果中断时，清除限制标志并关闭监听效果，使封锁只在融合召唤成功的那个时点生效。
function s.resetop(e,tp,eg,ep,ev,re,r,rp)
	e:GetHandler():ResetFlagEffect(id)
	e:Reset()
end
-- 连锁结束时执行：若确实发生过本次融合召唤成功且标志仍存在，则补设连锁限制；随后清理标志与效果。
function s.cedop(e,tp,eg,ep,ev,re,r,rp)
	-- 判断是否应补设限制：存在特殊召唤成功事件、sumop已标记为1、且限制标志未被清除。
	if Duel.CheckEvent(EVENT_SPSUMMON_SUCCESS) and e:GetLabelObject():GetLabel()==1 and e:GetHandler():GetFlagEffect(id)~=0 then
		-- 补设连锁限制：直到连锁结束前，仅允许本卡发动者tp进行连锁，对方不能发动魔法·陷阱·怪兽效果。
		Duel.SetChainLimitTillChainEnd(s.chainlm)
	end
	e:GetHandler():ResetFlagEffect(id)
	e:Reset()
end
-- 定义连锁限制条件s.chainlm：只允许tp方连锁（tp==rp），即对方不能发动效果。
function s.chainlm(e,rp,tp)
	return tp==rp
end
