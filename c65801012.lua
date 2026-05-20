--サイバネット・フュージョン
-- 效果：
-- ①：从自己的手卡·场上把电子界族融合怪兽卡决定的融合素材怪兽送去墓地，把那1只融合怪兽从额外卡组融合召唤。额外怪兽区域没有自己怪兽存在的场合，也能把自己墓地的电子界族连接怪兽（最多1只）除外作为融合素材。
function c65801012.initial_effect(c)
	-- ①：从自己的手卡·场上把电子界族融合怪兽卡决定的融合素材怪兽送去墓地，把那1只融合怪兽从额外卡组融合召唤。额外怪兽区域没有自己怪兽存在的场合，也能把自己墓地的电子界族连接怪兽（最多1只）除外作为融合素材。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_REMOVE+CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c65801012.target)
	e1:SetOperation(c65801012.activate)
	c:RegisterEffect(e1)
end
-- 过滤额外怪兽区域（区域编号5和6）的怪兽
function c65801012.cfilter(c)
	return c:GetSequence()>=5
end
-- 过滤可以送去墓地且不受效果影响的卡片（用于融合素材）
function c65801012.filter1(c,e)
	return c:IsAbleToGrave() and not c:IsImmuneToEffect(e)
end
-- 过滤自己墓地中可以作为融合素材且可以除外的电子界族连接怪兽（用于发动条件判断）
function c65801012.exfilter0(c)
	return c:IsType(TYPE_LINK) and c:IsRace(RACE_CYBERSE) and c:IsCanBeFusionMaterial() and c:IsAbleToRemove()
end
-- 过滤自己墓地中可以作为融合素材、可以除外且不受效果影响的电子界族连接怪兽（用于效果处理）
function c65801012.exfilter1(c,e)
	return c:IsType(TYPE_LINK) and c:IsRace(RACE_CYBERSE) and c:IsCanBeFusionMaterial() and c:IsAbleToRemove() and not c:IsImmuneToEffect(e)
end
-- 过滤额外卡组中可以进行融合召唤的电子界族融合怪兽
function c65801012.filter2(c,e,tp,m,f,chkf)
	return c:IsType(TYPE_FUSION) and c:IsRace(RACE_CYBERSE) and (not f or f(c))
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_FUSION,tp,false,false) and c:CheckFusionMaterial(m,nil,chkf)
end
-- 融合素材检查辅助函数：限制从墓地选择的融合素材最多为1张
function c65801012.fcheck(tp,sg,fc)
	return sg:FilterCount(Card.IsLocation,nil,LOCATION_GRAVE)<=1
end
-- 融合素材选择检查辅助函数：限制从墓地选择的融合素材最多为1张
function c65801012.gcheck(sg)
	return sg:FilterCount(Card.IsLocation,nil,LOCATION_GRAVE)<=1
end
-- 效果发动时的合法性检查（Target阶段）
function c65801012.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local chkf=tp
		-- 获取玩家手卡和场上可以送去墓地的融合素材
		local mg1=Duel.GetFusionMaterial(tp):Filter(Card.IsAbleToGrave,nil)
		-- 检查自己的额外怪兽区域是否存在怪兽（若不存在，则可以使用墓地素材）
		if not Duel.IsExistingMatchingCard(c65801012.cfilter,tp,LOCATION_MZONE,0,1,nil) then
			-- 获取自己墓地中满足条件的电子界族连接怪兽
			local sg=Duel.GetMatchingGroup(c65801012.exfilter0,tp,LOCATION_GRAVE,0,nil)
			if sg:GetCount()>0 then
				mg1:Merge(sg)
				-- 设置融合素材检查的额外过滤函数（限制墓地素材最多1张）
				aux.FCheckAdditional=c65801012.fcheck
				-- 设置融合素材选择的额外过滤函数（限制墓地素材最多1张）
				aux.GCheckAdditional=c65801012.gcheck
			end
		end
		-- 检查额外卡组是否存在可以使用当前素材进行融合召唤的电子界族融合怪兽
		local res=Duel.IsExistingMatchingCard(c65801012.filter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg1,nil,chkf)
		-- 重置融合素材检查的额外过滤函数
		aux.FCheckAdditional=nil
		-- 重置融合素材选择的额外过滤函数
		aux.GCheckAdditional=nil
		if not res then
			-- 检查是否存在受“连锁素材”等卡片效果影响的融合素材
			local ce=Duel.GetChainMaterial(tp)
			if ce~=nil then
				local fgroup=ce:GetTarget()
				local mg2=fgroup(ce,e,tp)
				local mf=ce:GetValue()
				-- 检查在“连锁素材”等效果下，是否存在可以融合召唤的怪兽
				res=Duel.IsExistingMatchingCard(c65801012.filter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg2,mf,chkf)
			end
		end
		return res
	end
	-- 设置连锁操作信息：从额外卡组特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- 效果处理（Activate阶段）
