--合成獣融合
-- 效果：
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：自己·对方的主要阶段才能发动。包含兽族·恶魔族怪兽其中任意种的自己的手卡·场上的怪兽作为融合素材，把1只融合怪兽融合召唤。
-- ②：自己主要阶段有这张卡在墓地存在，自己的场上或墓地有「有翼幻兽 奇美拉」存在的场合，可以从以下选择1个发动。
-- ●这张卡加入手卡。
-- ●这张卡除外，从自己的卡组·墓地把1只「幻兽王 加泽尔」和1只「巴风特」特殊召唤。
local s,id,o=GetID()
-- 初始化函数，注册卡片效果中涉及的卡片密码，并注册①效果（融合召唤）和②效果（墓地回收/特召）
function s.initial_effect(c)
	-- 向系统注册这张卡的效果中记载了「有翼幻兽 奇美拉」、「幻兽王 加泽尔」和「巴风特」的卡名
	aux.AddCodeList(c,4796100,5818798,77207191)
	-- ①：自己·对方的主要阶段才能发动。包含兽族·恶魔族怪兽其中任意种的自己的手卡·场上的怪兽作为融合素材，把1只融合怪兽融合召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_MAIN_END)
	e1:SetCondition(s.fscon)
	e1:SetTarget(s.fstg)
	e1:SetOperation(s.fsop)
	c:RegisterEffect(e1)
	-- ②：自己主要阶段有这张卡在墓地存在，自己的场上或墓地有「有翼幻兽 奇美拉」存在的场合，可以从以下选择1个发动。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,id)
	e2:SetCondition(s.gycon)
	e2:SetTarget(s.gytg)
	e2:SetOperation(s.gyop)
	c:RegisterEffect(e2)
end
-- ①效果的发动条件：自己或对方的主要阶段
function s.fscon(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前的阶段
	local ph=Duel.GetCurrentPhase()
	return ph==PHASE_MAIN1 or ph==PHASE_MAIN2
end
-- 融合怪兽的过滤条件：必须是融合怪兽、可以被融合召唤、且有合法的融合素材
function s.filter(c,e,tp,m,f,chkf)
	return c:IsType(TYPE_FUSION) and (not f or f(c))
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_FUSION,tp,false,false) and c:CheckFusionMaterial(m,nil,chkf)
end
-- 融合素材的额外检查条件：融合素材中必须包含至少1只兽族或恶魔族怪兽
function s.check(tp,g,fc)
	return g:IsExists(Card.IsRace,1,nil,RACE_BEAST+RACE_FIEND)
end
-- ①效果的发动准备（Target）：检查是否存在可融合召唤的怪兽，并设置特殊召唤的操作信息
function s.fstg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local chkf=tp
		-- 获取玩家可用于融合召唤的素材卡片组（手卡·场上）
		local mg1=Duel.GetFusionMaterial(tp)
		-- 设置融合素材的额外检查函数（必须包含兽族或恶魔族）
		aux.FCheckAdditional=s.check
		-- 检查额外卡组中是否存在可以使用当前素材进行融合召唤的怪兽
		local res=Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg1,nil,chkf)
		if not res then
			-- 检查玩家是否受到连锁素材（如「连锁素材」）效果的影响
			local ce=Duel.GetChainMaterial(tp)
			if ce~=nil then
				local fgroup=ce:GetTarget()
				local mg2=fgroup(ce,e,tp)
				local mf=ce:GetValue()
				-- 检查在使用连锁素材效果的素材时，额外卡组中是否存在可融合召唤的怪兽
				res=Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg2,mf,chkf)
			end
		end
		-- 清空融合素材的额外检查函数，避免影响后续其他卡的效果
		aux.FCheckAdditional=nil
		return res
	end
	-- 设置特殊召唤的操作信息，表示将从额外卡组特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- ①效果的效果处理（Operation）：选择并进行融合召唤
function s.fsop(e,tp,eg,ep,ev,re,r,rp)
	local chkf=tp
	-- 获取不受此卡效果影响以外的可用融合素材
	local mg1=Duel.GetFusionMaterial(tp):Filter(aux.NOT(Card.IsImmuneToEffect),nil,e)
	-- 在效果处理时，再次设置融合素材的额外检查函数（必须包含兽族或恶魔族）
	aux.FCheckAdditional=s.check
	-- 获取额外卡组中所有可以使用当前素材进行融合召唤的怪兽
	local sg1=Duel.GetMatchingGroup(s.filter,tp,LOCATION_EXTRA,0,nil,e,tp,mg1,nil,chkf)
	local mg2,sg2=nil,nil
	-- 获取玩家受到的连锁素材效果
	local ce=Duel.GetChainMaterial(tp)
	if ce~=nil then
		local fgroup=ce:GetTarget()
		mg2=fgroup(ce,e,tp)
		local mf=ce:GetValue()
		-- 获取在使用连锁素材效果的素材时，额外卡组中所有可融合召唤的怪兽
		sg2=Duel.GetMatchingGroup(s.filter,tp,LOCATION_EXTRA,0,nil,e,tp,mg2,mf,chkf)
	end
	if #sg1>0 or (sg2~=nil and #sg2>0) then
		local sg=sg1:Clone()
		if sg2 then sg:Merge(sg2) end
		::cancel::
		-- 提示玩家选择要特殊召唤的怪兽
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		local tc=sg:Select(tp,1,1,nil):GetFirst()
		if sg1:IsContains(tc) and (sg2==nil or not (sg2:IsContains(tc)
			-- 如果可以使用连锁素材的效果，询问玩家是否使用该效果进行融合召唤
			and Duel.SelectYesNo(tp,ce:GetDescription()))) then
			-- 让玩家选择用于融合召唤该怪兽的融合素材
			local mat=Duel.SelectFusionMaterial(tp,tc,mg1,nil,chkf)
			if #mat==0 then goto cancel end
			tc:SetMaterial(mat)
			-- 将选中的融合素材作为融合素材送去墓地
			Duel.SendtoGrave(mat,REASON_EFFECT+REASON_MATERIAL+REASON_FUSION)
			-- 中断当前效果处理，使送去墓地与特殊召唤不视为同时处理
			Duel.BreakEffect()
			-- 将融合怪兽以融合召唤的方式表侧表示特殊召唤
			Duel.SpecialSummon(tc,SUMMON_TYPE_FUSION,tp,tp,false,false,POS_FACEUP)
		else
			-- 让玩家从连锁素材提供的素材中选择融合素材
			local mat=Duel.SelectFusionMaterial(tp,tc,mg2,nil,chkf)
			if #mat==0 then goto cancel end
			local fop=ce:GetOperation()
			fop(ce,e,tp,tc,mat)
		end
		tc:CompleteProcedure()
	end
	-- 效果处理结束，清空融合素材的额外检查函数
	aux.FCheckAdditional=nil
