--赫の聖女カルテシア
-- 效果：
-- 这个卡名的①②③的效果1回合各能使用1次。
-- ①：自己的场上或墓地有「阿不思的落胤」存在的场合才能发动。这张卡从手卡特殊召唤。
-- ②：自己·对方的主要阶段才能发动。自己的手卡·场上的怪兽作为融合素材，把1只8星以上的融合怪兽融合召唤。
-- ③：这个回合有融合怪兽被送去自己墓地的场合，结束阶段才能发动。墓地的这张卡加入手卡。
local s,id,o=GetID()
-- 初始化卡片效果，注册特殊召唤、融合召唤、回收自身效果以及全局融合怪兽送墓检测。
function s.initial_effect(c)
	-- 记录这张卡记载了「阿不思的落胤」的卡名。
	aux.AddCodeList(c,68468459)
	-- ①：自己的场上或墓地有「阿不思的落胤」存在的场合才能发动。这张卡从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetCondition(s.spcon)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	-- ②：自己·对方的主要阶段才能发动。自己的手卡·场上的怪兽作为融合素材，把1只8星以上的融合怪兽融合召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_MZONE)
	e2:SetHintTiming(0,TIMING_MAIN_END)
	e2:SetCountLimit(1,id+o)
	e2:SetCondition(s.condition)
	e2:SetTarget(s.target)
	e2:SetOperation(s.operation)
	c:RegisterEffect(e2)
	-- ③：这个回合有融合怪兽被送去自己墓地的场合，结束阶段才能发动。墓地的这张卡加入手卡。
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_TOHAND)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_PHASE+PHASE_END)
	e3:SetRange(LOCATION_GRAVE)
	e3:SetCountLimit(1,id+o*2)
	e3:SetCondition(s.thcon)
	e3:SetTarget(s.thtg)
	e3:SetOperation(s.thop)
	c:RegisterEffect(e3)
	if not s.global_check then
		s.global_check=true
		-- 这个卡名的①②③的效果1回合各能使用1次。①：自己的场上或墓地有「阿不思的落胤」存在的场合才能发动。这张卡从手卡特殊召唤。②：自己·对方的主要阶段才能发动。自己的手卡·场上的怪兽作为融合素材，把1只8星以上的融合怪兽融合召唤。③：这个回合有融合怪兽被送去自己墓地的场合，结束阶段才能发动。墓地的这张卡加入手卡。
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_TO_GRAVE)
		ge1:SetOperation(s.checkop)
		-- 注册全局效果，用于检测是否有融合怪兽被送去墓地。
		Duel.RegisterEffect(ge1,0)
	end
end
-- 过滤条件：场上或墓地的「阿不思的落胤」。
function s.spcfilter(c)
	return c:IsCode(68468459) and (c:IsFaceup() or c:IsLocation(LOCATION_GRAVE))
end
-- 效果①的发动条件：检查自己场上或墓地是否存在「阿不思的落胤」。
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上或墓地是否存在至少1张满足过滤条件的卡。
	return Duel.IsExistingMatchingCard(s.spcfilter,tp,LOCATION_ONFIELD+LOCATION_GRAVE,0,1,nil)
end
-- 效果①的靶向处理：检查怪兽区域空位并确认自身能否特殊召唤，设置特殊召唤的操作信息。
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 检查自己场上是否有可用的怪兽区域空格。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置特殊召唤的操作信息，将自身作为特殊召唤的对象。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
-- 效果①的操作处理：将手卡的这张卡特殊召唤。
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 若此卡仍存在于手卡，则将其在自身场上表侧表示特殊召唤。
	if c:IsRelateToEffect(e) then Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP) end
end
-- 效果②的发动条件：自己或对方的主要阶段。
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前的阶段。
	local ph=Duel.GetCurrentPhase()
	return ph==PHASE_MAIN1 or ph==PHASE_MAIN2
end
-- 过滤条件：不受效果影响的怪兽除外（用于融合素材过滤）。
function s.filter1(c,e)
	return not c:IsImmuneToEffect(e)
