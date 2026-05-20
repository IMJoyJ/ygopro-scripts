--星辰竜ムルル
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：自己·对方的主要阶段才能发动。自己的手卡·场上的怪兽作为融合素材，把1只「星辰」融合怪兽融合召唤。这个回合，自己不是融合怪兽不能从额外卡组特殊召唤。
-- ②：这张卡成为融合召唤的素材送去墓地的场合才能发动。从卡组把1张「星辰」魔法·陷阱卡在自己场上盖放。那之后，可以把对方场上1只表侧表示怪兽的效果无效。
local s,id,o=GetID()
-- 注册卡片效果的初始化函数，包含①的融合召唤效果和②的作为素材送墓时盖放魔陷及无效怪兽效果。
function s.initial_effect(c)
	-- ①：自己·对方的主要阶段才能发动。自己的手卡·场上的怪兽作为融合素材，把1只「星辰」融合怪兽融合召唤。这个回合，自己不是融合怪兽不能从额外卡组特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"融合效果"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_MZONE)
	e1:SetHintTiming(0,TIMING_MAIN_END)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.fspcon)
	e1:SetTarget(s.fsptg)
	e1:SetOperation(s.fspop)
	c:RegisterEffect(e1)
	-- ②：这张卡成为融合召唤的素材送去墓地的场合才能发动。从卡组把1张「星辰」魔法·陷阱卡在自己场上盖放。那之后，可以把对方场上1只表侧表示怪兽的效果无效。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"盖放魔陷"
	e2:SetCategory(CATEGORY_DISABLE+CATEGORY_SSET)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_BE_MATERIAL)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCountLimit(1,id+o)
	e2:SetCondition(s.setcon)
	e2:SetTarget(s.settg)
	e2:SetOperation(s.setop)
	c:RegisterEffect(e2)
end
-- ①效果的发动条件：自己·对方的主要阶段。
function s.fspcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查当前是否为主要阶段。
	return Duel.IsMainPhase()
end
-- 过滤函数：过滤掉不受效果影响的融合素材怪兽。
function s.filter1(c,e)
	return not c:IsImmuneToEffect(e)
end
-- 过滤函数：过滤额外卡组中可以使用当前素材进行融合召唤的「星辰」融合怪兽。
function s.filter2(c,e,tp,m,f,chkf)
	return c:IsType(TYPE_FUSION) and c:IsSetCard(0x1c9) and (not f or f(c))
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_FUSION,tp,false,false) and c:CheckFusionMaterial(m,nil,chkf)
end
-- ①效果的发动准备：检查是否存在合法的融合怪兽，并设置特殊召唤的操作信息。
function s.fsptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local c=e:GetHandler()
		local chkf=tp
		-- 获取玩家可用的融合素材，并过滤掉不受效果影响的卡。
		local mg1=Duel.GetFusionMaterial(tp):Filter(s.filter1,nil,e)
		-- 检查额外卡组是否存在可以使用当前素材融合召唤的「星辰」融合怪兽。
		local res=Duel.IsExistingMatchingCard(s.filter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg1,nil,chkf)
		if not res then
			-- 检查玩家是否存在受「连锁素材」等效果影响的融合素材。
			local ce=Duel.GetChainMaterial(tp)
			if ce~=nil then
				local fgroup=ce:GetTarget()
				local mg2=fgroup(ce,e,tp)
				local mf=ce:GetValue()
				-- 检查在使用「连锁素材」等效果的素材时，是否存在可融合召唤的「星辰」融合怪兽。
				res=Duel.IsExistingMatchingCard(s.filter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg2,mf,chkf)
			end
		end
		return res
	end
	-- 设置操作信息：从额外卡组特殊召唤1只怪兽。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- ①效果的效果处理：进行融合召唤，并注册本回合不能从额外卡组特殊召唤融合怪兽以外怪兽的限制。
