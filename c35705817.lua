--幽合－ゴースト・フュージョン
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：从自己场上把融合怪兽卡决定的融合素材怪兽送去墓地，把那1只融合怪兽从额外卡组融合召唤。那个时候，融合素材怪兽必须全部是不死族怪兽。自己基本分比对方少的场合，自己的手卡·卡组·墓地的不死族怪兽也能有最多1只除外作为融合素材。
function c35705817.initial_effect(c)
	-- 这个卡名的卡在1回合只能发动1张。①：从自己场上把融合怪兽卡决定的融合素材怪兽送去墓地，把那1只融合怪兽从额外卡组融合召唤。那个时候，融合素材怪兽必须全部是不死族怪兽。自己基本分比对方少的场合，自己的手卡·卡组·墓地的不死族怪兽也能有最多1只除外作为融合素材。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON+CATEGORY_GRAVE_ACTION)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,35705817+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(c35705817.target)
	e1:SetOperation(c35705817.activate)
	c:RegisterEffect(e1)
end
-- 筛选可除外作为融合素材的手卡·卡组·墓地的不死族怪兽：须为怪兽、可作为融合素材、可除外且种族为不死族。
function c35705817.filter0(c)
	return c:IsType(TYPE_MONSTER) and c:IsCanBeFusionMaterial() and c:IsAbleToRemove() and c:IsRace(RACE_ZOMBIE)
end
-- 筛选场上可作为融合素材且不受该效果影响的不死族怪兽，用于效果处理时排除免疫该效果的卡。
function c35705817.filter1(c,e)
	return not c:IsImmuneToEffect(e) and c:IsOnField() and c:IsRace(RACE_ZOMBIE)
end
-- 筛选场上的不死族怪兽，用于目标阶段获取通常融合素材池时仅保留场上不死族。
function c35705817.filter(c)
	return c:IsOnField() and c:IsRace(RACE_ZOMBIE)
end
-- 筛选符合条件的融合怪兽：须为融合怪兽、可以融合召唤、且能用给定素材组完成融合素材组合。
function c35705817.filter2(c,e,tp,m,f,chkf)
	return c:IsType(TYPE_FUSION) and (not f or f(c))
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_FUSION,tp,false,false) and c:CheckFusionMaterial(m,nil,chkf)
end
-- 额外素材数量限制检查：选择的融合素材中来自手卡·卡组·墓地的卡不能超过1张。
function c35705817.fcheck(tp,sg,fc)
	return sg:FilterCount(Card.IsLocation,nil,LOCATION_DECK+LOCATION_HAND+LOCATION_GRAVE)<=1
end
-- 融合素材组合法性检查：整组素材中来自手卡·卡组·墓地的卡不能超过1张。
function c35705817.gcheck(sg)
	return sg:FilterCount(Card.IsLocation,nil,LOCATION_DECK+LOCATION_HAND+LOCATION_GRAVE)<=1
end
-- 发动条件判定：确认可使用场上不死族素材进行融合召唤，且LP较低时可将手卡·卡组·墓地的不死族怪兽作为额外素材；满足条件后设置特殊召唤操作信息。
function c35705817.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local chkf=tp
		-- 取得通常融合素材池，并筛选出其中的场上不死族怪兽作为基础可选素材。
		local mg1=Duel.GetFusionMaterial(tp):Filter(c35705817.filter,nil)
		local mg2=Group.CreateGroup()
		-- 判断发动者LP是否低于对方LP，以决定是否追加手卡·卡组·墓地的不死族素材。
		if Duel.GetLP(tp)<Duel.GetLP(1-tp) then
			-- LP较低时，检索手卡·卡组·墓地中满足条件（不死族、可除外、可作融合素材）的怪兽作为追加素材池。
			mg2=Duel.GetMatchingGroup(c35705817.filter0,tp,LOCATION_DECK+LOCATION_HAND+LOCATION_GRAVE,0,nil)
		end
		if mg2:GetCount()>0 then
			mg1:Merge(mg2)
			-- 设置辅助融合素材检查函数，强制后续选择素材时应用“手卡/卡组/墓地素材最多1张”的限制。
			aux.FCheckAdditional=c35705817.fcheck
			-- 设置融合素材组检查函数，使素材组整体也受同样数量限制。
			aux.GCheckAdditional=c35705817.gcheck
		end
		-- 检查额外卡组中是否存在能用当前素材池进行融合召唤的融合怪兽，作为发动条件。
		local res=Duel.IsExistingMatchingCard(c35705817.filter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg1,nil,chkf)
		-- 清除已设置的辅助素材检查函数，避免影响其他效果判定。
		aux.FCheckAdditional=nil
		-- 清除已设置的素材组检查函数。
		aux.GCheckAdditional=nil
		if not res then
			-- 获取当前玩家可用的连锁素材效果（如“连锁素材”），用于扩展融合素材来源。
			local ce=Duel.GetChainMaterial(tp)
			if ce~=nil then
				local fgroup=ce:GetTarget()
				local mg3=fgroup(ce,e,tp)
				local mf=ce:GetValue()
				-- 使用连锁素材提供的素材池再次检查是否存在可融合召唤的融合怪兽，作为普通素材不足时的备选。
				res=Duel.IsExistingMatchingCard(c35705817.filter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg3,mf,chkf)
			end
		end
		return res
	end
	-- 设置操作信息：本效果将把1只额外卡组怪兽特殊召唤（融合召唤），供相关卡进行效果检测。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- 效果处理：进行融合召唤，先选择要融合召唤的怪兽，再选择素材；场上素材送墓，手卡/卡组/墓地素材除外，最后融合召唤。
