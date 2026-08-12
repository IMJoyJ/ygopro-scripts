--白の烙印
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：包含龙族怪兽的自己的手卡·场上的怪兽作为融合素材，把1只融合怪兽融合召唤。把自己的「阿不思的落胤」作为融合素材的场合，也能把自己墓地的怪兽除外作为融合素材。
-- ②：这张卡为让「阿不思的落胤」的效果发动而被送去墓地的回合的结束阶段才能发动。这张卡在自己场上盖放。
function c34995106.initial_effect(c)
	-- 记录此卡与「阿不思的落胤」的关联
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
	-- ②：这张卡为让「阿不思的落胤」的效果发动而被送去墓地的回合的结束阶段才能发动。这张卡在自己场上盖放。
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
-- 过滤满足融合召唤条件的墓地怪兽
function c34995106.filter1(c,e)
	return c:IsType(TYPE_MONSTER) and c:IsAbleToRemove() and c:IsCanBeFusionMaterial() and not c:IsImmuneToEffect(e)
end
-- 过滤不受效果影响的卡
function c34995106.filter2(c,e)
	return not c:IsImmuneToEffect(e)
end
-- 检查融合怪兽是否可以特殊召唤
function c34995106.spfilter(c,e,tp,m,f,chkf)
	return (not f or f(c))
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_FUSION,tp,false,false) and c:CheckFusionMaterial(m,nil,chkf)
end
-- 检查是否为「阿不思的落胤」
function c34995106.chkfilter(c,tp)
	return c:IsControler(tp) and c:IsCode(68468459)
end
-- 检查是否为己方墓地的卡
function c34995106.exfilter(c,tp)
	return c:IsControler(tp) and c:IsLocation(LOCATION_GRAVE)
end
-- 融合召唤条件检查函数，确保包含龙族怪兽且满足融合条件
function c34995106.fcheck(tp,sg,fc)
	if sg:IsExists(c34995106.chkfilter,1,nil,tp) then
		return sg:IsExists(Card.IsRace,1,nil,RACE_DRAGON)
	else
		return sg:IsExists(Card.IsRace,1,nil,RACE_DRAGON) and not sg:IsExists(c34995106.exfilter,1,nil,tp)
	end
