--古代の機械融合
-- 效果：
-- ①：自己的手卡·场上的怪兽作为融合素材，把1只「古代的机械」融合怪兽融合召唤。把自己场上的「古代的机械巨人」或「古代的机械巨人-究极重击」作为融合素材的场合，自己卡组的怪兽也能作为融合素材。
function c64061284.initial_effect(c)
	-- 注册本卡效果中记载了「古代的机械巨人」的卡片密码。
	aux.AddCodeList(c,83104731)
	-- ①：自己的手卡·场上的怪兽作为融合素材，把1只「古代的机械」融合怪兽融合召唤。把自己场上的「古代的机械巨人」或「古代的机械巨人-究极重击」作为融合素材的场合，自己卡组的怪兽也能作为融合素材。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON+CATEGORY_DECKDES)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c64061284.target)
	e1:SetOperation(c64061284.activate)
	c:RegisterEffect(e1)
end
-- 融合素材检查函数：若融合素材中包含卡组的怪兽，则必须包含场上的「古代的机械巨人」或「古代的机械巨人-究极重击」。
function c64061284.fcheck(tp,sg,fc)
	if sg:IsExists(Card.IsLocation,1,nil,LOCATION_DECK) then
		return sg:IsExists(c64061284.filterchk,1,nil) end
	return true
end
-- 过滤场上的「古代的机械巨人」或「古代的机械巨人-究极重击」。
function c64061284.filterchk(c)
	return c:IsCode(83104731,95735217) and c:IsOnField()
end
-- 过滤卡组中可以作为融合素材送去墓地的怪兽。
function c64061284.filter0(c)
	return c:IsType(TYPE_MONSTER) and c:IsCanBeFusionMaterial() and c:IsAbleToGrave()
end
-- 过滤不受当前效果影响的怪兽。
function c64061284.filter1(c,e)
	return not c:IsImmuneToEffect(e)
end
-- 过滤额外卡组中可以融合召唤的「古代的机械」融合怪兽。
function c64061284.filter2(c,e,tp,m,f,chkf)
	return c:IsType(TYPE_FUSION) and c:IsSetCard(0x7) and (not f or f(c))
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_FUSION,tp,false,false) and c:CheckFusionMaterial(m,nil,chkf)
end
-- 效果发动时的合法性检查（Target阶段）。
function c64061284.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local chkf=tp
		-- 获取玩家手卡和场上的可用融合素材。
		local mg=Duel.GetFusionMaterial(tp)
		-- 获取卡组中满足条件的可用融合素材。
		local mg2=Duel.GetMatchingGroup(c64061284.filter0,tp,LOCATION_DECK,0,nil)
		if mg:IsExists(c64061284.filterchk,1,nil) and mg2:GetCount()>0 then
			mg:Merge(mg2)
			-- 设置额外的融合素材检查函数，用于限制卡组融合的条件。
			aux.FCheckAdditional=c64061284.fcheck
		end
		-- 检查额外卡组是否存在可以使用当前素材进行融合召唤的「古代的机械」怪兽。
		local res=Duel.IsExistingMatchingCard(c64061284.filter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg,nil,chkf)
		-- 清空额外的融合素材检查函数。
		aux.FCheckAdditional=nil
		if not res then
			-- 检查是否存在连锁素材等卡片效果的影响。
			local ce=Duel.GetChainMaterial(tp)
			if ce~=nil then
				local fgroup=ce:GetTarget()
				local mg3=fgroup(ce,e,tp)
				local mf=ce:GetValue()
				-- 在连锁素材效果下，检查是否存在可以融合召唤的怪兽。
				res=Duel.IsExistingMatchingCard(c64061284.filter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg3,mf,chkf)
			end
		end
		return res
	end
end
-- 效果处理阶段（Operation阶段）。
function c64061284.activate(e,tp,eg,ep,ev,re,r,rp)
	local chkf=tp
	-- 获取手卡和场上不受此效果影响的可用融合素材。
	local mg1=Duel.GetFusionMaterial(tp):Filter(c64061284.filter1,nil,e)
	-- 获取卡组中可用的融合素材。
	local mg2=Duel.GetMatchingGroup(c64061284.filter0,tp,LOCATION_DECK,0,nil)
	if mg1:IsExists(c64061284.filterchk,1,nil) and mg2:GetCount()>0 then
		mg1:Merge(mg2)
		-- 设置额外的融合素材检查函数，用于限制卡组融合的条件。
		aux.FCheckAdditional=c64061284.fcheck
	end
	-- 获取额外卡组中可以使用当前素材融合召唤的怪兽。
	local sg1=Duel.GetMatchingGroup(c64061284.filter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg1,nil,chkf)
	-- 清空额外的融合素材检查函数。
	aux.FCheckAdditional=nil
	local mg2=nil
	local sg2=nil
	-- 检查是否存在连锁素材的效果。
	local ce=Duel.GetChainMaterial(tp)
	if ce~=nil then
		local fgroup=ce:GetTarget()
		mg2=fgroup(ce,e,tp)
		local mf=ce:GetValue()
		-- 获取在连锁素材效果下可以融合召唤的怪兽。
		sg2=Duel.GetMatchingGroup(c64061284.filter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg2,mf,chkf)
	end
	local sg=sg1:Clone()
	if sg2 then sg:Merge(sg2) end
	-- 提示玩家选择要特殊召唤的怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	local tg=sg:Select(tp,1,1,nil)
	local tc=tg:GetFirst()
	if not tc then return end
	-- 判断是否使用本卡自身的效果进行融合召唤（而非连锁素材的效果）。
	if sg1:IsContains(tc) and (sg2==nil or not sg2:IsContains(tc) or not Duel.SelectYesNo(tp,ce:GetDescription())) then
		-- 设置额外的融合素材检查函数，用于限制卡组融合的条件。
		aux.FCheckAdditional=c64061284.fcheck
		-- 让玩家选择融合素材。
		local mat1=Duel.SelectFusionMaterial(tp,tc,mg1,nil,chkf)
		-- 清空额外的融合素材检查函数。
		aux.FCheckAdditional=nil
		tc:SetMaterial(mat1)
		-- 将选中的融合素材送去墓地。
		Duel.SendtoGrave(mat1,REASON_EFFECT+REASON_MATERIAL+REASON_FUSION)
		-- 中断当前效果，使之后的特殊召唤处理与送去墓地不视为同时处理。
		Duel.BreakEffect()
		-- 将融合怪兽以表侧表示融合召唤。
		Duel.SpecialSummon(tc,SUMMON_TYPE_FUSION,tp,tp,false,false,POS_FACEUP)
	else
		-- 在连锁素材效果下，让玩家选择融合素材。
		local mat2=Duel.SelectFusionMaterial(tp,tc,mg2,nil,chkf)
		local fop=ce:GetOperation()
		fop(ce,e,tp,tc,mat2)
	end
	tc:CompleteProcedure()
end
