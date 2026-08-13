--ナチュルの春風
-- 效果：
-- ①：可以从以下效果选择1个发动。
-- ●从自己的手卡·墓地选1只「自然」怪兽特殊召唤。
-- ●用包含「自然」怪兽的自己场上的怪兽为素材作同调召唤。
-- ●从自己场上把融合怪兽卡决定的包含「自然」怪兽的融合素材怪兽送去墓地，把那1只融合怪兽从额外卡组融合召唤。
function c34813545.initial_effect(c)
	-- ①：可以从以下效果选择1个发动。●从自己的手卡·墓地选1只「自然」怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(34813545,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c34813545.sptg)
	e1:SetOperation(c34813545.spop)
	c:RegisterEffect(e1)
	-- ●用包含「自然」怪兽的自己场上的怪兽为素材作同调召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(34813545,1))  --"同调召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_ACTIVATE)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetTarget(c34813545.sctg)
	e2:SetOperation(c34813545.scop)
	c:RegisterEffect(e2)
	-- ●从自己场上把融合怪兽卡决定的包含「自然」怪兽的融合素材怪兽送去墓地，把那1只融合怪兽从额外卡组融合召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(34813545,2))  --"融合召唤"
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON)
	e3:SetType(EFFECT_TYPE_ACTIVATE)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetTarget(c34813545.fstg)
	e3:SetOperation(c34813545.fsop)
	c:RegisterEffect(e3)
end
-- 过滤器：判定怪兽是否属于「自然」系列且能被当前效果特殊召唤（符合召唤条件与苏生限制）。
function c34813545.spfilter(c,e,tp)
	return c:IsSetCard(0x2a) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 特殊召唤效果的发动条件：自己主要怪兽区有空位，且手卡·墓地存在至少1只可特殊召唤的「自然」怪兽。
function c34813545.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有空余的主要怪兽区。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查手卡·墓地是否存在至少1只符合条件的「自然」怪兽。
		and Duel.IsExistingMatchingCard(c34813545.spfilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 向对方玩家提示本效果发动的具体选项（特殊召唤）。
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
	-- 设置效果的预估操作信息：将从手卡·墓地特殊召唤1只怪兽。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_GRAVE)
end
-- 效果处理时，在自己的手卡·墓地中选择1只不受王家长眠之谷影响的、可特殊召唤的「自然」怪兽，以表侧表示特殊召唤到场上。
function c34813545.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 处理时若自己场上没有可用的主要怪兽区，则本次特殊召唤效果不适用。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 弹出提示，要求玩家选择要特殊召唤的怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从手卡·墓地中选择1只符合条件的「自然」怪兽（墓地侧会额外排除受王家长眠之谷影响的卡）。
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c34813545.spfilter),tp,LOCATION_HAND+LOCATION_GRAVE,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选择的怪兽以表侧表示特殊召唤到自己的主要怪兽区。
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 过滤器：判断卡片是否属于「自然」系列且为怪兽卡。
function c34813545.mfilter(c)
	return c:IsSetCard(0x2a) and c:IsType(TYPE_MONSTER)
