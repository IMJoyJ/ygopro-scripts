--アルトメギア・マスターワーク－継承－
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：自己·对方的主要阶段才能发动。包含「神艺」怪兽的自己的手卡·场上的怪兽作为融合素材，把1只融合怪兽融合召唤。场地区域有卡存在的场合，再让这个效果特殊召唤的怪兽的攻击力上升500。
-- ②：自己主要阶段把墓地的这张卡除外，以自己墓地3张「神艺」卡为对象才能发动（同名卡最多1张）。那些卡回到卡组。
local s,id,o=GetID()
-- 定义initial_effect函数，用于注册卡片效果。
function s.initial_effect(c)
	-- 创建融合召唤效果，描述为“融合召唤”，类别为特殊召唤和融合召唤，类型为起动效果，触发时机为自由连锁，提示时机为主怪兽登场或主要阶段结束，限制每回合使用次数为1次，条件为s.fscon，目标为s.fstg，操作为s.fsop。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"融合召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_MAIN_END)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.fscon)
	e1:SetTarget(s.fstg)
	e1:SetOperation(s.fsop)
	c:RegisterEffect(e1)
	-- 创建回卡组效果，类别为回卡组，类型为起动效果，属性为需要指定对象，生效范围为墓地，限制每回合使用次数为1次（id+o），代价为aux.bfgcost，目标为s.tdtg，操作为s.tdop。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_TODECK)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,id+o)
	-- 设置将这张卡除外的过滤条件，用于作为效果的启动代价。
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(s.tdtg)
	e2:SetOperation(s.tdop)
	c:RegisterEffect(e2)
end
-- 定义fscon函数，用于判断是否在主要阶段。
function s.fscon(e,tp,eg,ep,ev,re,r,rp)
	-- 返回当前是否为主阶段。
	return Duel.IsMainPhase()
end
-- 定义filter函数，用于筛选融合怪兽并检查其特殊召唤条件和融合素材。
function s.filter(c,e,tp,m,f,chkf)
	return c:IsType(TYPE_FUSION) and (not f or f(c))
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_FUSION,tp,false,false) and c:CheckFusionMaterial(m,nil,chkf)
end
-- 定义check函数，用于检查卡组中是否存在融合设定卡。
function s.check(tp,g,fc)
	return g:IsExists(Card.IsFusionSetCard,1,nil,0x1cd)
end
-- 定义fstg函数，用于确定融合召唤的目标卡片。
function s.fstg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local chkf=tp
		-- 获取玩家的融合素材，并过滤掉免疫效果的卡片。
		local mg1=Duel.GetFusionMaterial(tp):Filter(aux.NOT(Card.IsImmuneToEffect),nil,e)
		-- 将s.check函数赋值给aux.FCheckAdditional，用于辅助判断融合素材是否有效。
		aux.FCheckAdditional=s.check
		-- 使用Duel.IsExistingMatchingCard检查是否存在满足条件的融合怪兽。
		local res=Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg1,nil,chkf)
		if not res then
			-- 获取连锁素材。
			local ce=Duel.GetChainMaterial(tp)
			if ce~=nil then
				local fgroup=ce:GetTarget()
				local mg2=fgroup(ce,e,tp)
				local mf=ce:GetValue()
				-- 如果存在连锁素材，则使用Duel.IsExistingMatchingCard再次检查是否存在满足条件的融合怪兽。
				res=Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg2,mf,chkf)
			end
		end
		-- 将aux.FCheckAdditional重置为nil。
		aux.FCheckAdditional=nil
		return res
	end
	-- 设置操作信息为特殊召唤，目标数量为1，位置为额外怪兽区。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- 定义fsop函数，用于执行融合召唤的操作。