function c65801012.activate(e,tp,eg,ep,ev,re,r,rp)
	local chkf=tp
	-- 获取手卡和场上可以作为融合素材送去墓地且不受此卡效果影响的卡片
	local mg1=Duel.GetFusionMaterial(tp):Filter(c65801012.filter1,nil,e)
	local exmat=false
	-- 检查自己的额外怪兽区域是否存在怪兽（若不存在，则可以使用墓地素材）
	if not Duel.IsExistingMatchingCard(c65801012.cfilter,tp,LOCATION_MZONE,0,1,nil) then
		-- 获取自己墓地中满足条件且不受此卡效果影响的电子界族连接怪兽
		local sg=Duel.GetMatchingGroup(c65801012.exfilter1,tp,LOCATION_GRAVE,0,nil,e)
		if sg:GetCount()>0 then
			mg1:Merge(sg)
			exmat=true
		end
	end
	if exmat then
		-- 设置融合素材检查的额外过滤函数（限制墓地素材最多1张）
		aux.FCheckAdditional=c65801012.fcheck
		-- 设置融合素材选择的额外过滤函数（限制墓地素材最多1张）
		aux.GCheckAdditional=c65801012.gcheck
	end
	-- 获取额外卡组中可以使用当前素材进行融合召唤的电子界族融合怪兽
	local sg1=Duel.GetMatchingGroup(c65801012.filter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg1,nil,chkf)
	-- 重置融合素材检查的额外过滤函数
	aux.FCheckAdditional=nil
	-- 重置融合素材选择的额外过滤函数
	aux.GCheckAdditional=nil
	local mg2=nil
	local sg2=nil
	-- 检查是否存在受“连锁素材”等卡片效果影响的融合素材
	local ce=Duel.GetChainMaterial(tp)
	if ce~=nil then
		local fgroup=ce:GetTarget()
		mg2=fgroup(ce,e,tp)
		local mf=ce:GetValue()
		-- 获取在“连锁素材”等效果下，可以融合召唤的怪兽组
		sg2=Duel.GetMatchingGroup(c65801012.filter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg2,mf,chkf)
	end
	if sg1:GetCount()>0 or (sg2~=nil and sg2:GetCount()>0) then
		local sg=sg1:Clone()
		if sg2 then sg:Merge(sg2) end
		-- 提示玩家选择要特殊召唤的怪兽
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		local tg=sg:Select(tp,1,1,nil)
		local tc=tg:GetFirst()
		mg1:RemoveCard(tc)
		-- 判断是否使用本卡自身的效果进行融合召唤（而非“连锁素材”等其他卡的效果）
		if sg1:IsContains(tc) and (sg2==nil or not sg2:IsContains(tc) or not Duel.SelectYesNo(tp,ce:GetDescription())) then
			if exmat then
				-- 设置融合素材检查的额外过滤函数（限制墓地素材最多1张）
				aux.FCheckAdditional=c65801012.fcheck
				-- 设置融合素材选择的额外过滤函数（限制墓地素材最多1张）
				aux.GCheckAdditional=c65801012.gcheck
			end
			-- 玩家选择融合素材
			local mat1=Duel.SelectFusionMaterial(tp,tc,mg1,nil,chkf)
			-- 重置融合素材检查的额外过滤函数
			aux.FCheckAdditional=nil
			-- 重置融合素材选择的额外过滤函数
			aux.GCheckAdditional=nil
			tc:SetMaterial(mat1)
			local rg=mat1:Filter(Card.IsLocation,nil,LOCATION_GRAVE)
			mat1:Sub(rg)
			-- 将非墓地来源的融合素材送去墓地
			Duel.SendtoGrave(mat1,REASON_EFFECT+REASON_MATERIAL+REASON_FUSION)
			-- 将来自墓地的融合素材除外
			Duel.Remove(rg,POS_FACEUP,REASON_EFFECT+REASON_MATERIAL+REASON_FUSION)
			-- 中断当前效果，使后续的特殊召唤处理不与素材移动同时处理
			Duel.BreakEffect()
			-- 将融合怪兽从额外卡组融合召唤
			Duel.SpecialSummon(tc,SUMMON_TYPE_FUSION,tp,tp,false,false,POS_FACEUP)
		else
			-- 在“连锁素材”等效果下，玩家选择融合素材
			local mat2=Duel.SelectFusionMaterial(tp,tc,mg2,nil,chkf)
			local fop=ce:GetOperation()
			fop(ce,e,tp,tc,mat2)
		end
		tc:CompleteProcedure()
	end
end
