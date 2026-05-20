--冥骸融合－メメント・フュージョン
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：双方的主要阶段才能发动。包含「莫忘」怪兽的自己的手卡·场上的怪兽作为融合素材，把1只融合怪兽融合召唤。这个回合是已有自己怪兽被效果破坏的场合，也能让自己墓地的「莫忘」怪兽回到卡组作为融合素材。
-- ②：自己主要阶段把墓地的这张卡除外才能发动。自己场上1只怪兽破坏，从卡组把1张「莫忘」魔法·陷阱卡加入手卡。
local s,id,o=GetID()
-- 注册卡片效果与全局监听器（用于记录本回合是否有怪兽被效果破坏）。
function s.initial_effect(c)
	-- ①：双方的主要阶段才能发动。包含「莫忘」怪兽的自己的手卡·场上的怪兽作为融合素材，把1只融合怪兽融合召唤。这个回合是已有自己怪兽被效果破坏的场合，也能让自己墓地的「莫忘」怪兽回到卡组作为融合素材。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"融合召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON+CATEGORY_TODECK)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	-- ②：自己主要阶段把墓地的这张卡除外才能发动。自己场上1只怪兽破坏，从卡组把1张「莫忘」魔法·陷阱卡加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"破坏并检索「莫忘」魔法·陷阱卡"
	e2:SetCategory(CATEGORY_DESTROY+CATEGORY_SEARCH+CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,id+o)
	-- 设置发动Cost为把墓地的这张卡除外。
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)
	if not s.global_check then
		s.global_check=true
		-- 融合召唤效果的完整逻辑实现，包括检测本回合是否有怪兽被效果破坏、过滤手卡/场上/墓地的融合素材、执行融合召唤并处理素材移动（墓地素材回卡组，手卡/场上素材送去墓地）。
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_DESTROYED)
		ge1:SetCondition(s.regcon)
		ge1:SetOperation(s.regop)
		-- 注册全局效果监听器，用于记录怪兽被效果破坏的事件。
		Duel.RegisterEffect(ge1,0)
	end
end
s.fusion_effect=true
-- 过滤因效果而被破坏的怪兽（必须是怪兽卡，或者原本在怪兽区域且不在魔法与陷阱区域）。
function s.spcfilter(c)
	return c:IsReason(REASON_EFFECT) and (c:IsType(TYPE_MONSTER) or c:IsPreviousLocation(LOCATION_MZONE))
		and not c:IsPreviousLocation(LOCATION_SZONE)
end
-- 检查被破坏的卡中是否存在满足上述过滤条件的怪兽。
function s.regcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.spcfilter,1,nil)
end
-- 根据被破坏怪兽的原本控制者，为对应玩家注册本回合有怪兽被效果破坏的全局标记。
function s.regop(e,tp,eg,ep,ev,re,r,rp)
	local g=eg:Filter(s.spcfilter,nil)
	if g:IsExists(Card.IsPreviousControler,1,nil,0) then
		-- 为先攻玩家（玩家0）注册本回合有怪兽被效果破坏的标记，持续到回合结束。
		Duel.RegisterFlagEffect(0,id,RESET_PHASE+PHASE_END,EFFECT_FLAG_OATH,1)
	end
	if g:IsExists(Card.IsPreviousControler,1,nil,1) then
		-- 为后攻玩家（玩家1）注册本回合有怪兽被效果破坏的标记，持续到回合结束。
		Duel.RegisterFlagEffect(1,id,RESET_PHASE+PHASE_END,EFFECT_FLAG_OATH,1)
	end
end
-- 限制只能在双方的主要阶段发动。
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前的阶段。
	local ph=Duel.GetCurrentPhase()
	return (ph==PHASE_MAIN1 or ph==PHASE_MAIN2)
end
-- 过滤墓地中可以作为融合素材且能回到卡组的「莫忘」怪兽。
function s.filter1(c,e)
	return c:IsSetCard(0x1a1) and c:IsType(TYPE_MONSTER) and c:IsAbleToDeck() and c:IsCanBeFusionMaterial() and not c:IsImmuneToEffect(e)
end
-- 过滤不受此卡效果影响的卡片（用于常规融合素材过滤）。
function s.filter2(c,e)
	return not c:IsImmuneToEffect(e)
