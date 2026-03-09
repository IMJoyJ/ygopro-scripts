--オッドアイズ・フュージョン
-- 效果：
-- 「异色眼融合」在1回合只能发动1张。
-- ①：从自己的手卡·场上把龙族融合怪兽卡决定的融合素材怪兽送去墓地，把那1只融合怪兽从额外卡组融合召唤。对方场上有怪兽2只以上存在，自己场上没有怪兽存在的场合，自己的额外卡组的「异色眼」怪兽也能有最多2只作为融合素材。
function c48144509.initial_effect(c)
	-- 效果原文内容：「异色眼融合」在1回合只能发动1张。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,48144509+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(c48144509.target)
	e1:SetOperation(c48144509.activate)
	c:RegisterEffect(e1)
end
-- 效果作用：过滤手卡和场上的怪兽，筛选出可以送去墓地的卡片
function c48144509.filter1(c,e)
	return c:IsAbleToGrave() and not c:IsImmuneToEffect(e)
end
-- 效果作用：筛选额外卡组中满足异色眼种族、可作为融合素材且能送去墓地的怪兽
function c48144509.exfilter0(c)
	return c:IsSetCard(0x99) and c:IsCanBeFusionMaterial() and c:IsAbleToGrave()
end
-- 效果作用：筛选额外卡组中满足异色眼种族、可作为融合素材、能送去墓地且未被效果免疫的怪兽
function c48144509.exfilter1(c,e)
	return c:IsSetCard(0x99) and c:IsCanBeFusionMaterial() and c:IsAbleToGrave() and not c:IsImmuneToEffect(e)
end
-- 效果作用：筛选满足融合召唤条件的龙族融合怪兽
function c48144509.filter2(c,e,tp,m,f,chkf)
	return c:IsType(TYPE_FUSION) and c:IsRace(RACE_DRAGON) and (not f or f(c))
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_FUSION,tp,false,false) and c:CheckFusionMaterial(m,nil,chkf)
end
-- 效果作用：检查融合素材中来自额外卡组的数量不超过2只
function c48144509.fcheck(tp,sg,fc)
	return sg:FilterCount(Card.IsLocation,nil,LOCATION_EXTRA)<=2
end
-- 效果作用：检查融合素材中来自额外卡组的数量不超过2只
function c48144509.gcheck(sg)
	return sg:FilterCount(Card.IsLocation,nil,LOCATION_EXTRA)<=2
end
-- 效果原文内容：①：从自己的手卡·场上把龙族融合怪兽卡决定的融合素材怪兽送去墓地，把那1只融合怪兽从额外卡组融合召唤。
function c48144509.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local chkf=tp
		-- 效果作用：获取玩家当前可用的融合素材（包括手卡和场上的怪兽）并筛选出可送去墓地的卡片
		local mg1=Duel.GetFusionMaterial(tp):Filter(Card.IsAbleToGrave,nil)
		-- 效果作用：判断是否满足特殊融合条件（对方场上怪兽2只以上，自己场上没有怪兽）
		if Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)==0 and Duel.GetFieldGroupCount(tp,0,LOCATION_MZONE)>1 then
			-- 效果作用：获取额外卡组中满足异色眼种族、可作为融合素材且能送去墓地的怪兽
			local sg=Duel.GetMatchingGroup(c48144509.exfilter0,tp,LOCATION_EXTRA,0,nil)
			if sg:GetCount()>0 then
				mg1:Merge(sg)
				-- 效果作用：设置融合素材数量限制为最多2只来自额外卡组
				aux.FCheckAdditional=c48144509.fcheck
				-- 效果作用：设置融合素材数量限制为最多2只来自额外卡组
				aux.GCheckAdditional=c48144509.gcheck
			end
		end
		-- 效果作用：检查是否存在满足条件的融合怪兽
		local res=Duel.IsExistingMatchingCard(c48144509.filter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg1,nil,chkf)
		-- 效果作用：清除融合素材数量限制设置
		aux.FCheckAdditional=nil
		-- 效果作用：清除融合素材数量限制设置
		aux.GCheckAdditional=nil
		if not res then
			-- 效果作用：获取当前连锁中的融合素材效果
			local ce=Duel.GetChainMaterial(tp)
			if ce~=nil then
				local fgroup=ce:GetTarget()
				local mg2=fgroup(ce,e,tp)
				local mf=ce:GetValue()
				-- 效果作用：检查是否存在满足连锁中融合素材条件的融合怪兽
				res=Duel.IsExistingMatchingCard(c48144509.filter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg2,mf,chkf)
			end
		end
		return res
	end
	-- 效果作用：设置操作信息，表示将要特殊召唤一张来自额外卡组的融合怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- 效果原文内容：对方场上有怪兽2只以上存在，自己场上没有怪兽存在的场合，自己的额外卡组的「异色眼」怪兽也能有最多2只作为融合素材。