end
-- 判断是否可以发动效果，检查是否有满足条件的融合怪兽
function c34995106.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local chkf=tp
		-- 获取玩家可用的融合素材组（手卡和场上的怪兽）
		local mg1=Duel.GetFusionMaterial(tp):Filter(c34995106.filter2,nil,e)
		-- 获取玩家墓地中的可作为融合素材的怪兽组
		local mg2=Duel.GetMatchingGroup(c34995106.filter1,tp,LOCATION_GRAVE,0,nil,e)
		if mg1:IsExists(c34995106.chkfilter,1,nil,tp) and mg2:GetCount()>0 or mg2:IsExists(c34995106.chkfilter,1,nil,tp) then
			mg1:Merge(mg2)
		end
		-- 设置融合召唤额外检查函数
		aux.FCheckAdditional=c34995106.fcheck
		-- 检查是否存在满足融合召唤条件的融合怪兽
		local res=Duel.IsExistingMatchingCard(c34995106.spfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg1,nil,chkf)
		if not res then
			-- 获取当前连锁的融合素材效果
			local ce=Duel.GetChainMaterial(tp)
			if ce~=nil then
				local fgroup=ce:GetTarget()
				local mg3=fgroup(ce,e,tp)
				local mf=ce:GetValue()
				-- 检查是否存在满足连锁融合素材条件的融合怪兽
				res=Duel.IsExistingMatchingCard(c34995106.spfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg3,mf,chkf)
			end
		end
		-- 清除融合召唤额外检查函数
		aux.FCheckAdditional=nil
		return res
	end
	-- 设置操作信息：特殊召唤
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
	-- 设置操作信息：除外
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,0,tp,LOCATION_GRAVE)
end
-- 发动效果，选择融合怪兽并进行融合召唤
function c34995106.activate(e,tp,eg,ep,ev,re,r,rp)
	local chkf=tp
	-- 获取玩家可用的融合素材组（手卡和场上的怪兽）
	local mg1=Duel.GetFusionMaterial(tp):Filter(c34995106.filter2,nil,e)
	-- 获取玩家墓地中的可作为融合素材的怪兽组
	local mg2=Duel.GetMatchingGroup(c34995106.filter1,tp,LOCATION_GRAVE,0,nil,e)
	if mg1:IsExists(c34995106.chkfilter,1,nil,tp) and mg2:GetCount()>0 or mg2:IsExists(c34995106.chkfilter,1,nil,tp) then
		mg1:Merge(mg2)
	end
	-- 设置融合召唤额外检查函数
	aux.FCheckAdditional=c34995106.fcheck
	-- 获取满足融合召唤条件的融合怪兽组
	local sg1=Duel.GetMatchingGroup(c34995106.spfilter,tp,LOCATION_EXTRA,0,nil,e,tp,mg1,nil,chkf)
	local mg3=nil
	local sg2=nil
	-- 获取当前连锁的融合素材效果
	local ce=Duel.GetChainMaterial(tp)
	if ce~=nil then
		local fgroup=ce:GetTarget()
		mg3=fgroup(ce,e,tp)
		local mf=ce:GetValue()
		-- 获取满足连锁融合素材条件的融合怪兽组
		sg2=Duel.GetMatchingGroup(c34995106.spfilter,tp,LOCATION_EXTRA,0,nil,e,tp,mg3,mf,chkf)
	end
	if sg1:GetCount()>0 or (sg2~=nil and sg2:GetCount()>0) then
		local sg=sg1:Clone()
		if sg2 then sg:Merge(sg2) end
		-- 提示玩家选择要特殊召唤的融合怪兽
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		local tg=sg:Select(tp,1,1,nil)
		local tc=tg:GetFirst()
		-- 判断是否使用普通融合召唤方式
		if sg1:IsContains(tc) and (sg2==nil or not sg2:IsContains(tc) or not Duel.SelectYesNo(tp,ce:GetDescription())) then
			-- 选择融合召唤的素材
			local mat1=Duel.SelectFusionMaterial(tp,tc,mg1,nil,chkf)
			tc:SetMaterial(mat1)
			local mat2=mat1:Filter(Card.IsLocation,nil,LOCATION_GRAVE)
			mat1:Sub(mat2)
			-- 将融合素材中的场上怪兽送入墓地
			Duel.SendtoGrave(mat1,REASON_EFFECT+REASON_MATERIAL+REASON_FUSION)
			-- 将融合素材中的墓地怪兽除外
			Duel.Remove(mat2,POS_FACEUP,REASON_EFFECT+REASON_MATERIAL+REASON_FUSION)
			-- 中断当前效果处理
			Duel.BreakEffect()
			-- 特殊召唤融合怪兽
			Duel.SpecialSummon(tc,SUMMON_TYPE_FUSION,tp,tp,false,false,POS_FACEUP)
		else
			-- 选择融合召唤的素材
			local mat2=Duel.SelectFusionMaterial(tp,tc,mg3,nil,chkf)
			local fop=ce:GetOperation()
			fop(ce,e,tp,tc,mat2)
		end
		tc:CompleteProcedure()
	end
	-- 清除融合召唤额外检查函数
	aux.FCheckAdditional=nil
end
-- 判断是否为「阿不思的落胤」的效果发动导致送入墓地
function c34995106.regcon(e,tp,eg,ep,ev,re,r,rp)
	-- 获取连锁触发的卡号
	local code1,code2=Duel.GetChainInfo(ev,CHAININFO_TRIGGERING_CODE,CHAININFO_TRIGGERING_CODE2)
	return e:GetHandler():IsReason(REASON_COST) and re and re:IsActivated() and (code1==68468459 or code2==68468459)
end
-- 注册标记，表示此卡在本回合可以发动②效果
function c34995106.regop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	c:RegisterFlagEffect(34995106,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1)
end
-- 判断是否可以发动②效果
function c34995106.setcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetFlagEffect(34995106)>0
end
-- 设置②效果的发动信息
function c34995106.settg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsSSetable() end
	-- 设置操作信息：盖放
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,e:GetHandler(),1,0,0)
end
-- 发动②效果，将此卡盖放
function c34995106.setop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 将此卡盖放
		Duel.SSet(tp,c)
	end
end
