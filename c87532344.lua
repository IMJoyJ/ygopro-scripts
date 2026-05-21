--エターナル・フェイバリット
-- 效果：
-- ①：1回合1次，可以从以下效果选择1个发动（这个卡名的以下效果1回合各能选择1次）。
-- ●自己的墓地·除外状态的1只「于贝尔」怪兽特殊召唤。在那次特殊召唤成功时双方不能把魔法·陷阱·怪兽的效果发动。
-- ●自己场上有「于贝尔」存在的场合，丢弃1张手卡，把魔法与陷阱区域的表侧表示的这张卡送去墓地才能发动。包含「于贝尔」怪兽的自己·对方场上的怪兽作为融合素材，把1只融合怪兽融合召唤。
local s,id,o=GetID()
-- 初始化卡片效果（注册卡片效果）。
function s.initial_effect(c)
	-- 注册该卡记载了「于贝尔」的关系。
	aux.AddCodeList(c,78371393)
	-- 注册该卡记载了「于贝尔」系列怪兽的关系。
	aux.AddSetNameMonsterList(c,0x1a5)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- ●自己的墓地·除外状态的1只「于贝尔」怪兽特殊召唤。在那次特殊召唤成功时双方不能把魔法·陷阱·怪兽的效果发动。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))  --"特殊召唤「于贝尔」怪兽"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1,EFFECT_COUNT_CODE_SINGLE)
	e2:SetHintTiming(0,TIMING_END_PHASE)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
	-- ●自己场上有「于贝尔」存在的场合，丢弃1张手卡，把魔法与陷阱区域的表侧表示的这张卡送去墓地才能发动。包含「于贝尔」怪兽的自己·对方场上的怪兽作为融合素材，把1只融合怪兽融合召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))  --"用「于贝尔」怪兽融合召唤"
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON|CATEGORY_FUSION_SUMMON)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCountLimit(1,EFFECT_COUNT_CODE_SINGLE)
	e3:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e3:SetCondition(s.fucon)
	e3:SetCost(s.fucost)
	e3:SetTarget(s.futg)
	e3:SetOperation(s.fuop)
	c:RegisterEffect(e3)
end
-- 过滤条件：属于「于贝尔」系列且可以被特殊召唤的怪兽。
function s.spfilter(c,e,tp)
	return c:IsSetCard(0x1a5) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 特殊召唤效果的发动准备（检查是否满足发动条件、注册回合内发动标识、设置操作信息）。
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查本回合是否还未发动过此效果，且自己场上有可用的怪兽区域。
	if chk==0 then return Duel.GetFlagEffect(tp,id)==0 and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查自己的墓地或除外状态是否存在至少1只满足条件的「于贝尔」怪兽。
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,nil,e,tp) end
	-- 向对方玩家提示选择了发动哪个效果。
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
	-- 给玩家注册本回合已发动过此效果的标识（限制1回合1次选择1个）。
	Duel.RegisterFlagEffect(tp,id,RESET_PHASE+PHASE_END,0,1)
	-- 设置特殊召唤的操作信息（从墓地或除外状态特殊召唤1只怪兽）。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE+LOCATION_REMOVED)
end
-- 特殊召唤效果的处理（选择并特殊召唤怪兽，并注册特殊召唤成功时限制双方发动的效果）。
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要特殊召唤的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从墓地或除外状态选择1只满足条件的「于贝尔」怪兽（受王家长眠之谷影响）。
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.spfilter),tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		local tc=g:GetFirst()
		-- 如果成功将该怪兽以表侧表示特殊召唤。
		if tc and Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP) then
			-- 在那次特殊召唤成功时双方不能把魔法·陷阱·怪兽的效果发动。
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
			e1:SetCode(EVENT_SPSUMMON_SUCCESS)
			e1:SetLabelObject(tc)
			e1:SetCondition(s.sumcon)
			e1:SetOperation(s.sumop)
			-- 注册用于检测特殊召唤成功时点的效果。
			Duel.RegisterEffect(e1,tp)
			-- 在那次特殊召唤成功时双方不能把魔法·陷阱·怪兽的效果发动。
			local e2=Effect.CreateEffect(e:GetHandler())
			e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
			e2:SetCode(EVENT_CHAIN_END)
			e2:SetLabelObject(e1)
			e2:SetOperation(s.cedop)
			-- 注册用于检测连锁结束时点的效果。
			Duel.RegisterEffect(e2,tp)
		end
		-- 完成特殊召唤的流程。
		Duel.SpecialSummonComplete()
	end