function s.fspop(e,tp,eg,ep,ev,re,r,rp)
	local chkf=tp
	-- 获取玩家可用的融合素材，并过滤掉不受效果影响的卡。
	local mg1=Duel.GetFusionMaterial(tp):Filter(s.filter1,nil,e)
	-- 获取额外卡组中可以使用当前素材融合召唤的「星辰」融合怪兽组。
	local sg1=Duel.GetMatchingGroup(s.filter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg1,nil,chkf)
	local mg2=nil
	local sg2=nil
	-- 获取玩家受到的「连锁素材」等效果。
	local ce=Duel.GetChainMaterial(tp)
	if ce~=nil then
		local fgroup=ce:GetTarget()
		mg2=fgroup(ce,e,tp)
		local mf=ce:GetValue()
		-- 获取在使用「连锁素材」等效果的素材时，可以融合召唤的「星辰」融合怪兽组。
		sg2=Duel.GetMatchingGroup(s.filter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg2,mf,chkf)
	end
	if sg1:GetCount()>0 or (sg2~=nil and sg2:GetCount()>0) then
		local sg=sg1:Clone()
		if sg2 then sg:Merge(sg2) end
		-- 提示玩家选择要特殊召唤的融合怪兽。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		local tg=sg:Select(tp,1,1,nil)
		local tc=tg:GetFirst()
		-- 判断是否使用常规融合素材进行融合召唤（若同时满足常规和连锁素材，则让玩家选择是否使用连锁素材效果）。
		if sg1:IsContains(tc) and (sg2==nil or not sg2:IsContains(tc) or ce and not Duel.SelectYesNo(tp,ce:GetDescription())) then
			-- 让玩家选择用于融合召唤该怪兽的常规融合素材。
			local mat1=Duel.SelectFusionMaterial(tp,tc,mg1,nil,chkf)
			tc:SetMaterial(mat1)
			-- 将选中的融合素材作为融合素材因效果送去墓地。
			Duel.SendtoGrave(mat1,REASON_EFFECT+REASON_MATERIAL+REASON_FUSION)
			-- 中断当前效果处理，使后续的特殊召唤不与送墓同时处理。
			Duel.BreakEffect()
			-- 将融合怪兽以融合召唤的方式表侧表示特殊召唤。
			Duel.SpecialSummon(tc,SUMMON_TYPE_FUSION,tp,tp,false,false,POS_FACEUP)
		elseif ce then
			-- 让玩家选择使用「连锁素材」等效果时的融合素材。
			local mat2=Duel.SelectFusionMaterial(tp,tc,mg2,nil,chkf)
			local fop=ce:GetOperation()
			fop(ce,e,tp,tc,mat2)
		end
		tc:CompleteProcedure()
	end
	-- 这个回合，自己不是融合怪兽不能从额外卡组特殊召唤。/②：这张卡成为融合召唤的素材送去墓地的场合才能发动。从卡组把1张「星辰」魔法·陷阱卡在自己场上盖放。那之后，可以把对方场上1只表侧表示怪兽的效果无效。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetTarget(s.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 注册该限制效果给玩家（即本回合不能从额外卡组特殊召唤融合怪兽以外的怪兽）。
	Duel.RegisterEffect(e1,tp)
end
-- 限制额外卡组特殊召唤的怪兽必须是融合怪兽。
function s.splimit(e,c)
	return not c:IsType(TYPE_FUSION) and c:IsLocation(LOCATION_EXTRA)
end
-- ②效果的发动条件：这张卡作为融合素材送去墓地的场合。
function s.setcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsLocation(LOCATION_GRAVE) and r==REASON_FUSION
end
-- 过滤函数：过滤卡组中可盖放的「星辰」魔法·陷阱卡。
function s.setfilter(c)
	return c:IsSetCard(0x1c9) and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsSSetable()
end
-- ②效果的发动准备：检查卡组中是否存在可盖放的「星辰」魔法·陷阱卡。
function s.settg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在至少1张可盖放的「星辰」魔法·陷阱卡。
	if chk==0 then return Duel.IsExistingMatchingCard(s.setfilter,tp,LOCATION_DECK,0,1,nil) end
end
-- ②效果的效果处理：从卡组盖放1张「星辰」魔陷，之后可选择无效对方场上1只表侧表示怪兽的效果。
function s.setop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 提示玩家选择要盖放的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)  --"请选择要盖放的卡"
	-- 让玩家从卡组选择1张满足条件的「星辰」魔法·陷阱卡。
	local g=Duel.SelectMatchingCard(tp,s.setfilter,tp,LOCATION_DECK,0,1,1,nil)
	local tc=g:GetFirst()
	-- 若成功将选中的卡在自己场上盖放。
	if tc and Duel.SSet(tp,tc)~=0 then
		-- 获取对方场上所有表侧表示且未被无效的效果怪兽。
		local sg=Duel.GetMatchingGroup(aux.NegateMonsterFilter,tp,0,LOCATION_MZONE,nil)
		-- 若存在可无效的怪兽，询问玩家是否发动无效效果。
		if #sg>0 and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then  --"是否把怪兽无效？"
			-- 提示玩家选择要无效效果的怪兽。
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISABLE)  --"请选择要无效的卡"
			local dg=sg:Select(tp,1,1,nil)
			-- 显式地在场上框选并提示被选中的怪兽。
			Duel.HintSelection(dg)
			-- 中断当前效果处理，使后续的无效效果不与盖放魔陷同时处理。
			Duel.BreakEffect()
			local nc=dg:GetFirst()
			if nc:IsCanBeDisabledByEffect(e) then
				-- 无效与该怪兽相关的连锁效果。
				Duel.NegateRelatedChain(nc,RESET_TURN_SET)
				-- 可以把对方场上1只表侧表示怪兽的效果无效。
				local e1=Effect.CreateEffect(c)
				e1:SetType(EFFECT_TYPE_SINGLE)
				e1:SetCode(EFFECT_DISABLE)
				e1:SetReset(RESET_EVENT+RESETS_STANDARD)
				nc:RegisterEffect(e1)
				-- 可以把对方场上1只表侧表示怪兽的效果无效。
				local e2=Effect.CreateEffect(c)
				e2:SetType(EFFECT_TYPE_SINGLE)
				e2:SetCode(EFFECT_DISABLE_EFFECT)
				e2:SetValue(RESET_TURN_SET)
				e2:SetReset(RESET_EVENT+RESETS_STANDARD)
				nc:RegisterEffect(e2)
			end
		end
	end
end