end
-- 过滤额外卡组中可以使用指定素材进行融合召唤的融合怪兽。
function s.spfilter(c,e,tp,m,f,chkf)
	return (not f or f(c))
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_FUSION,tp,false,false) and c:CheckFusionMaterial(m,nil,chkf)
end
-- 过滤属于自己且位于墓地的卡片（用于检测是否使用了墓地素材）。
function s.exfilter(c,tp)
	return c:IsControler(tp) and c:IsLocation(LOCATION_GRAVE)
end
-- 融合素材的额外检查函数：必须包含至少1只「莫忘」怪兽；若本回合没有怪兽被效果破坏，则不能使用墓地的卡作为素材。
function s.fcheck(tp,sg,fc)
	-- 检查本回合自己是否有怪兽被效果破坏。
	if Duel.GetFlagEffect(tp,id)~=0 then
		return sg:IsExists(Card.IsFusionSetCard,1,nil,0x1a1)
	else
		return sg:IsExists(Card.IsFusionSetCard,1,nil,0x1a1) and not sg:IsExists(s.exfilter,1,nil,tp)
	end
end
-- 融合召唤效果的发动准备，检查是否存在可融合召唤的合法组合，并设置操作信息。
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local chkf=tp
		-- 获取玩家手卡·场上可用的常规融合素材。
		local mg1=Duel.GetFusionMaterial(tp):Filter(s.filter2,nil,e)
		-- 获取自己墓地中满足条件的「莫忘」怪兽作为潜在融合素材。
		local mg2=Duel.GetMatchingGroup(s.filter1,tp,LOCATION_GRAVE,0,nil,e)
		-- 检查本回合自己是否有怪兽被效果破坏。
		if Duel.GetFlagEffect(tp,id)~=0 then
			mg1:Merge(mg2)
		end
		-- 设定融合素材的额外检查逻辑（必须包含「莫忘」怪兽，且在未达成条件时不能使用墓地素材）。
		aux.FCheckAdditional=s.fcheck
		-- 检查额外卡组是否存在可以使用当前可用素材进行融合召唤的怪兽。
		local res=Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg1,nil,chkf)
		if not res then
			-- 获取玩家受到的连锁素材效果（如「连锁素材」）。
			local ce=Duel.GetChainMaterial(tp)
			if ce~=nil then
				local fgroup=ce:GetTarget()
				local mg3=fgroup(ce,e,tp)
				local mf=ce:GetValue()
				-- 检查在连锁素材效果下是否存在可融合召唤的怪兽。
				res=Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg3,mf,chkf)
			end
		end
		-- 清除融合素材的额外检查函数，避免影响后续其他卡的效果。
		aux.FCheckAdditional=nil
		return res
	end
	-- 设置特殊召唤的操作信息（从额外卡组特殊召唤1只怪兽）。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
	-- 设置回到卡组的操作信息（可能需要将墓地的素材回到卡组）。
	Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,0,tp,LOCATION_GRAVE)
