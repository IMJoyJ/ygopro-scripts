--重錬装融合
-- 效果：
-- ①：从自己的手卡·场上把「炼装」融合怪兽卡决定的融合素材怪兽送去墓地，把那1只融合怪兽从额外卡组融合召唤。
function c39564736.initial_effect(c)
	-- ①：从自己的手卡·场上把「炼装」融合怪兽卡决定的融合素材怪兽送去墓地，把那1只融合怪兽从额外卡组融合召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(39564736,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c39564736.target)
	e1:SetOperation(c39564736.activate)
	c:RegisterEffect(e1)
end
-- 过滤素材卡：排除对该融合效果免疫的怪兽，确保后续作为融合素材送墓的卡能够被此效果正常处理。
function c39564736.filter1(c,e)
	return not c:IsImmuneToEffect(e)
end
-- 检索额外卡组中可作为融合召唤对象的卡：必须是「炼装」融合怪兽，满足额外连锁素材条件（若有），能被以融合召唤方式特殊召唤，并且当前可用素材满足其融合素材要求。
function c39564736.filter2(c,e,tp,m,f,chkf)
	return c:IsType(TYPE_FUSION) and c:IsSetCard(0xe1) and (not f or f(c))
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_FUSION,tp,false,false) and c:CheckFusionMaterial(m,nil,chkf)
end
-- 发动时点判定：先以普通融合素材检查额外卡组是否存在符合条件的「炼装」融合怪兽；若无，再检查玩家可用的连锁素材（替代素材）效果，并用其素材组和条件再次检查；若存在可融合召唤对象则通过发动检查，并设置操作信息，声明将特殊召唤1只额外卡组怪兽。
function c39564736.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local chkf=tp
		-- 取得玩家当前可用的融合素材卡组（包含手卡·场上的怪兽以及受EFFECT_EXTRA_FUSION_MATERIAL影响的卡）。
		local mg1=Duel.GetFusionMaterial(tp)
		-- 检查额外卡组是否存在至少1只满足普通素材融合召唤条件的「炼装」融合怪兽。
		local res=Duel.IsExistingMatchingCard(c39564736.filter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg1,nil,chkf)
		if not res then
			-- 取得玩家可用的连锁素材（替代融合素材）效果，用于在普通素材不够时尝试以替代素材融合召唤。
			local ce=Duel.GetChainMaterial(tp)
			if ce~=nil then
				local fgroup=ce:GetTarget()
				local mg2=fgroup(ce,e,tp)
				local mf=ce:GetValue()
				-- 使用连锁素材提供的素材组和额外条件，再次检查额外卡组是否存在可融合召唤的「炼装」融合怪兽。
				res=Duel.IsExistingMatchingCard(c39564736.filter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg2,mf,chkf)
			end
		end
		return res
	end
	-- 设置本连锁的操作信息：效果处理时将把1只额外卡组怪兽特殊召唤（类别为特殊召唤/融合召唤），供暴走魔法阵等相关效果和时点检测。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- 效果处理阶段：分别取得普通素材路线和连锁素材路线下可融合召唤的「炼装」融合怪兽；若存在，让玩家选择要融合召唤的怪兽；若走普通素材流程，则选择素材、送墓并执行融合召唤；若走连锁素材流程，则选择素材并调用连锁素材效果的处理函数；最后完成融合召唤手续。
function c39564736.activate(e,tp,eg,ep,ev,re,r,rp)
	local chkf=tp
	-- 取得普通融合素材组，并过滤掉对该效果免疫的卡片，得到本次融合召唤实际可用的素材。
	local mg1=Duel.GetFusionMaterial(tp):Filter(c39564736.filter1,nil,e)
	-- 用普通素材组筛选出额外卡组中所有可融合召唤的「炼装」融合怪兽，作为玩家可选择的融合召唤对象。
	local sg1=Duel.GetMatchingGroup(c39564736.filter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg1,nil,chkf)
	local mg2=nil
	local sg2=nil
	-- 取得玩家可用的连锁素材（替代融合素材）效果，用于处理普通素材无法融合召唤的情况。
	local ce=Duel.GetChainMaterial(tp)
	if ce~=nil then
		local fgroup=ce:GetTarget()
		mg2=fgroup(ce,e,tp)
		local mf=ce:GetValue()
		-- 用连锁素材提供的素材组和条件筛选出额外卡组中可融合召唤的「炼装」融合怪兽，作为替代路线的可选对象。
		sg2=Duel.GetMatchingGroup(c39564736.filter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg2,mf,chkf)
	end
	if sg1:GetCount()>0 or (sg2~=nil and sg2:GetCount()>0) then
		local sg=sg1:Clone()
		if sg2 then sg:Merge(sg2) end
		-- 向玩家发送“请选择要特殊召唤的卡”的选择提示，为接下来的融合怪兽选择界面设置提示消息。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		local tg=sg:Select(tp,1,1,nil)
		local tc=tg:GetFirst()
		-- 判断玩家选择的融合怪兽是否可走普通素材流程：若该怪兽可用普通素材融合，且不能走连锁素材流程（或虽能走但玩家选择不使用连锁素材效果），则进入普通素材送墓融合召唤分支。
		if sg1:IsContains(tc) and (sg2==nil or not sg2:IsContains(tc) or not Duel.SelectYesNo(tp,ce:GetDescription())) then
			-- 让玩家从普通素材组中为选定的「炼装」融合怪兽选择一组满足融合素材要求的素材。
			local mat1=Duel.SelectFusionMaterial(tp,tc,mg1,nil,chkf)
			tc:SetMaterial(mat1)
			-- 将选择的融合素材怪兽送去墓地，送墓原因为效果处理且作为融合素材用于融合召唤。
			Duel.SendtoGrave(mat1,REASON_EFFECT+REASON_MATERIAL+REASON_FUSION)
			-- 中断当前效果处理，使素材送墓与后续特殊召唤视为不同时处理，避免因同时处理而错过诱发时点。
			Duel.BreakEffect()
			-- 将选定的融合怪兽以融合召唤方式表侧表示特殊召唤到对应玩家的场上，完成融合召唤。
			Duel.SpecialSummon(tc,SUMMON_TYPE_FUSION,tp,tp,false,false,POS_FACEUP)
		else
			-- 让玩家从连锁素材组中为选定的「炼装」融合怪兽选择一组满足其融合素材要求的素材，用于执行连锁素材的融合召唤处理。
			local mat2=Duel.SelectFusionMaterial(tp,tc,mg2,nil,chkf)
			local fop=ce:GetOperation()
			fop(ce,e,tp,tc,mat2)
		end
		tc:CompleteProcedure()
	end
end
