--白の烙印
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：包含龙族怪兽的自己的手卡·场上的怪兽作为融合素材，把1只融合怪兽融合召唤。把自己的「阿不思的落胤」作为融合素材的场合，也能把自己墓地的怪兽除外作为融合素材。
-- ②：这张卡为让「阿不思的落胤」的效果发动而被送去墓地的回合的结束阶段才能发动。这张卡在自己场上盖放。
function c34995106.initial_effect(c)
	-- 将「阿不思的落胤」(68468459)登记为这张卡上记载的卡名，用于触发卡名相关效果。
	aux.AddCodeList(c,68468459)
	-- ①：包含龙族怪兽的自己的手卡·场上的怪兽作为融合素材，把1只融合怪兽融合召唤。把自己的「阿不思的落胤」作为融合素材的场合，也能把自己墓地的怪兽除外作为融合素材。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(34995106,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON+CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,34995106)
	e1:SetTarget(c34995106.target)
	e1:SetOperation(c34995106.activate)
	c:RegisterEffect(e1)
	-- ②：这张卡为让「阿不思的落胤」的效果发动而被送去墓地的回合
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetCondition(c34995106.regcon)
	e2:SetOperation(c34995106.regop)
	c:RegisterEffect(e2)
	-- ②：这张卡为让「阿不思的落胤」的效果发动而被送去墓地的回合的结束阶段才能发动。这张卡在自己场上盖放。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(34995106,1))
	e3:SetCategory(CATEGORY_SSET)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_PHASE+PHASE_END)
	e3:SetRange(LOCATION_GRAVE)
	e3:SetCountLimit(1,34995107)
	e3:SetCondition(c34995106.setcon)
	e3:SetTarget(c34995106.settg)
	e3:SetOperation(c34995106.setop)
	c:RegisterEffect(e3)
end
-- 过滤出墓地里可作为融合素材的怪兽：必须是怪兽卡、能够除外、能作为融合素材、且不受本效果影响。
function c34995106.filter1(c,e)
	return c:IsType(TYPE_MONSTER) and c:IsAbleToRemove() and c:IsCanBeFusionMaterial() and not c:IsImmuneToEffect(e)
end
-- 过滤出不受本效果影响的融合素材（用于手卡·场上的普通素材池）。
function c34995106.filter2(c,e)
	return not c:IsImmuneToEffect(e)
end
-- 从额外卡组中筛选能够使用素材组m进行融合召唤的融合怪兽，同时满足特殊召唤条件和附加素材检查函数f（连锁素材时）。
function c34995106.spfilter(c,e,tp,m,f,chkf)
	return (not f or f(c))
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_FUSION,tp,false,false) and c:CheckFusionMaterial(m,nil,chkf)
end
-- 判断一张卡是否为己方控制的「阿不思的落胤」(68468459)，用于检查素材中是否包含阿尔贝斯。
function c34995106.chkfilter(c,tp)
	return c:IsControler(tp) and c:IsCode(68468459)
end
-- 判断一张卡是否在己方墓地，用于检查是否可从墓地除外作为融合素材。
function c34995106.exfilter(c,tp)
	return c:IsControler(tp) and c:IsLocation(LOCATION_GRAVE)
end
-- 融合素材合法性检查：若素材中包含阿尔贝斯，则素材中必须有龙族怪兽且允许使用墓地素材；若不包含阿尔贝斯，则素材中必须有龙族怪兽且不允许使用墓地素材（只能使用手卡·场上的怪兽）。
function c34995106.fcheck(tp,sg,fc)
	if sg:IsExists(c34995106.chkfilter,1,nil,tp) then
		return sg:IsExists(Card.IsRace,1,nil,RACE_DRAGON)
	else
		return sg:IsExists(Card.IsRace,1,nil,RACE_DRAGON) and not sg:IsExists(c34995106.exfilter,1,nil,tp)
	end
