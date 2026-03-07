--ナチュルの春風
-- 效果：
-- ①：可以从以下效果选择1个发动。
-- ●从自己的手卡·墓地选1只「自然」怪兽特殊召唤。
-- ●用包含「自然」怪兽的自己场上的怪兽为素材作同调召唤。
-- ●从自己场上把融合怪兽卡决定的包含「自然」怪兽的融合素材怪兽送去墓地，把那1只融合怪兽从额外卡组融合召唤。
function c34813545.initial_effect(c)
	-- 效果原文内容：●从自己的手卡·墓地选1只「自然」怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(34813545,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c34813545.sptg)
	e1:SetOperation(c34813545.spop)
	c:RegisterEffect(e1)
	-- 效果原文内容：●用包含「自然」怪兽的自己场上的怪兽为素材作同调召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(34813545,1))  --"同调召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_ACTIVATE)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetTarget(c34813545.sctg)
	e2:SetOperation(c34813545.scop)
	c:RegisterEffect(e2)
	-- 效果原文内容：●从自己场上把融合怪兽卡决定的包含「自然」怪兽的融合素材怪兽送去墓地，把那1只融合怪兽从额外卡组融合召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(34813545,2))  --"融合召唤"
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON)
	e3:SetType(EFFECT_TYPE_ACTIVATE)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetTarget(c34813545.fstg)
	e3:SetOperation(c34813545.fsop)
	c:RegisterEffect(e3)
end
-- 检索满足条件的「自然」怪兽，用于特殊召唤。
function c34813545.spfilter(c,e,tp)
	return c:IsSetCard(0x2a) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 判断是否满足特殊召唤效果的发动条件。
function c34813545.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断玩家场上是否有足够的怪兽区域。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 判断玩家手卡或墓地是否存在满足条件的「自然」怪兽。
		and Duel.IsExistingMatchingCard(c34813545.spfilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 向对方玩家提示发动了特殊召唤效果。
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
	-- 设置效果处理时要特殊召唤的卡的信息。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_GRAVE)
end
-- 执行特殊召唤效果的处理。
function c34813545.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 判断玩家场上是否有足够的怪兽区域。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择满足条件的「自然」怪兽。
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c34813545.spfilter),tp,LOCATION_HAND+LOCATION_GRAVE,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的「自然」怪兽特殊召唤。
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 检索满足条件的「自然」怪兽，用于同调召唤。
function c34813545.mfilter(c)
	return c:IsSetCard(0x2a) and c:IsType(TYPE_MONSTER)