end
-- 融合召唤效果的处理逻辑：选择融合怪兽，决定并扣除融合素材（墓地素材回卡组，其余送去墓地），然后进行融合召唤。
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local chkf=tp
	-- 获取玩家手卡·场上可用的常规融合素材。
	local mg1=Duel.GetFusionMaterial(tp):Filter(s.filter2,nil,e)
	-- 获取自己墓地中满足条件且不受王家之谷影响的「莫忘」怪兽作为潜在融合素材。
	local mg2=Duel.GetMatchingGroup(aux.NecroValleyFilter(s.filter1),tp,LOCATION_GRAVE,0,nil,e)
	-- 检查本回合自己是否有怪兽被效果破坏。
	if Duel.GetFlagEffect(tp,id)~=0 then
		mg1:Merge(mg2)
	end
	-- 设定融合素材的额外检查逻辑（必须包含「莫忘」怪兽，且在未达成条件时不能使用墓地素材）。
	aux.FCheckAdditional=s.fcheck
	-- 过滤出可以使用当前可用素材进行融合召唤的额外卡组怪兽。
	local sg1=Duel.GetMatchingGroup(s.spfilter,tp,LOCATION_EXTRA,0,nil,e,tp,mg1,nil,chkf)
	local mg3=nil
	local sg2=nil
	-- 获取玩家受到的连锁素材效果。
	local ce=Duel.GetChainMaterial(tp)
	if ce~=nil then
		local fgroup=ce:GetTarget()
		mg3=fgroup(ce,e,tp)
		local mf=ce:GetValue()
		-- 过滤出在连锁素材效果下可以融合召唤的额外卡组怪兽。
		sg2=Duel.GetMatchingGroup(s.spfilter,tp,LOCATION_EXTRA,0,nil,e,tp,mg3,mf,chkf)
	end
	if sg1:GetCount()>0 or (sg2~=nil and sg2:GetCount()>0) then
		local sg=sg1:Clone()
		if sg2 then sg:Merge(sg2) end
		-- 提示玩家选择要特殊召唤的融合怪兽。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		local tg=sg:Select(tp,1,1,nil)
		local tc=tg:GetFirst()
		-- 判断是否使用常规融合方式（而非连锁素材效果）进行融合召唤。
		if sg1:IsContains(tc) and (sg2==nil or not sg2:IsContains(tc) or not Duel.SelectYesNo(tp,ce:GetDescription())) then
			-- 让玩家选择融合怪兽所需的融合素材。
			local mat1=Duel.SelectFusionMaterial(tp,tc,mg1,nil,chkf)
			tc:SetMaterial(mat1)
			local mat2=mat1:Filter(Card.IsLocation,nil,LOCATION_GRAVE)
			mat1:Sub(mat2)
			if #mat2>0 then
				-- 提示并展示被选为融合素材的墓地怪兽。
				Duel.HintSelection(mat2)
			end
			-- 将手卡·场上的融合素材送去墓地。
			Duel.SendtoGrave(mat1,REASON_EFFECT+REASON_MATERIAL+REASON_FUSION)
			-- 将墓地的融合素材回到持有者卡组。
			Duel.SendtoDeck(mat2,nil,2,REASON_EFFECT+REASON_MATERIAL+REASON_FUSION)
			-- 产生时点中断，使素材移动与特殊召唤不视为同时处理。
			Duel.BreakEffect()
			-- 将融合怪兽以融合召唤的方式表侧表示特殊召唤。
			Duel.SpecialSummon(tc,SUMMON_TYPE_FUSION,tp,tp,false,false,POS_FACEUP)
		else
			-- 在使用连锁素材效果时，让玩家选择对应的融合素材。
			local mat2=Duel.SelectFusionMaterial(tp,tc,mg3,nil,chkf)
			local fop=ce:GetOperation()
			fop(ce,e,tp,tc,mat2)
		end
		tc:CompleteProcedure()
	end
	-- 清除融合素材的额外检查函数。
	aux.FCheckAdditional=nil
end
-- 过滤卡组中的「莫忘」魔法·陷阱卡。
function s.filter(c)
	return c:IsSetCard(0x1a1) and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsAbleToHand()
end
-- 破坏并检索效果的发动准备，检查场上是否有怪兽可破坏以及卡组是否有可检索的卡，并设置操作信息。
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取自己场上的所有怪兽。
	local g=Duel.GetMatchingGroup(aux.TRUE,tp,LOCATION_MZONE,0,nil)
	-- 检查自己场上是否有怪兽可以破坏，且卡组中是否存在「莫忘」魔法·陷阱卡。
	if chk==0 then return #g>0 and Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置破坏的操作信息（破坏自己场上的1只怪兽）。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
	-- 设置加入手卡的操作信息（从卡组将1张卡加入手卡）。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 破坏并检索效果的处理逻辑：选择并破坏自己场上1只怪兽，若破坏成功，则从卡组将1张「莫忘」魔法·陷阱卡加入手卡。
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要破坏的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 让玩家选择自己场上的1只怪兽。
	local g=Duel.SelectMatchingCard(tp,aux.TRUE,tp,LOCATION_MZONE,0,1,1,nil)
	-- 破坏选中的怪兽，若破坏失败则终止效果处理。
	if Duel.Destroy(g,REASON_EFFECT)<1 then return end
	-- 提示玩家选择要加入手牌的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从卡组选择1张「莫忘」魔法·陷阱卡。
	local sg=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		-- 将选中的卡加入手卡。
		Duel.SendtoHand(sg,nil,REASON_EFFECT)
		-- 向对方玩家展示加入手卡的卡。
		Duel.ConfirmCards(1-tp,sg)
	end
end