end
-- 效果发动时的合法性检查：确认存在能用当前可用素材（含手卡·场上的龙族怪兽，若素材含阿尔贝斯则可额外用墓地怪兽）融合召唤的融合怪兽；若普通素材不满足，则检查连锁素材能否提供召唤；合法后设置特殊召唤与除外的操作信息。
function c34995106.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local chkf=tp
		-- 获取玩家可用的普通融合素材（手卡·场上的怪兽），并过滤掉受本效果免疫的卡，得到基础素材组mg1。
		local mg1=Duel.GetFusionMaterial(tp):Filter(c34995106.filter2,nil,e)
		-- 获取己方墓地里可作为融合素材的怪兽组mg2（满足filter1，可除外且可作为素材）。
		local mg2=Duel.GetMatchingGroup(c34995106.filter1,tp,LOCATION_GRAVE,0,nil,e)
		if mg1:IsExists(c34995106.chkfilter,1,nil,tp) and mg2:GetCount()>0 or mg2:IsExists(c34995106.chkfilter,1,nil,tp) then
			mg1:Merge(mg2)
		end
		-- 设置额外的融合素材合法性检查函数为c34995106.fcheck，用于后续融合召唤时验证素材组是否符合卡片的素材限制。
		aux.FCheckAdditional=c34995106.fcheck
		-- 检查额外卡组中是否存在至少1只融合怪兽，能够用mg1（可能已并入墓地素材）作为素材进行融合召唤。
		local res=Duel.IsExistingMatchingCard(c34995106.spfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg1,nil,chkf)
		if not res then
			-- 获取当前玩家可用的连锁素材效果（如「连锁素材」），用于在普通融合素材不可行时扩展素材组。
			local ce=Duel.GetChainMaterial(tp)
			if ce~=nil then
				local fgroup=ce:GetTarget()
				local mg3=fgroup(ce,e,tp)
				local mf=ce:GetValue()
				-- 使用连锁素材提供的素材组mg3和素材限制函数mf，再次检查额外卡组中是否存在可融合召唤的融合怪兽。
				res=Duel.IsExistingMatchingCard(c34995106.spfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg3,mf,chkf)
			end
		end
		-- 清除额外融合素材合法性检查函数，避免影响其他效果的判定。
		aux.FCheckAdditional=nil
		return res
	end
	-- 设置本次操作信息：将从额外卡组特殊召唤1只怪兽，供相关效果（如「暴走魔法阵」）响应。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
	-- 设置本次操作信息：可能涉及除外己方墓地怪兽，数量不固定（0表示不预设具体数量）。
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,0,tp,LOCATION_GRAVE)
end
-- 效果处理：从可用的融合怪兽候选中选择1只，再选择融合素材；若走普通融合路线，则手卡·场上素材送墓、墓地素材除外并融合召唤；若走连锁素材路线，则调用连锁素材的效果处理；最后完成融合召唤手续。
function c34995106.activate(e,tp,eg,ep,ev,re,r,rp)
	local chkf=tp
	-- 获取玩家可用的普通融合素材（手卡·场上的怪兽），并过滤掉受本效果免疫的卡，得到基础素材组mg1。
	local mg1=Duel.GetFusionMaterial(tp):Filter(c34995106.filter2,nil,e)
	-- 获取己方墓地里可作为融合素材的怪兽组mg2（满足filter1，可除外且可作为素材）。
	local mg2=Duel.GetMatchingGroup(c34995106.filter1,tp,LOCATION_GRAVE,0,nil,e)
	if mg1:IsExists(c34995106.chkfilter,1,nil,tp) and mg2:GetCount()>0 or mg2:IsExists(c34995106.chkfilter,1,nil,tp) then
		mg1:Merge(mg2)
	end
	-- 设置额外的融合素材合法性检查函数为c34995106.fcheck，用于后续融合召唤时验证素材组是否符合卡片的素材限制。
	aux.FCheckAdditional=c34995106.fcheck
	-- 获取所有能用当前素材组mg1进行融合召唤的融合怪兽列表sg1。
	local sg1=Duel.GetMatchingGroup(c34995106.spfilter,tp,LOCATION_EXTRA,0,nil,e,tp,mg1,nil,chkf)
	local mg3=nil
	local sg2=nil
	-- 获取当前玩家可用的连锁素材效果，用于在普通融合素材不可行时扩展素材组。
	local ce=Duel.GetChainMaterial(tp)
	if ce~=nil then
		local fgroup=ce:GetTarget()
		mg3=fgroup(ce,e,tp)
		local mf=ce:GetValue()
		-- 获取所有能用连锁素材组mg3进行融合召唤的融合怪兽列表sg2。
		sg2=Duel.GetMatchingGroup(c34995106.spfilter,tp,LOCATION_EXTRA,0,nil,e,tp,mg3,mf,chkf)
	end
	if sg1:GetCount()>0 or (sg2~=nil and sg2:GetCount()>0) then
		local sg=sg1:Clone()
		if sg2 then sg:Merge(sg2) end
		-- 提示玩家选择要特殊召唤的融合怪兽。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		local tg=sg:Select(tp,1,1,nil)
		local tc=tg:GetFirst()
		-- 判断所选融合怪兽是否属于普通素材可召唤列表，并且（连锁素材列表为空、或该怪兽不在连锁素材列表中、或玩家选择不使用连锁素材），若是则走普通融合召唤流程。
		if sg1:IsContains(tc) and (sg2==nil or not sg2:IsContains(tc) or not Duel.SelectYesNo(tp,ce:GetDescription())) then
			-- 让玩家从普通素材组mg1中选择融合怪兽tc所需的融合素材。
			local mat1=Duel.SelectFusionMaterial(tp,tc,mg1,nil,chkf)
			tc:SetMaterial(mat1)
			local mat2=mat1:Filter(Card.IsLocation,nil,LOCATION_GRAVE)
			mat1:Sub(mat2)
			-- 将选中的素材中非墓地的部分（手卡·场上的怪兽）作为融合素材送去墓地。
			Duel.SendtoGrave(mat1,REASON_EFFECT+REASON_MATERIAL+REASON_FUSION)
			-- 将选中的素材中位于墓地的那部分怪兽除外作为融合素材。
			Duel.Remove(mat2,POS_FACEUP,REASON_EFFECT+REASON_MATERIAL+REASON_FUSION)
			-- 中断当前效果处理，使融合召唤的时点独立，以便正确触发召唤成功时的诱发效果。
			Duel.BreakEffect()
			-- 将融合怪兽以表侧表示融合召唤到己方场上。
			Duel.SpecialSummon(tc,SUMMON_TYPE_FUSION,tp,tp,false,false,POS_FACEUP)
		else
			-- 在连锁素材路线中，让玩家从连锁素材组mg3中选择融合怪兽tc所需的素材。
			local mat2=Duel.SelectFusionMaterial(tp,tc,mg3,nil,chkf)
			local fop=ce:GetOperation()
			fop(ce,e,tp,tc,mat2)
		end
		tc:CompleteProcedure()
	end
	-- 清除额外素材合法性检查函数，恢复默认融合素材规则。
	aux.FCheckAdditional=nil