end
-- 过滤条件：额外卡组中可以使用当前素材进行融合召唤的8星以上的融合怪兽。
function s.filter2(c,e,tp,m,f,chkf)
	return c:IsType(TYPE_FUSION) and c:IsLevelAbove(8) and (not f or f(c))
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_FUSION,tp,false,false) and c:CheckFusionMaterial(m,nil,chkf)
end
-- 效果②的靶向处理：检查是否存在可融合召唤的怪兽，并设置特殊召唤的操作信息。
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local chkf=tp
		-- 获取玩家可用的融合素材卡片组（手卡和场上）。
		local mg1=Duel.GetFusionMaterial(tp)
		-- 检查额外卡组是否存在满足条件的、可使用当前素材融合召唤的8星以上融合怪兽。
		local res=Duel.IsExistingMatchingCard(s.filter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg1,nil,chkf)
		if not res then
			-- 获取玩家受到的连锁素材效果。
			local ce=Duel.GetChainMaterial(tp)
			if ce~=nil then
				local fgroup=ce:GetTarget()
				local mg2=fgroup(ce,e,tp)
				local mf=ce:GetValue()
				-- 检查在使用连锁素材效果提供的素材时，是否存在可融合召唤的8星以上融合怪兽。
				res=Duel.IsExistingMatchingCard(s.filter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg2,mf,chkf)
			end
		end
		return res
	end
	-- 设置特殊召唤的操作信息，表示从额外卡组特殊召唤1只怪兽。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- 效果②的操作处理：选择并融合召唤1只8星以上的融合怪兽。
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local chkf=tp
	-- 获取玩家可用且不受此效果影响的融合素材卡片组。
	local mg1=Duel.GetFusionMaterial(tp):Filter(s.filter1,nil,e)
	-- 获取额外卡组中可以使用当前素材融合召唤的8星以上融合怪兽组。
	local sg1=Duel.GetMatchingGroup(s.filter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg1,nil,chkf)
	local mg2=nil
	local sg2=nil
	-- 获取玩家受到的连锁素材效果。
	local ce=Duel.GetChainMaterial(tp)
	if ce~=nil then
		local fgroup=ce:GetTarget()
		mg2=fgroup(ce,e,tp)
		local mf=ce:GetValue()
		-- 获取在使用连锁素材效果时，额外卡组中可融合召唤的8星以上融合怪兽组。
		sg2=Duel.GetMatchingGroup(s.filter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg2,mf,chkf)
	end
	if #sg1>0 or (sg2~=nil and #sg2>0) then
		local sg=sg1:Clone()
		if sg2 then sg:Merge(sg2) end
		-- 提示玩家选择要特殊召唤的怪兽。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		local tg=sg:Select(tp,1,1,nil)
		local tc=tg:GetFirst()
		-- 判断是否使用常规融合方式（而非连锁素材效果）进行融合召唤。
		if sg1:IsContains(tc) and (sg2==nil or not sg2:IsContains(tc) or not Duel.SelectYesNo(tp,ce:GetDescription())) then
			-- 让玩家选择用于融合召唤该怪兽的融合素材。
			local mat1=Duel.SelectFusionMaterial(tp,tc,mg1,nil,chkf)
			tc:SetMaterial(mat1)
			-- 将选中的融合素材送去墓地。
			Duel.SendtoGrave(mat1,REASON_EFFECT+REASON_MATERIAL+REASON_FUSION)
			-- 中断当前效果处理，使后续的特殊召唤不与送墓同时处理（造成错时点）。
			Duel.BreakEffect()
			-- 将融合怪兽以融合召唤的方式表侧表示特殊召唤到场上。
			Duel.SpecialSummon(tc,SUMMON_TYPE_FUSION,tp,tp,false,false,POS_FACEUP)
		else
			-- 让玩家从连锁素材效果提供的素材中选择融合素材。
			local mat2=Duel.SelectFusionMaterial(tp,tc,mg2,nil,chkf)
			local fop=ce:GetOperation()
			fop(ce,e,tp,tc,mat2)
		end
		tc:CompleteProcedure()
	end
end
-- 过滤条件：属于该玩家的融合怪兽。
function s.checkfilter(c,tp)
	return c:IsType(TYPE_FUSION) and c:IsControler(tp)
end
-- 全局检测操作：若有融合怪兽被送去玩家墓地，则为该玩家注册对应的回合结束阶段标识。
function s.checkop(e,tp,eg,ep,ev,re,r,rp)
	-- 若有融合怪兽被送去玩家0的墓地，则为玩家0注册回合结束时失效的标识效果。
	if eg:IsExists(s.checkfilter,1,nil,0) then Duel.RegisterFlagEffect(0,id,RESET_PHASE+PHASE_END,0,1) end
	-- 若有融合怪兽被送去玩家1的墓地，则为玩家1注册回合结束时失效的标识效果。
	if eg:IsExists(s.checkfilter,1,nil,1) then Duel.RegisterFlagEffect(1,id,RESET_PHASE+PHASE_END,0,1) end
end
-- 效果③的发动条件：本回合有融合怪兽被送去自己墓地，且当前为结束阶段。
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查本回合自己是否有融合怪兽被送去墓地的标识。
	return Duel.GetFlagEffect(tp,id)>0
end
-- 效果③的靶向处理：检查墓地的这张卡是否能加入手卡，并设置加入手卡的操作信息。
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToHand() end
	-- 设置加入手卡的操作信息，将墓地的自身作为操作对象。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,e:GetHandler(),1,0,0)
end
-- 效果③的操作处理：将墓地的这张卡加入手卡。
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 将这张卡加入持有者的手卡。
		Duel.SendtoHand(c,nil,REASON_EFFECT)
	end
end