end
-- 同调素材组检查：素材组必须包含至少1只「自然」怪兽，且满足手牌同调规则和同调怪兽的素材等级要求。
function c34813545.syncheck(g,tp,syncard)
	-- 同调素材组满足：含有「自然」怪兽、可通过手牌同调规则进行同调召唤、且该同调怪兽能用这组素材进行同调召唤。
	return g:IsExists(c34813545.mfilter,1,nil) and aux.SynMixHandCheck(g,tp,syncard) and syncard:IsSynchroSummonable(nil,g,#g-1,#g-1)
end
-- 额外卡组的同调怪兽筛选：该怪兽必须是同调怪兽，并且存在至少一组满足条件的同调素材（素材组含「自然」怪兽且等级合法）。
function c34813545.scfilter(c,tp,mg)
	if not c:IsType(TYPE_SYNCHRO) then return false end
	-- 设置额外的同调素材检查函数，用于按目标同调怪兽校验素材组的等级之和。
	aux.GCheckAdditional=aux.SynGroupCheckLevelAddition(c)
	local res=mg:CheckSubGroup(c34813545.syncheck,2,#mg,tp,c)
	-- 清除临时设置的同调素材检查函数，避免影响其他效果。
	aux.GCheckAdditional=nil
	return res
end
-- 同调召唤效果的发动条件：玩家可以进行特殊召唤，场上（必要时加上手牌的调整）存在可组成的同调素材，且额外卡组有可同调召唤的同调怪兽。
function c34813545.sctg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		-- 若玩家当前不能进行特殊召唤，则不能发动该效果。
		if not Duel.IsPlayerCanSpecialSummon(tp) then return false end
		-- 取得玩家可用的同调素材组（包含场上可作同调素材的怪兽，以及受特殊效果影响的素材）。
		local mg=Duel.GetSynchroMaterial(tp)
		if mg:IsExists(Card.GetHandSynchro,1,nil) then
			-- 获取玩家手牌中的所有怪兽，用于在手牌同调可用时扩展素材组。
			local mg2=Duel.GetMatchingGroup(nil,tp,LOCATION_HAND,0,nil)
			if mg2:GetCount()>0 then mg:Merge(mg2) end
		end
		-- 检查额外卡组是否存在至少1只可用当前素材组进行同调召唤的同调怪兽。
		return Duel.IsExistingMatchingCard(c34813545.scfilter,tp,LOCATION_EXTRA,0,1,nil,tp,mg)
	end
	-- 向对方玩家提示本效果发动的是“同调召唤”选项。
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
	-- 设置效果的预估操作信息：将从额外卡组特殊召唤1只同调怪兽。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- 同调召唤效果处理：重新取得同调素材（必要时加入手牌），筛选可同调召唤的同调怪兽，由玩家选择怪兽并选择素材组，进行同调召唤。
function c34813545.scop(e,tp,eg,ep,ev,re,r,rp)
	-- 重新取得玩家当前可用的同调素材组。
	local mg=Duel.GetSynchroMaterial(tp)
	if mg:IsExists(Card.GetHandSynchro,1,nil) then
		-- 获取手牌中的所有怪兽，用于手牌同调。
		local mg2=Duel.GetMatchingGroup(nil,tp,LOCATION_HAND,0,nil)
		if mg2:GetCount()>0 then mg:Merge(mg2) end
	end
	-- 筛选额外卡组中所有能用当前素材组进行同调召唤的同调怪兽。
	local g=Duel.GetMatchingGroup(c34813545.scfilter,tp,LOCATION_EXTRA,0,nil,tp,mg)
	if g:GetCount()>0 then
		-- 提示玩家选择要同调召唤的怪兽。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		local sg=g:Select(tp,1,1,nil)
		local sc=sg:GetFirst()
		-- 提示玩家选择要作为同调素材的怪兽。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SMATERIAL)  --"请选择要作为同调素材的卡"
		local tg=mg:SelectSubGroup(tp,c34813545.syncheck,false,2,#mg,tp,sc)
		-- 将选择的素材组作为素材，以同调召唤的方式特殊召唤所选择的同调怪兽。
		Duel.SynchroSummon(tp,sc,nil,tg,#tg-1,#tg-1)
	end
end
-- 过滤器：排除对当前效果具有免疫能力的卡片（不能被本效果作为融合素材）。
function c34813545.filter1(c,e)
	return not c:IsImmuneToEffect(e)
end
-- 筛选额外卡组中可作为融合召唤对象的融合怪兽：必须为融合怪兽、满足素材条件、且能被当前效果以融合召唤方式特殊召唤。
function c34813545.filter2(c,e,tp,m,f,chkf)
	return c:IsType(TYPE_FUSION) and (not f or f(c))
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_FUSION,tp,false,false) and c:CheckFusionMaterial(m,nil,chkf)
end
-- 额外的融合素材检查：所选融合素材组中必须包含至少1只「自然」怪兽。
function c34813545.fcheck(tp,sg,fc)
	return sg:IsExists(Card.IsFusionSetCard,1,nil,0x2a)
end
-- 融合召唤效果的发动条件：自己场上存在可作为融合素材的「自然」怪兽，且额外卡组中有对应可融合召唤的融合怪兽；若存在连锁素材等替代素材效果，也一并检查。
function c34813545.fstg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local chkf=tp
		-- 取得玩家可用的融合素材，并仅保留场上的部分（符合效果‘从自己场上’的限制）。
		local mg1=Duel.GetFusionMaterial(tp):Filter(Card.IsLocation,nil,LOCATION_ONFIELD)
		-- 设置额外的融合素材检查函数，要求素材组必须包含「自然」怪兽。
		aux.FCheckAdditional=c34813545.fcheck
		-- 检查额外卡组是否存在至少1只融合怪兽，能与当前场上的素材组合合法地进行融合召唤。
		local res=Duel.IsExistingMatchingCard(c34813545.filter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg1,nil,chkf)
		-- 清除临时设置的融合素材检查函数。
		aux.FCheckAdditional=nil
		if not res then
			-- 获取当前玩家受到的‘连锁素材’等可替代融合素材的效果。
			local ce=Duel.GetChainMaterial(tp)
			if ce~=nil then
				local fgroup=ce:GetTarget()
				local mg2=fgroup(ce,e,tp)
				local mf=ce:GetValue()
				-- 若存在连锁素材等效果，检查额外卡组是否存在能用这些替代素材融合召唤的融合怪兽。
				res=Duel.IsExistingMatchingCard(c34813545.filter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg2,mf,chkf)
			end
		end
		return res
	end
	-- 向对方玩家提示本效果发动的是“融合召唤”选项。
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
	-- 设置效果的预估操作信息：将从额外卡组进行1只融合怪兽的融合召唤。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- 融合召唤效果处理：确定场上可用的融合素材以及替代素材，选择要融合召唤的融合怪兽，将决定的「自然」素材送入墓地，并以融合召唤方式特殊召唤该怪兽。
function c34813545.fsop(e,tp,eg,ep,ev,re,r,rp)
	local chkf=tp
	-- 处理时重新取得场上可用的融合素材，并排除对当前效果免疫的卡。
	local mg1=Duel.GetFusionMaterial(tp):Filter(Card.IsLocation,nil,LOCATION_ONFIELD):Filter(c34813545.filter1,nil,e)
	-- 设置融合素材组必须包含「自然」怪兽的额外检查。
	aux.FCheckAdditional=c34813545.fcheck
	-- 筛选额外卡组中所有能以场上素材进行融合召唤的融合怪兽。
	local sg1=Duel.GetMatchingGroup(c34813545.filter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg1,nil,chkf)
	-- 清除临时设置的融合素材检查函数。
	aux.FCheckAdditional=nil
	local mg2=nil
	local sg2=nil
	-- 获取连锁素材等替代融合素材效果。
	local ce=Duel.GetChainMaterial(tp)
	if ce~=nil then
		local fgroup=ce:GetTarget()
		mg2=fgroup(ce,e,tp)
		local mf=ce:GetValue()
		-- 使用替代素材效果筛选额外卡组中可融合召唤的融合怪兽。
		sg2=Duel.GetMatchingGroup(c34813545.filter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg2,mf,chkf)
	end
	if sg1:GetCount()>0 or (sg2~=nil and sg2:GetCount()>0) then
		local sg=sg1:Clone()
		if sg2 then sg:Merge(sg2) end
		-- 提示玩家选择要融合召唤的怪兽。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		local tg=sg:Select(tp,1,1,nil)
		local tc=tg:GetFirst()
		-- 如果所选怪兽可以用场上素材融合，且没有替代素材或玩家选择不使用替代素材，则执行通常的融合召唤。
		if sg1:IsContains(tc) and (sg2==nil or not sg2:IsContains(tc) or not Duel.SelectYesNo(tp,ce:GetDescription())) then
			-- 设置融合素材组必须包含「自然」怪兽的额外检查，用于选择常规素材。
			aux.FCheckAdditional=c34813545.fcheck
			-- 从场上选择一组符合融合怪兽要求且包含「自然」怪兽的融合素材。
			local mat1=Duel.SelectFusionMaterial(tp,tc,mg1,nil,chkf)
			-- 清除临时设置的融合素材检查函数。
			aux.FCheckAdditional=nil
			tc:SetMaterial(mat1)
			-- 将选择的融合素材怪兽送入墓地（作为融合素材，原因是效果、素材、融合）。
			Duel.SendtoGrave(mat1,REASON_EFFECT+REASON_MATERIAL+REASON_FUSION)
			-- 中断当前效果链，使后续特殊召唤作为另一次处理，避免错过时点。
			Duel.BreakEffect()
			-- 将融合怪兽以融合召唤方式表侧表示特殊召唤到场上。
			Duel.SpecialSummon(tc,SUMMON_TYPE_FUSION,tp,tp,false,false,POS_FACEUP)
		else
			-- 从替代素材组中选择一组融合素材（用于连锁素材等效果）。
			local mat2=Duel.SelectFusionMaterial(tp,tc,mg2,nil,chkf)
			local fop=ce:GetOperation()
			fop(ce,e,tp,tc,mat2)
		end
		tc:CompleteProcedure()
	end
end