end
-- 判断同调召唤素材是否满足条件。
function c34813545.syncheck(g,tp,syncard)
	-- 判断同调召唤素材是否包含「自然」怪兽、是否满足手卡同调限制、是否满足目标怪兽的同调召唤条件。
	return g:IsExists(c34813545.mfilter,1,nil) and aux.SynMixHandCheck(g,tp,syncard) and syncard:IsSynchroSummonable(nil,g,#g-1,#g-1)
end
-- 判断满足条件的同调怪兽是否存在。
function c34813545.scfilter(c,tp,mg)
	if not c:IsType(TYPE_SYNCHRO) then return false end
	-- 设置同调召唤时的等级加成检查。
	aux.GCheckAdditional=aux.SynGroupCheckLevelAddition(c)
	local res=mg:CheckSubGroup(c34813545.syncheck,2,#mg,tp,c)
	-- 清除同调召唤时的等级加成检查。
	aux.GCheckAdditional=nil
	return res
end
-- 判断是否满足同调召唤效果的发动条件。
function c34813545.sctg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		-- 判断玩家是否可以特殊召唤。
		if not Duel.IsPlayerCanSpecialSummon(tp) then return false end
		-- 获取玩家可用的同调素材。
		local mg=Duel.GetSynchroMaterial(tp)
		if mg:IsExists(Card.GetHandSynchro,1,nil) then
			-- 获取玩家手卡中的怪兽。
			local mg2=Duel.GetMatchingGroup(nil,tp,LOCATION_HAND,0,nil)
			if mg2:GetCount()>0 then mg:Merge(mg2) end
		end
		-- 判断是否存在满足条件的同调怪兽。
		return Duel.IsExistingMatchingCard(c34813545.scfilter,tp,LOCATION_EXTRA,0,1,nil,tp,mg)
	end
	-- 向对方玩家提示发动了同调召唤效果。
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
	-- 设置效果处理时要特殊召唤的卡的信息。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- 执行同调召唤效果的处理。
function c34813545.scop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取玩家可用的同调素材。
	local mg=Duel.GetSynchroMaterial(tp)
	if mg:IsExists(Card.GetHandSynchro,1,nil) then
		-- 获取玩家手卡中的怪兽。
		local mg2=Duel.GetMatchingGroup(nil,tp,LOCATION_HAND,0,nil)
		if mg2:GetCount()>0 then mg:Merge(mg2) end
	end
	-- 检索满足条件的同调怪兽。
	local g=Duel.GetMatchingGroup(c34813545.scfilter,tp,LOCATION_EXTRA,0,nil,tp,mg)
	if g:GetCount()>0 then
		-- 提示玩家选择要特殊召唤的卡。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		local sg=g:Select(tp,1,1,nil)
		local sc=sg:GetFirst()
		-- 提示玩家选择要作为同调素材的卡。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SMATERIAL)  --"请选择要作为同调素材的卡"
		local tg=mg:SelectSubGroup(tp,c34813545.syncheck,false,2,#mg,tp,sc)
		-- 执行同调召唤。
		Duel.SynchroSummon(tp,sc,nil,tg,#tg-1,#tg-1)
	end
end
-- 过滤不受王家长眠之谷影响的卡。
function c34813545.filter1(c,e)
	return not c:IsImmuneToEffect(e)
end
-- 过滤满足条件的融合怪兽。
function c34813545.filter2(c,e,tp,m,f,chkf)
	return c:IsType(TYPE_FUSION) and (not f or f(c))
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_FUSION,tp,false,false) and c:CheckFusionMaterial(m,nil,chkf)
end
-- 判断融合素材是否包含「自然」怪兽。
function c34813545.fcheck(tp,sg,fc)
	return sg:IsExists(Card.IsFusionSetCard,1,nil,0x2a)
end
-- 判断是否满足融合召唤效果的发动条件。
function c34813545.fstg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local chkf=tp
		-- 获取玩家场上的融合素材。
		local mg1=Duel.GetFusionMaterial(tp):Filter(Card.IsLocation,nil,LOCATION_ONFIELD)
		-- 设置融合召唤时的额外检查。
		aux.FCheckAdditional=c34813545.fcheck
		-- 判断是否存在满足条件的融合怪兽。
		local res=Duel.IsExistingMatchingCard(c34813545.filter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg1,nil,chkf)
		-- 清除融合召唤时的额外检查。
		aux.FCheckAdditional=nil
		if not res then
			-- 获取当前连锁的融合素材效果。
			local ce=Duel.GetChainMaterial(tp)
			if ce~=nil then
				local fgroup=ce:GetTarget()
				local mg2=fgroup(ce,e,tp)
				local mf=ce:GetValue()
				-- 判断是否存在满足条件的融合怪兽。
				res=Duel.IsExistingMatchingCard(c34813545.filter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg2,mf,chkf)
			end
		end
		return res
	end
	-- 向对方玩家提示发动了融合召唤效果。
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
	-- 设置效果处理时要特殊召唤的卡的信息。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- 执行融合召唤效果的处理。
function c34813545.fsop(e,tp,eg,ep,ev,re,r,rp)
	local chkf=tp
	-- 获取玩家场上的融合素材并过滤不受王家长眠之谷影响的卡。
	local mg1=Duel.GetFusionMaterial(tp):Filter(Card.IsLocation,nil,LOCATION_ONFIELD):Filter(c34813545.filter1,nil,e)
	-- 设置融合召唤时的额外检查。
	aux.FCheckAdditional=c34813545.fcheck
	-- 检索满足条件的融合怪兽。
	local sg1=Duel.GetMatchingGroup(c34813545.filter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg1,nil,chkf)
	-- 清除融合召唤时的额外检查。
	aux.FCheckAdditional=nil
	local mg2=nil
	local sg2=nil
	-- 获取当前连锁的融合素材效果。
	local ce=Duel.GetChainMaterial(tp)
	if ce~=nil then
		local fgroup=ce:GetTarget()
		mg2=fgroup(ce,e,tp)
		local mf=ce:GetValue()
		-- 检索满足条件的融合怪兽。
		sg2=Duel.GetMatchingGroup(c34813545.filter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg2,mf,chkf)
	end
	if sg1:GetCount()>0 or (sg2~=nil and sg2:GetCount()>0) then
		local sg=sg1:Clone()
		if sg2 then sg:Merge(sg2) end
		-- 提示玩家选择要特殊召唤的卡。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		local tg=sg:Select(tp,1,1,nil)
		local tc=tg:GetFirst()
		-- 判断是否使用原融合素材效果。
		if sg1:IsContains(tc) and (sg2==nil or not sg2:IsContains(tc) or not Duel.SelectYesNo(tp,ce:GetDescription())) then
			-- 设置融合召唤时的额外检查。
			aux.FCheckAdditional=c34813545.fcheck
			-- 选择融合素材。
			local mat1=Duel.SelectFusionMaterial(tp,tc,mg1,nil,chkf)
			-- 清除融合召唤时的额外检查。
			aux.FCheckAdditional=nil
			tc:SetMaterial(mat1)
			-- 将融合素材送去墓地。
			Duel.SendtoGrave(mat1,REASON_EFFECT+REASON_MATERIAL+REASON_FUSION)
			-- 中断当前效果。
			Duel.BreakEffect()
			-- 将融合怪兽特殊召唤。
			Duel.SpecialSummon(tc,SUMMON_TYPE_FUSION,tp,tp,false,false,POS_FACEUP)
		else
			-- 选择融合素材。
			local mat2=Duel.SelectFusionMaterial(tp,tc,mg2,nil,chkf)
			local fop=ce:GetOperation()
			fop(ce,e,tp,tc,mat2)
		end
		tc:CompleteProcedure()
	end
end