function c48144509.activate(e,tp,eg,ep,ev,re,r,rp)
	local chkf=tp
	-- 效果作用：获取玩家当前可用的融合素材（包括手卡和场上的怪兽）并筛选出可送去墓地且未被免疫的卡片
	local mg1=Duel.GetFusionMaterial(tp):Filter(c48144509.filter1,nil,e)
	local exmat=false
	-- 效果作用：判断是否满足特殊融合条件（对方场上怪兽2只以上，自己场上没有怪兽）
	if Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)==0 and Duel.GetFieldGroupCount(tp,0,LOCATION_MZONE)>1 then
		-- 效果作用：获取额外卡组中满足异色眼种族、可作为融合素材、能送去墓地且未被免疫的怪兽
		local sg=Duel.GetMatchingGroup(c48144509.exfilter1,tp,LOCATION_EXTRA,0,nil,e)
		if sg:GetCount()>0 then
			mg1:Merge(sg)
			exmat=true
		end
	end
	if exmat then
		-- 效果作用：设置融合素材数量限制为最多2只来自额外卡组
		aux.FCheckAdditional=c48144509.fcheck
		-- 效果作用：设置融合素材数量限制为最多2只来自额外卡组
		aux.GCheckAdditional=c48144509.gcheck
	end
	-- 效果作用：筛选满足融合召唤条件的龙族融合怪兽
	local sg1=Duel.GetMatchingGroup(c48144509.filter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg1,nil,chkf)
	-- 效果作用：清除融合素材数量限制设置
	aux.FCheckAdditional=nil
	-- 效果作用：清除融合素材数量限制设置
	aux.GCheckAdditional=nil
	local mg2=nil
	local sg2=nil
	-- 效果作用：获取当前连锁中的融合素材效果
	local ce=Duel.GetChainMaterial(tp)
	if ce~=nil then
		local fgroup=ce:GetTarget()
		mg2=fgroup(ce,e,tp)
		local mf=ce:GetValue()
		-- 效果作用：筛选满足连锁中融合素材条件的龙族融合怪兽
		sg2=Duel.GetMatchingGroup(c48144509.filter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg2,mf,chkf)
	end
	if sg1:GetCount()>0 or (sg2~=nil and sg2:GetCount()>0) then
		local sg=sg1:Clone()
		if sg2 then sg:Merge(sg2) end
		-- 效果作用：提示玩家选择要特殊召唤的融合怪兽
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		local tg=sg:Select(tp,1,1,nil)
		local tc=tg:GetFirst()
		mg1:RemoveCard(tc)
		-- 效果作用：判断是否使用额外卡组中的异色眼怪兽作为融合素材
		if sg1:IsContains(tc) and (sg2==nil or not sg2:IsContains(tc) or not Duel.SelectYesNo(tp,ce:GetDescription())) then
			if exmat then
				-- 效果作用：设置融合素材数量限制为最多2只来自额外卡组
				aux.FCheckAdditional=c48144509.fcheck
				-- 效果作用：设置融合素材数量限制为最多2只来自额外卡组
				aux.GCheckAdditional=c48144509.gcheck
			end
			-- 效果作用：选择融合怪兽的融合素材
			local mat1=Duel.SelectFusionMaterial(tp,tc,mg1,nil,chkf)
			-- 效果作用：清除融合素材数量限制设置
			aux.FCheckAdditional=nil
			-- 效果作用：清除融合素材数量限制设置
			aux.GCheckAdditional=nil
			tc:SetMaterial(mat1)
			-- 效果作用：将融合素材送去墓地
			Duel.SendtoGrave(mat1,REASON_EFFECT+REASON_MATERIAL+REASON_FUSION)
			-- 效果作用：中断当前效果处理
			Duel.BreakEffect()
			-- 效果作用：将融合怪兽特殊召唤到场上
			Duel.SpecialSummon(tc,SUMMON_TYPE_FUSION,tp,tp,false,false,POS_FACEUP)
		else
			-- 效果作用：选择连锁中融合素材的融合怪兽
			local mat2=Duel.SelectFusionMaterial(tp,tc,mg2,nil,chkf)
			local fop=ce:GetOperation()
			fop(ce,e,tp,tc,mat2)
		end
		tc:CompleteProcedure()
	end
end