end
-- 检查特殊召唤成功的怪兽中是否包含被特殊召唤的「于贝尔」怪兽。
function s.sumcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsContains(e:GetLabelObject())
end
-- 特殊召唤成功时的处理（根据当前连锁数限制双方的效果发动）。
function s.sumop(e,tp,eg,ep,ev,re,r,rp)
	e:SetLabel(1)
	-- 如果当前没有处于连锁处理中（即在连锁1特殊召唤成功）。
	if Duel.GetCurrentChain()==0 then
		-- 限制双方直到连锁结束前不能发动任何效果。
		Duel.SetChainLimitTillChainEnd(aux.FALSE)
	-- 如果当前处于连锁处理中（即在连锁2及以上特殊召唤成功）。
	elseif Duel.GetCurrentChain()==1 then
		e:GetHandler():RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD,0,1)
		-- 在那次特殊召唤成功时双方不能把魔法·陷阱·怪兽的效果发动。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_CHAINING)
		e1:SetOperation(s.resetop)
		-- 注册用于在连锁中重置标识的效果。
		Duel.RegisterEffect(e1,tp)
		local e2=e1:Clone()
		e2:SetCode(EVENT_BREAK_EFFECT)
		e2:SetReset(RESET_CHAIN)
		-- 注册用于在效果被中断时重置标识的效果。
		Duel.RegisterEffect(e2,tp)
	end
end
-- 重置限制发动的标识并使自身效果失效。
function s.resetop(e,tp,eg,ep,ev,re,r,rp)
	e:GetHandler():ResetFlagEffect(id)
	e:Reset()
end
-- 连锁结束时的处理（若在连锁中特殊召唤成功，则在连锁结束后限制双方发动效果）。
function s.cedop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查当前是否是特殊召唤成功时点，且确实成功特殊召唤了目标怪兽，并且限制标识依然有效。
	if Duel.CheckEvent(EVENT_SPSUMMON_SUCCESS) and e:GetLabelObject():GetLabel()==1 and e:GetHandler():GetFlagEffect(id)~=0 then
		-- 限制双方直到连锁结束前不能发动任何效果。
		Duel.SetChainLimitTillChainEnd(aux.FALSE)
	end
	e:GetHandler():ResetFlagEffect(id)
	e:Reset()
end
-- 过滤条件：场上表侧表示的「于贝尔」。
function s.fufilter(c,e,tp)
	return c:IsFaceup() and c:IsCode(78371393)
end
-- 融合召唤效果的发动条件（自己场上有「于贝尔」存在）。
function s.fucon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否存在表侧表示的「于贝尔」。
	return Duel.IsExistingMatchingCard(s.fufilter,tp,LOCATION_ONFIELD,0,1,nil)
end
-- 融合召唤效果的发动代价（丢弃1张手卡，并将表侧表示的这张卡送去墓地）。
function s.fucost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 检查手卡中是否存在除这张卡以外的可丢弃卡片。
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,e:GetHandler())
		and c:IsAbleToGraveAsCost() and c:IsStatus(STATUS_EFFECT_ENABLED) end
	-- 丢弃1张手卡。
	Duel.DiscardHand(tp,Card.IsDiscardable,1,1,REASON_COST+REASON_DISCARD)
	-- 将这张卡送去墓地。
	Duel.SendtoGrave(c,REASON_COST)
end
-- 过滤条件：场上表侧表示且可以作为融合素材的怪兽。
function s.filter0(c)
	return c:IsFaceup() and c:IsCanBeFusionMaterial()
end
-- 过滤条件：场上表侧表示、可以作为融合素材且不受当前效果影响的怪兽。
function s.filter1(c,e)
	return c:IsFaceup() and c:IsCanBeFusionMaterial() and not c:IsImmuneToEffect(e)
end
-- 过滤条件：额外卡组中可以被融合召唤且能用指定素材进行融合召唤的融合怪兽。
function s.filter2(c,e,tp,m,f,chkf)
	return c:IsType(TYPE_FUSION) and (not f or f(c))
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_FUSION,tp,false,false) and c:CheckFusionMaterial(m,nil,chkf)
end
-- 过滤条件：场上且不受当前效果影响的怪兽。
function s.filter3(c,e)
	return c:IsOnField() and not c:IsImmuneToEffect(e)
end
-- 融合素材检查：融合素材中必须包含至少1只「于贝尔」系列怪兽。
function s.fcheck(tp,sg,fc)
	return sg:IsExists(Card.IsFusionSetCard,1,nil,0x1a5)