function c35705817.activate(e,tp,eg,ep,ev,re,r,rp)
	local chkf=tp
	-- 效果处理时重新获取通常素材池，并过滤出场上、不免疫效果的不死族怪兽。
	local mg1=Duel.GetFusionMaterial(tp):Filter(c35705817.filter1,nil,e)
	local exmat=false
	local mg2=Group.CreateGroup()
	-- 效果处理时再次判断LP是否低于对方，以决定是否使用追加素材。
	if Duel.GetLP(tp)<Duel.GetLP(1-tp) then
		-- LP较低时，从手卡·卡组·墓地检索可除外的不死族怪兽加入素材池。
		mg2=Duel.GetMatchingGroup(c35705817.filter0,tp,LOCATION_DECK+LOCATION_HAND+LOCATION_GRAVE,0,nil)
	end
	if mg2:GetCount()>0 then
		mg1:Merge(mg2)
		exmat=true
	end
	if exmat then
		-- 在效果处理的选择素材阶段设置额外素材数量限制。
		aux.FCheckAdditional=c35705817.fcheck
		-- 在效果处理的选择素材阶段设置素材组数量限制。
		aux.GCheckAdditional=c35705817.gcheck
	end
	-- 筛选出使用当前素材池能够融合召唤的额外卡组怪兽候选。
	local sg1=Duel.GetMatchingGroup(c35705817.filter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg1,nil,chkf)
	-- 清除素材数量限制函数。
	aux.FCheckAdditional=nil
	-- 清除素材组限制函数。
	aux.GCheckAdditional=nil
	local mg3=nil
	local sg2=nil
	-- 获取连锁素材效果，用于决定是否可走连锁素材的融合召唤流程。
	local ce=Duel.GetChainMaterial(tp)
	if ce~=nil then
		local fgroup=ce:GetTarget()
		mg3=fgroup(ce,e,tp)
		local mf=ce:GetValue()
		-- 筛选出使用连锁素材效果提供的素材池能够融合召唤的额外卡组怪兽候选。
		sg2=Duel.GetMatchingGroup(c35705817.filter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg3,mf,chkf)
	end
	if sg1:GetCount()>0 or (sg2~=nil and sg2:GetCount()>0) then
		local sg=sg1:Clone()
		if sg2 then sg:Merge(sg2) end
		-- 提示玩家选择要特殊召唤的融合怪兽。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		local tg=sg:Select(tp,1,1,nil)
		local tc=tg:GetFirst()
		mg1:RemoveCard(tc)
		-- 判断选中的融合怪兽是否走本卡自己的素材处理流程：若该怪兽可用通常素材召唤，且不使用连锁素材（或玩家选择不用），则执行本卡流程；否则交予连锁素材效果处理。
		if sg1:IsContains(tc) and (sg2==nil or not sg2:IsContains(tc) or not Duel.SelectYesNo(tp,ce:GetDescription())) then
			if exmat then
				-- 执行本卡流程时，在最终选择融合素材前再次设置额外素材数量限制。
				aux.FCheckAdditional=c35705817.fcheck
				-- 执行本卡流程时，再次设置素材组数量限制。
				aux.GCheckAdditional=c35705817.gcheck
			end
			-- 让玩家从素材池中选择符合该融合怪兽要求的融合素材（自动应用额外限制）。
			local mat1=Duel.SelectFusionMaterial(tp,tc,mg1,nil,chkf)
			-- 选择完成后清除素材数量限制。
			aux.FCheckAdditional=nil
			-- 选择完成后清除素材组限制。
			aux.GCheckAdditional=nil
			tc:SetMaterial(mat1)
			local rg=mat1:Filter(Card.IsLocation,nil,LOCATION_ONFIELD)
			mat1:Sub(rg)
			-- 将选择的素材中位于场上的部分送去墓地，作为融合素材处理。
			Duel.SendtoGrave(rg,REASON_EFFECT+REASON_MATERIAL+REASON_FUSION)
			-- 将选择的素材中来自手卡·卡组·墓地的部分表侧除外，作为融合素材处理。
			Duel.Remove(mat1,POS_FACEUP,REASON_EFFECT+REASON_MATERIAL+REASON_FUSION)
			-- 中断当前效果处理，使素材处理和特殊召唤不同时处理，保证融合召唤自己的时点。
			Duel.BreakEffect()
			-- 将选定的融合怪兽以融合召唤方式表侧表示特殊召唤到发动者场上。
			Duel.SpecialSummon(tc,SUMMON_TYPE_FUSION,tp,tp,false,false,POS_FACEUP)
		else
			-- 当使用连锁素材效果进行融合召唤时，从连锁素材提供的素材池中选择融合素材。
			local mat2=Duel.SelectFusionMaterial(tp,tc,mg3,nil,chkf)
			local fop=ce:GetOperation()
			fop(ce,e,tp,tc,mat2)
		end
		tc:CompleteProcedure()
	end
end
