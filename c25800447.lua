--フュージョン・オブ・ファイア
-- 效果：
-- 这个卡名在规则上也当作「转生炎兽」卡使用。这个卡名的卡在1回合只能发动1张。
-- ①：从自己手卡以及自己·对方场上把「转生炎兽」融合怪兽卡决定的融合素材怪兽送去墓地，把那1只融合怪兽从额外卡组融合召唤。
function c25800447.initial_effect(c)
	-- 这个卡名在规则上也当作「转生炎兽」卡使用。这个卡名的卡在1回合只能发动1张。①：从自己手卡以及自己·对方场上把「转生炎兽」融合怪兽卡决定的融合素材怪兽送去墓地，把那1只融合怪兽从额外卡组融合召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,25800447+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(c25800447.target)
	e1:SetOperation(c25800447.activate)
	c:RegisterEffect(e1)
end
-- 筛选表侧表示且可作为融合素材的怪兽，用于在发动时获取对方场上可能的融合素材。
function c25800447.filter0(c)
	return c:IsFaceup() and c:IsCanBeFusionMaterial()
end
-- 筛选表侧表示、可作为融合素材且不免疫此效果的怪兽，用于效果处理时从对方场上选取真正能送去墓地的素材。
function c25800447.filter1(c,e)
	return c:IsFaceup() and c:IsCanBeFusionMaterial() and not c:IsImmuneToEffect(e)
end
-- 筛选额外卡组中的「转生炎兽」融合怪兽：必须是融合怪兽、属于「转生炎兽」字段、可被当前效果融合召唤，并且能用现有素材组（m，可能包含替代素材）满足其融合素材要求。
function c25800447.filter2(c,e,tp,m,f,chkf)
	return c:IsType(TYPE_FUSION) and c:IsSetCard(0x119) and (not f or f(c))
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_FUSION,tp,false,false) and c:CheckFusionMaterial(m,nil,chkf)
end
-- 筛选不免疫当前效果的卡，用于从基础融合素材组中剔除不能受此效果影响的卡。
function c25800447.filter3(c,e)
	return not c:IsImmuneToEffect(e)
end
-- 发动判定：检查能否从自己手卡以及自己·对方场上（或连锁素材提供的额外素材）凑齐融合素材，并存在可融合召唤的「转生炎兽」融合怪兽；若可以，设置本次操作将融合召唤1只额外卡组怪兽。
function c25800447.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local chkf=tp
		-- 获取玩家tp当前可用于融合召唤的基础素材组（通常含手卡及己方场上怪兽，以及额外融合素材效果提供的位置）。
		local mg1=Duel.GetFusionMaterial(tp)
		-- 获取对方场上表侧表示且可作为融合素材的怪兽，补充为可用的融合素材。
		local mg2=Duel.GetMatchingGroup(c25800447.filter0,tp,0,LOCATION_MZONE,nil)
		mg1:Merge(mg2)
		-- 检查额外卡组是否存在「转生炎兽」融合怪兽，能够以当前合并后的素材组（mg1）为素材并被融合召唤。
		local res=Duel.IsExistingMatchingCard(c25800447.filter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg1,nil,chkf)
		if not res then
			-- 获取当前玩家可用的连锁素材效果（如其他卡赋予的额外融合素材），用于在普通素材不足时追加素材来源。
			local ce=Duel.GetChainMaterial(tp)
			if ce~=nil then
				local fgroup=ce:GetTarget()
				local mg3=fgroup(ce,e,tp)
				local mf=ce:GetValue()
				-- 在使用连锁素材提供的素材（mg3及特殊素材条件mf）后，再次检查额外卡组是否存在可融合召唤的「转生炎兽」融合怪兽。
				res=Duel.IsExistingMatchingCard(c25800447.filter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg3,mf,chkf)
			end
		end
		return res
	end
	-- 设置发动时的操作信息：本次效果将进行1只额外卡组怪兽的特殊召唤（融合召唤），供其他卡进行效果检测。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- 效果处理：收集真正可用的融合素材，选择要融合召唤的「转生炎兽」融合怪兽，选择素材并送去墓地，然后进行融合召唤；若选用连锁素材，则按连锁素材效果进行融合。
function c25800447.activate(e,tp,eg,ep,ev,re,r,rp)
	local chkf=tp
	-- 处理时获取基础可用素材组，并排除免疫此效果的卡，得到真正能送去墓地的融合素材。
	local mg1=Duel.GetFusionMaterial(tp):Filter(c25800447.filter3,nil,e)
	-- 处理时获取对方场上表侧表示、可作为融合素材且不免疫此效果的怪兽，并入素材组。
	local mg2=Duel.GetMatchingGroup(c25800447.filter1,tp,0,LOCATION_MZONE,nil,e)
	mg1:Merge(mg2)
	-- 从额外卡组筛选出所有能用当前素材组（mg1）融合召唤的「转生炎兽」融合怪兽，作为候选对象。
	local sg1=Duel.GetMatchingGroup(c25800447.filter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg1,nil,chkf)
	local mg3=nil
	local sg2=nil
	-- 处理时再次获取连锁素材效果，以支持使用额外素材进行融合召唤。
	local ce=Duel.GetChainMaterial(tp)
	if ce~=nil then
		local fgroup=ce:GetTarget()
		mg3=fgroup(ce,e,tp)
		local mf=ce:GetValue()
		-- 根据连锁素材提供的素材组（mg3）及素材条件，筛选出可融合召唤的「转生炎兽」融合怪兽，并入候选组。
		sg2=Duel.GetMatchingGroup(c25800447.filter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg3,mf,chkf)
	end
	if sg1:GetCount()>0 or (sg2~=nil and sg2:GetCount()>0) then
		local sg=sg1:Clone()
		if sg2 then sg:Merge(sg2) end
		-- 向玩家显示提示“请选择要特殊召唤的卡”，用于接下来选择要融合召唤的怪兽。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		local tg=sg:Select(tp,1,1,nil)
		local tc=tg:GetFirst()
		-- 判断所选融合怪兽是否属于普通素材可召唤组，且（若也在连锁素材组中时）玩家未选择使用连锁素材方式；若满足则执行普通融合召唤，否则执行连锁素材融合。
		if sg1:IsContains(tc) and (sg2==nil or not sg2:IsContains(tc) or not Duel.SelectYesNo(tp,ce:GetDescription())) then
			-- 让玩家从普通可用素材组中为所选融合怪兽选择一组融合素材。
			local mat1=Duel.SelectFusionMaterial(tp,tc,mg1,nil,chkf)
			tc:SetMaterial(mat1)
			-- 将选中的融合素材怪兽送去墓地，原因记录为效果、作为融合素材、用于融合召唤。
			Duel.SendtoGrave(mat1,REASON_EFFECT+REASON_MATERIAL+REASON_FUSION)
			-- 中断当前效果处理，使后续融合召唤作为独立时点，避免触发错误的时点。
			Duel.BreakEffect()
			-- 将所选融合怪兽以融合召唤方式表侧攻击表示特殊召唤到己方场上。
			Duel.SpecialSummon(tc,SUMMON_TYPE_FUSION,tp,tp,false,false,POS_FACEUP)
		else
			-- 当使用连锁素材效果时，让玩家从连锁素材提供的素材组中为所选融合怪兽选择一组融合素材。
			local mat2=Duel.SelectFusionMaterial(tp,tc,mg3,nil,chkf)
			local fop=ce:GetOperation()
			fop(ce,e,tp,tc,mat2)
		end
		tc:CompleteProcedure()
	end
end