end
-- 融合召唤效果的目标确认（检查是否有可融合召唤的怪兽，并注册回合内发动标识）。
function s.futg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local chkf=tp
		-- 获取自己场上可用的融合素材。
		local mg1=Duel.GetFusionMaterial(tp):Filter(Card.IsOnField,nil)
		-- 获取对方场上表侧表示可作为融合素材的怪兽。
		local mg2=Duel.GetMatchingGroup(s.filter0,tp,0,LOCATION_MZONE,nil)
		mg1:Merge(mg2)
		-- 设定融合素材的额外检查函数（必须包含「于贝尔」怪兽）。
		aux.FCheckAdditional=s.fcheck
		-- 检查额外卡组是否存在可以使用双方场上素材进行融合召唤的怪兽。
		local res=Duel.IsExistingMatchingCard(s.filter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg1,nil,chkf)
		if not res then
			-- 获取玩家受到的连锁素材效果。
			local ce=Duel.GetChainMaterial(tp)
			if ce~=nil then
				local fgroup=ce:GetTarget()
				local mg3=fgroup(ce,e,tp)
				local mf=ce:GetValue()
				-- 检查在使用连锁素材效果时，是否存在可以融合召唤的怪兽。
				res=Duel.IsExistingMatchingCard(s.filter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg3,mf,chkf)
			end
		end
		-- 重置融合素材的额外检查函数。
		aux.FCheckAdditional=nil
		-- 检查本回合是否还未发动过此效果，且存在可融合召唤的怪兽。
		return Duel.GetFlagEffect(tp,id+o)==0 and res
	end
	-- 向对方玩家提示选择了发动哪个效果。
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
	-- 给玩家注册本回合已发动过此效果的标识（限制1回合1次选择1个）。
	Duel.RegisterFlagEffect(tp,id+o,RESET_PHASE+PHASE_END,0,1)
	-- 设置特殊召唤的操作信息（从额外卡组特殊召唤1只怪兽）。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- 融合召唤效果的处理（收集双方场上素材，选择融合怪兽并进行融合召唤）。
function s.fuop(e,tp,eg,ep,ev,re,r,rp)
	local chkf=tp
	-- 获取自己场上不受当前效果影响的融合素材。
	local mg1=Duel.GetFusionMaterial(tp):Filter(s.filter3,nil,e)
	-- 获取对方场上不受当前效果影响的融合素材。
	local mg2=Duel.GetMatchingGroup(s.filter1,tp,0,LOCATION_MZONE,nil,e)
	mg1:Merge(mg2)
	-- 设定融合素材的额外检查函数（必须包含「于贝尔」怪兽）。
	aux.FCheckAdditional=s.fcheck
	-- 获取可以使用双方场上素材进行融合召唤的怪兽组。
	local sg1=Duel.GetMatchingGroup(s.filter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg1,nil,chkf)
	local mg3=nil
	local sg2=nil
	-- 获取玩家受到的连锁素材效果。
	local ce=Duel.GetChainMaterial(tp)
	if ce~=nil then
		local fgroup=ce:GetTarget()
		mg3=fgroup(ce,e,tp)
		local mf=ce:GetValue()
		-- 获取在使用连锁素材效果时可以融合召唤的怪兽组。
		sg2=Duel.GetMatchingGroup(s.filter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg3,mf,chkf)
	end
	if sg1:GetCount()>0 or (sg2~=nil and sg2:GetCount()>0) then
		local sg=sg1:Clone()
		if sg2 then sg:Merge(sg2) end
		-- 提示玩家选择要特殊召唤的卡。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		local tg=sg:Select(tp,1,1,nil)
		local tc=tg:GetFirst()
		-- 如果选择的怪兽可以使用场上素材进行融合召唤，且不使用连锁素材效果。
		if sg1:IsContains(tc) and (sg2==nil or not sg2:IsContains(tc) or not Duel.SelectYesNo(tp,ce:GetDescription())) then
			-- 让玩家选择用于融合召唤该怪兽的融合素材。
			local mat1=Duel.SelectFusionMaterial(tp,tc,mg1,nil,chkf)
			tc:SetMaterial(mat1)
			-- 将选中的融合素材送去墓地。
			Duel.SendtoGrave(mat1,REASON_EFFECT+REASON_MATERIAL+REASON_FUSION)
			-- 中断当前效果处理（使融合召唤与送去墓地不视为同时处理）。
			Duel.BreakEffect()
			-- 将融合怪兽以融合召唤方式特殊召唤。
			Duel.SpecialSummon(tc,SUMMON_TYPE_FUSION,tp,tp,false,false,POS_FACEUP)
		else
			-- 让玩家从连锁素材中选择用于融合召唤该怪兽的融合素材。
			local mat2=Duel.SelectFusionMaterial(tp,tc,mg3,nil,chkf)
			local fop=ce:GetOperation()
			fop(ce,e,tp,tc,mat2)
		end
		tc:CompleteProcedure()
	end
	-- 重置融合素材的额外检查函数。
	aux.FCheckAdditional=nil
end