end
-- e2的触发条件：当「白之烙印」作为「阿不思的落胤」效果发动的cost被送去墓地时，返回true，以便登记标志。
function c34995106.regcon(e,tp,eg,ep,ev,re,r,rp)
	-- 取得送墓事件所在连锁中发动效果的卡的卡号（包括同名第二卡号），用于判断是否为「阿不思的落胤」(68468459)的效果。
	local code1,code2=Duel.GetChainInfo(ev,CHAININFO_TRIGGERING_CODE,CHAININFO_TRIGGERING_CODE2)
	return e:GetHandler():IsReason(REASON_COST) and re and re:IsActivated() and (code1==68468459 or code2==68468459)
end
-- e2的触发操作：为本卡注册一个持续到结束阶段的标记(34995106)，表示本回合已因阿尔贝斯效果发动而送墓。
function c34995106.regop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	c:RegisterFlagEffect(34995106,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1)
end
-- e3的发动条件：本卡在墓地且拥有标记34995106（即本回合因阿尔贝斯效果送墓过），才允许在结束阶段发动。
function c34995106.setcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetFlagEffect(34995106)>0
end
-- e3的发动目标检查：确认本卡能够被盖放；若能，则设置操作信息，表示要离开墓地。
function c34995106.settg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsSSetable() end
	-- 设置操作信息：这张卡将从墓地移动到场上（盖放），供相关效果响应。
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,e:GetHandler(),1,0,0)
end
-- e3的效果处理：若本卡仍然和该效果有关联，则将其盖放到自己场上。
function c34995106.setop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 将这张卡以里侧表示盖放在己方魔法·陷阱区域。
		Duel.SSet(tp,c)
	end
end
