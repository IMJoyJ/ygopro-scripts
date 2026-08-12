--ダーク・コーリング
-- 效果：
-- ①：自己的手卡·墓地的怪兽作为融合素材除外，把「暗黑融合」的效果才能特殊召唤的1只融合怪兽当作「暗黑融合」的融合召唤作融合召唤。
function c12071500.initial_effect(c)
	-- 为卡片注册关联卡片代码94820406（暗黑融合）
	aux.AddCodeList(c,94820406)
	-- ①：自己的手卡·墓地的怪兽作为融合素材除外，把「暗黑融合」的效果才能特殊召唤的1只融合怪兽当作「暗黑融合」的融合召唤作融合召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c12071500.target)
	e1:SetOperation(c12071500.activate)
	c:RegisterEffect(e1)
end
-- 过滤手卡中可除外的怪兽
function c12071500.filter0(c)
	return c:IsLocation(LOCATION_HAND) and c:IsAbleToRemove()
end
-- 过滤手卡中可除外且未被效果免疫的怪兽
function c12071500.filter1(c,e)
	return c:IsLocation(LOCATION_HAND) and c:IsAbleToRemove() and not c:IsImmuneToEffect(e)
end
-- 过滤可特殊召唤的融合怪兽
function c12071500.filter2(c,e,tp,m,f,chkf)
	return c:IsType(TYPE_FUSION) and c.dark_calling and (not f or f(c))
		and c:IsCanBeSpecialSummoned(e,SUMMON_VALUE_DARK_FUSION,tp,false,false) and c:CheckFusionMaterial(m,nil,chkf)
end
-- 过滤墓地中的可作为融合素材的怪兽
function c12071500.filter3(c)
	return c:IsType(TYPE_MONSTER) and c:IsCanBeFusionMaterial() and c:IsAbleToRemove()
end
-- 效果发动时的处理函数
function c12071500.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local chkf=tp
		-- 获取玩家可用的融合素材组并过滤出手卡中的可除外怪兽
		local mg1=Duel.GetFusionMaterial(tp):Filter(c12071500.filter0,nil)
		-- 获取玩家墓地中的可除外怪兽
		local mg2=Duel.GetMatchingGroup(c12071500.filter3,tp,LOCATION_GRAVE,0,nil)
		mg1:Merge(mg2)
		-- 检查是否存在满足条件的融合怪兽
		local res=Duel.IsExistingMatchingCard(c12071500.filter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg1,nil,chkf)
		if not res then
			-- 获取当前连锁中的融合素材效果
			local ce=Duel.GetChainMaterial(tp)
			if ce~=nil then
				local fgroup=ce:GetTarget()
				local mg3=fgroup(ce,e,tp)
				local mf=ce:GetValue()
				-- 检查是否存在满足连锁素材条件的融合怪兽
				res=Duel.IsExistingMatchingCard(c12071500.filter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg3,mf,chkf)
			end
		end
		return res
	end
	-- 设置操作信息：特殊召唤1只融合怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
	-- 设置操作信息：除外2张手卡或墓地的怪兽
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,2,tp,LOCATION_HAND+LOCATION_GRAVE)
end
-- 效果发动时的处理函数
function c12071500.activate(e,tp,eg,ep,ev,re,r,rp)
	local chkf=tp
	-- 获取玩家可用的融合素材组并过滤出手卡中未被效果免疫的怪兽
	local mg1=Duel.GetFusionMaterial(tp):Filter(c12071500.filter1,nil,e)
	-- 获取玩家墓地中的可除外怪兽
	local mg2=Duel.GetMatchingGroup(c12071500.filter3,tp,LOCATION_GRAVE,0,nil)
	mg1:Merge(mg2)
	-- 获取满足特殊召唤条件的融合怪兽
	local sg1=Duel.GetMatchingGroup(c12071500.filter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg1,nil,chkf)
	local mg3=nil
	local sg2=nil
	-- 获取当前连锁中的融合素材效果
	local ce=Duel.GetChainMaterial(tp)
	if ce~=nil then
		local fgroup=ce:GetTarget()
		mg3=fgroup(ce,e,tp)
		local mf=ce:GetValue()
		-- 获取满足连锁素材条件的融合怪兽
		sg2=Duel.GetMatchingGroup(c12071500.filter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg3,mf,chkf)
	end
	if sg1:GetCount()>0 or (sg2~=nil and sg2:GetCount()>0) then
		local sg=sg1:Clone()
		if sg2 then sg:Merge(sg2) end
		-- 提示玩家选择要特殊召唤的融合怪兽
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local tg=sg:Select(tp,1,1,nil)
		local tc=tg:GetFirst()
		-- 判断是否使用原融合素材或连锁素材
		if sg1:IsContains(tc) and (sg2==nil or not sg2:IsContains(tc) or not Duel.SelectYesNo(tp,ce:GetDescription())) then
			-- 选择融合怪兽的融合素材
			local mat1=Duel.SelectFusionMaterial(tp,tc,mg1,nil,chkf)
			tc:SetMaterial(mat1)
			-- 将融合素材除外
			Duel.Remove(mat1,POS_FACEUP,REASON_EFFECT+REASON_MATERIAL+REASON_FUSION)
			-- 中断当前效果处理
			Duel.BreakEffect()
			-- 特殊召唤融合怪兽
			Duel.SpecialSummon(tc,SUMMON_VALUE_DARK_FUSION,tp,tp,false,false,POS_FACEUP)
		else
			-- 选择融合怪兽的融合素材
			local mat2=Duel.SelectFusionMaterial(tp,tc,mg3,nil,chkf)
			local fop=ce:GetOperation()
			fop(ce,e,tp,tc,mat2,SUMMON_VALUE_DARK_FUSION)
		end
		tc:CompleteProcedure()
	end
end