end
-- 过滤条件：场上或墓地表侧表示存在的「有翼幻兽 奇美拉」
function s.cfilter(c)
	return c:IsFaceupEx() and c:IsCode(4796100)
end
-- ②效果的发动条件：自己主要阶段，且自己场上或墓地有「有翼幻兽 奇美拉」存在
function s.gycon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己的场上或墓地是否存在「有翼幻兽 奇美拉」
	return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_GRAVE+LOCATION_MZONE,0,1,nil)
end
-- 过滤条件：卡名为「幻兽王 加泽尔」或「巴风特」，且可以被特殊召唤
function s.sfilter(c,e,tp)
	return c:IsCode(5818798,77207191) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- ②效果的发动准备（Target）：检测可发动的分支，让玩家选择其中一个发动，并设置相应的操作信息
function s.gytg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local b1=c:IsAbleToHand()
	-- 获取卡组或墓地中所有满足特召条件的「幻兽王 加泽尔」和「巴风特」
	local g=Duel.GetMatchingGroup(s.sfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,nil,e,tp)
	-- 检查分支2的可行性：此卡可以除外，且自己场上有2个以上的怪兽区域空位
	local b2=c:IsAbleToRemove() and Duel.GetLocationCount(tp,LOCATION_MZONE)>1
		-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
		and not Duel.IsPlayerAffectedByEffect(tp,59822133)
		and g:GetClassCount(Card.GetCode)>1
	if chk==0 then return b1 or b2 end
	local op=aux.SelectFromOptions(tp,{b1,aux.Stringid(id,2)},{b2,aux.Stringid(id,3)})  --"这张卡加入手卡/这张卡除外并特殊召唤"
	e:SetLabel(op)
	if op==1 then
		e:SetCategory(CATEGORY_TOHAND)
		-- 设置操作信息：将此卡加入手卡
		Duel.SetOperationInfo(0,CATEGORY_TOHAND,c,1,0,0)
	else
		e:SetCategory(CATEGORY_REMOVE+CATEGORY_SPECIAL_SUMMON)
		-- 设置操作信息：将此卡除外
		Duel.SetOperationInfo(0,CATEGORY_REMOVE,c,1,0,0)
		-- 设置操作信息：从卡组或墓地特殊召唤2只怪兽
		Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,2,tp,LOCATION_DECK+LOCATION_GRAVE)
	end
end
-- ②效果的效果处理（Operation）：根据玩家选择的分支执行对应的处理
function s.gyop(e,tp,eg,ep,ev,re,r,rp)
	local op=e:GetLabel()
	if op==1 then
		s.tohand(e,tp,eg,ep,ev,re,r,rp)
	elseif op==2 then
		s.banish(e,tp,eg,ep,ev,re,r,rp)
	end
end
-- 分支1的处理：将墓地的这张卡加入手卡
function s.tohand(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 如果此卡仍存在于墓地，则将其加入手卡
	if c:IsRelateToEffect(e) then Duel.SendtoHand(c,nil,REASON_EFFECT) end
end
-- 分支2的处理：将此卡除外，并从卡组·墓地特殊召唤「幻兽王 加泽尔」和「巴风特」
function s.banish(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 检查此卡是否仍存在于墓地，并将其表侧表示除外，若除外失败则终止处理
	if not c:IsRelateToEffect(e) or Duel.Remove(c,POS_FACEUP,REASON_EFFECT)==0
		-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
		or Duel.GetLocationCount(tp,LOCATION_MZONE)<2 or Duel.IsPlayerAffectedByEffect(tp,59822133) then return end
	-- 获取卡组或墓地中不受「王家长眠之谷」影响的「幻兽王 加泽尔」和「巴风特」
	local g=Duel.GetMatchingGroup(aux.NecroValleyFilter(s.sfilter),tp,LOCATION_DECK+LOCATION_GRAVE,0,nil,e,tp)
	-- 提示玩家选择要特殊召唤的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从过滤出的卡片中选择2张卡名不同的怪兽（即「幻兽王 加泽尔」和「巴风特」各1只）
	local sg=g:SelectSubGroup(tp,aux.dncheck,false,2,2)
	-- 将选中的2只怪兽表侧表示特殊召唤
	if sg then Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP) end
end