function s.fsop(e,tp,eg,ep,ev,re,r,rp)
	local chkf=tp
	-- 获取玩家的融合素材，并过滤掉免疫效果的卡片。
	local mg1=Duel.GetFusionMaterial(tp):Filter(aux.NOT(Card.IsImmuneToEffect),nil,e)
	-- 将s.check函数赋值给aux.FCheckAdditional，用于辅助判断融合素材是否有效。
	aux.FCheckAdditional=s.check
	-- 使用Duel.GetMatchingGroup筛选满足条件的融合怪兽。
	local sg1=Duel.GetMatchingGroup(s.filter,tp,LOCATION_EXTRA,0,nil,e,tp,mg1,nil,chkf)
	local mg2,sg2=nil,nil
	-- 获取连锁素材。
	local ce=Duel.GetChainMaterial(tp)
	if ce~=nil then
		local fgroup=ce:GetTarget()
		mg2=fgroup(ce,e,tp)
		local mf=ce:GetValue()
		-- 如果存在连锁素材，则获取对应的融合素材组。
		sg2=Duel.GetMatchingGroup(s.filter,tp,LOCATION_EXTRA,0,nil,e,tp,mg2,mf,chkf)
	end
	if #sg1>0 or (sg2~=nil and #sg2>0) then
		local sg=sg1:Clone()
		if sg2 then sg:Merge(sg2) end
		::cancel::
		-- 提示玩家选择要特殊召唤的卡片。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		local tc=sg:Select(tp,1,1,nil):GetFirst()
		-- 判断所选卡片是否在sg1中，或者sg2为空或不包含该卡片，或者存在连锁且玩家拒绝了选择。
		if sg1:IsContains(tc) and (sg2==nil or not sg2:IsContains(tc) or ce and not Duel.SelectYesNo(tp,ce:GetDescription())) then
			-- 让玩家从mg1中选择融合素材。
			local mat=Duel.SelectFusionMaterial(tp,tc,mg1,nil,chkf)
			if #mat==0 then goto cancel end
			tc:SetMaterial(mat)
			-- 将选定的素材送入墓地。
			Duel.SendtoGrave(mat,REASON_EFFECT+REASON_MATERIAL+REASON_FUSION)
			-- 中断当前效果。
			Duel.BreakEffect()
			-- 特殊召唤所选卡片。
			Duel.SpecialSummon(tc,SUMMON_TYPE_FUSION,tp,tp,false,false,POS_FACEUP)
		elseif ce then
			-- 让玩家从mg2中选择融合素材。
			local mat=Duel.SelectFusionMaterial(tp,tc,mg2,nil,chkf)
			if #mat==0 then goto cancel end
			local fop=ce:GetOperation()
			fop(ce,e,tp,tc,mat)
		end
		tc:CompleteProcedure()
		-- 如果场上存在怪兽区域，则中断效果并赋予攻击力上升的效果。
		if Duel.IsExistingMatchingCard(aux.TRUE,tp,LOCATION_FZONE,LOCATION_FZONE,1,nil) then
			-- 中断当前效果。
			Duel.BreakEffect()
			-- 为特殊召唤的怪兽注册一个持续性的攻击力提升效果。
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_UPDATE_ATTACK)
			e1:SetValue(500)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			tc:RegisterEffect(e1)
		end
	end
	-- 将aux.FCheckAdditional重置为nil。
	aux.FCheckAdditional=nil
end
-- 定义tdfilter函数，用于筛选可以返回卡组的神艺卡。
function s.tdfilter(c)
	return c:IsSetCard(0x1cd) and c:IsAbleToDeck() and c:IsCanBeEffectTarget()
end
-- 定义tdtg函数，用于确定要返回卡组的目标卡片。
function s.tdtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	-- 从墓地获取所有神艺卡。
	local g=Duel.GetMatchingGroup(s.tdfilter,tp,LOCATION_GRAVE,0,e:GetHandler())
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and s.tdfilter(chkc) end
	-- 检查目标卡片是否在墓地、由玩家控制且满足tdfilter的条件。
	if chk==0 then return g:CheckSubGroup(aux.dncheck,3,3) end
	-- 提示玩家选择要返回卡组的卡片。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 让玩家从g中选择最多3张不重复命名的卡片。
	local sg=g:SelectSubGroup(tp,aux.dncheck,false,3,3)
	-- 设置当前处理的连锁的目标卡片为选定的卡片组。
	Duel.SetTargetCard(sg)
	-- 设置操作信息为回卡组，目标数量为g的数量。
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,g:GetCount(),0,0)
end
-- 定义tdop函数，用于执行将卡片返回卡组的操作。
function s.tdop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取与当前连锁相关的目标卡片组。
	local g=Duel.GetTargetsRelateToChain()
	if g:GetCount()>0 then
		-- 将卡片组中的所有卡片送入卡组。
		Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	end
end
