--DDネクロ・スライム
-- 效果：
-- 这个卡名的效果1回合只能使用1次。
-- ①：这张卡在墓地存在的场合才能发动。包含这张卡的自己墓地的怪兽作为融合素材除外，把1只「DDD」融合怪兽融合召唤。
function c72291412.initial_effect(c)
	-- 这个卡名的效果1回合只能使用1次。①：这张卡在墓地存在的场合才能发动。包含这张卡的自己墓地的怪兽作为融合素材除外，把1只「DDD」融合怪兽融合召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_GRAVE)
	e1:SetCountLimit(1,72291412)
	e1:SetTarget(c72291412.target)
	e1:SetOperation(c72291412.operation)
	c:RegisterEffect(e1)
end
-- 过滤函数：过滤自己墓地中可以作为融合素材且可以除外的怪兽
function c72291412.filter0(c)
	return c:IsType(TYPE_MONSTER) and c:IsCanBeFusionMaterial() and c:IsAbleToRemove()
end
-- 过滤函数：过滤自己墓地中可以作为融合素材、可以除外且不受当前效果影响的怪兽
function c72291412.filter1(c,e)
	return c:IsType(TYPE_MONSTER) and c:IsCanBeFusionMaterial() and c:IsAbleToRemove() and not c:IsImmuneToEffect(e)
end
-- 过滤函数：过滤额外卡组中可以进行融合召唤的「DDD」融合怪兽
function c72291412.filter2(c,e,tp,m,f,gc,chkf)
	return c:IsType(TYPE_FUSION) and c:IsSetCard(0x10af) and (not f or f(c))
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_FUSION,tp,false,false) and c:CheckFusionMaterial(m,gc,chkf)
		-- 检查额外卡组怪兽特殊召唤到场上是否有可用的空格
		and Duel.GetLocationCountFromEx(tp,tp,nil,c)>0
end
-- 效果发动合法性检测与操作信息设置（Target阶段）
function c72291412.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then
		local chkf=tp
		-- 获取自己墓地中所有可作为融合素材且可除外的怪兽组
		local mg1=Duel.GetMatchingGroup(c72291412.filter0,tp,LOCATION_GRAVE,0,nil)
		-- 检查额外卡组是否存在可以使用墓地素材（必须包含此卡）进行融合召唤的「DDD」融合怪兽
		local res=Duel.IsExistingMatchingCard(c72291412.filter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg1,nil,c,chkf)
		if not res then
			-- 获取玩家受到的连锁素材效果（如「连锁素材」）
			local ce=Duel.GetChainMaterial(tp)
			if ce~=nil then
				local fgroup=ce:GetTarget()
				local mg2=fgroup(ce,e,tp)
				local mf=ce:GetValue()
				-- 检查在连锁素材效果影响下，是否存在可以融合召唤的「DDD」融合怪兽
				res=Duel.IsExistingMatchingCard(c72291412.filter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg2,mf,c,chkf)
			end
		end
		return res
	end
	-- 设置特殊召唤的操作信息，表示该效果包含从额外卡组特殊召唤怪兽的操作
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
	-- 设置除外的操作信息，表示该效果包含将墓地的此卡除外的操作
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,c,1,tp,LOCATION_GRAVE)
end
-- 效果处理的执行（Operation阶段）
function c72291412.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local chkf=tp
	if not c:IsRelateToEffect(e) or c:IsImmuneToEffect(e) then return end
	-- 获取自己墓地中所有可作为融合素材、可除外且不受此效果影响的怪兽组
	local mg1=Duel.GetMatchingGroup(c72291412.filter1,tp,LOCATION_GRAVE,0,nil,e)
	-- 过滤出当前可以融合召唤的「DDD」融合怪兽组
	local sg1=Duel.GetMatchingGroup(c72291412.filter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg1,nil,c,chkf)
	local mg2=nil
	local sg2=nil
	-- 获取玩家受到的连锁素材效果
	local ce=Duel.GetChainMaterial(tp)
	if ce~=nil then
		local fgroup=ce:GetTarget()
		mg2=fgroup(ce,e,tp)
		local mf=ce:GetValue()
		-- 过滤出在连锁素材效果影响下可以融合召唤的「DDD」融合怪兽组
		sg2=Duel.GetMatchingGroup(c72291412.filter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg2,mf,c,chkf)
	end
	if sg1:GetCount()>0 or (sg2~=nil and sg2:GetCount()>0) then
		local sg=sg1:Clone()
		if sg2 then sg:Merge(sg2) end
		-- 提示玩家选择要特殊召唤的怪兽
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		local tg=sg:Select(tp,1,1,nil)
		local tc=tg:GetFirst()
		-- 判断是否使用本卡自身的效果进行融合召唤（若不使用连锁素材效果，或玩家选择不使用连锁素材效果）
		if sg1:IsContains(tc) and (sg2==nil or not sg2:IsContains(tc) or not Duel.SelectYesNo(tp,ce:GetDescription())) then
			-- 让玩家从墓地选择融合素材（必须包含此卡）
			local mat1=Duel.SelectFusionMaterial(tp,tc,mg1,c,chkf)
			tc:SetMaterial(mat1)
			-- 将选定的融合素材怪兽表侧表示除外
			Duel.Remove(mat1,POS_FACEUP,REASON_EFFECT+REASON_MATERIAL+REASON_FUSION)
			-- 中断当前效果处理，使后续的特殊召唤与除外不视为同时处理
			Duel.BreakEffect()
			-- 将选定的「DDD」融合怪兽融合召唤
			Duel.SpecialSummon(tc,SUMMON_TYPE_FUSION,tp,tp,false,false,POS_FACEUP)
		else
			-- 在连锁素材效果下，让玩家选择对应的融合素材
			local mat2=Duel.SelectFusionMaterial(tp,tc,mg2,c,chkf)
			local fop=ce:GetOperation()
			fop(ce,e,tp,tc,mat2)
		end
		tc:CompleteProcedure()
	end
end
