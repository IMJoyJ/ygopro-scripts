--オッドアイズ・フュージョン
-- 效果：
-- 「异色眼融合」在1回合只能发动1张。
-- ①：从自己的手卡·场上把龙族融合怪兽卡决定的融合素材怪兽送去墓地，把那1只融合怪兽从额外卡组融合召唤。对方场上有怪兽2只以上存在，自己场上没有怪兽存在的场合，自己的额外卡组的「异色眼」怪兽也能有最多2只作为融合素材。
function c48144509.initial_effect(c)
	-- 「异色眼融合」在1回合只能发动1张。①：从自己的手卡·场上把龙族融合怪兽卡决定的融合素材怪兽送去墓地，把那1只融合怪兽从额外卡组融合召唤。对方场上有怪兽2只以上存在，自己场上没有怪兽存在的场合，自己的额外卡组的「异色眼」怪兽也能有最多2只作为融合素材。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,48144509+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(c48144509.target)
	e1:SetOperation(c48144509.activate)
	c:RegisterEffect(e1)
end
-- 筛选可作为融合素材的怪兽：需要能送去墓地，且不受此效果影响。
function c48144509.filter1(c,e)
	return c:IsAbleToGrave() and not c:IsImmuneToEffect(e)
end
-- 从额外卡组中筛选可作为融合素材的「异色眼」怪兽，要求卡名含异色眼、可作为融合素材且能送去墓地。
function c48144509.exfilter0(c)
	return c:IsSetCard(0x99) and c:IsCanBeFusionMaterial() and c:IsAbleToGrave()
end
-- 效果处理时从额外卡组中筛选可作为融合素材且不免疫此效果的「异色眼」怪兽，要求能送去墓地且可作为融合素材。
function c48144509.exfilter1(c,e)
	return c:IsSetCard(0x99) and c:IsCanBeFusionMaterial() and c:IsAbleToGrave() and not c:IsImmuneToEffect(e)
end
-- 筛选可作为融合召唤目标的龙族融合怪兽：必须是龙族融合怪兽、能以给定素材组完成融合召唤且能被此效果特殊召唤。
function c48144509.filter2(c,e,tp,m,f,chkf)
	return c:IsType(TYPE_FUSION) and c:IsRace(RACE_DRAGON) and (not f or f(c))
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_FUSION,tp,false,false) and c:CheckFusionMaterial(m,nil,chkf)
end
-- 额外检查函数：限制选择的融合素材中来自额外卡组的卡不超过2张，对应“最多2只”。
function c48144509.fcheck(tp,sg,fc)
	return sg:FilterCount(Card.IsLocation,nil,LOCATION_EXTRA)<=2
end
-- 全局检查函数：限制融合素材组中来自额外卡组的卡不超过2张，防止超过额外素材数量。
function c48144509.gcheck(sg)
	return sg:FilterCount(Card.IsLocation,nil,LOCATION_EXTRA)<=2
end
-- 发动的合法判定与可融合召唤目标的确定：检查是否存在可用的龙族融合怪兽及足够的融合素材，满足追加条件时额外卡组的「异色眼」怪兽可加入素材并限制最多2张，同时设置操作信息。
function c48144509.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local chkf=tp
		-- 取得当前可用的融合素材并筛选能送去墓地的怪兽，作为基础素材池。
		local mg1=Duel.GetFusionMaterial(tp):Filter(Card.IsAbleToGrave,nil)
		-- 判断是否满足追加条件：自己场上没有怪兽，且对方场上有2只以上怪兽。
		if Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)==0 and Duel.GetFieldGroupCount(tp,0,LOCATION_MZONE)>1 then
			-- 从自己额外卡组中筛选可作素材的「异色眼」怪兽（不检查免疫），用于追加到素材池。
			local sg=Duel.GetMatchingGroup(c48144509.exfilter0,tp,LOCATION_EXTRA,0,nil)
			if sg:GetCount()>0 then
				mg1:Merge(sg)
				-- 设置额外素材检查，使选择的额外卡组素材数量不超过2张。
				aux.FCheckAdditional=c48144509.fcheck
				-- 设置融合素材组检查，同样限制额外卡组素材数量不超过2张。
				aux.GCheckAdditional=c48144509.gcheck
			end
		end
		-- 检查额外卡组中是否存在能用当前素材池进行融合召唤的龙族融合怪兽。
		local res=Duel.IsExistingMatchingCard(c48144509.filter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg1,nil,chkf)
		-- 清除额外检查函数，避免影响后续判定。
		aux.FCheckAdditional=nil
		-- 清除全局检查函数。
		aux.GCheckAdditional=nil
		if not res then
			-- 获取玩家可用的“连锁素材”类效果（可提供替代融合素材的效果）。
			local ce=Duel.GetChainMaterial(tp)
			if ce~=nil then
				local fgroup=ce:GetTarget()
				local mg2=fgroup(ce,e,tp)
				local mf=ce:GetValue()
				-- 使用连锁素材提供的素材组再次检查是否存在可融合召唤的龙族融合怪兽。
				res=Duel.IsExistingMatchingCard(c48144509.filter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg2,mf,chkf)
			end
		end
		return res
	end
	-- 设置本次效果将进行的操作为从额外卡组特殊召唤1只怪兽。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- 效果处理：选择要融合召唤的龙族融合怪兽；若满足条件，额外卡组的「异色眼」怪兽也可作为素材（最多2张）；通常素材可用则用通常素材融合召唤，否则可使用连锁素材效果进行融合。
function c48144509.activate(e,tp,eg,ep,ev,re,r,rp)
	local chkf=tp
	-- 效果处理时获取素材：从可用融合素材中筛选能送去墓地且不免疫此效果的怪兽。
	local mg1=Duel.GetFusionMaterial(tp):Filter(c48144509.filter1,nil,e)
	local exmat=false
	-- 同发动判定，判断是否满足追加条件：自己场上无怪兽且对方场上有2只以上怪兽。
	if Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)==0 and Duel.GetFieldGroupCount(tp,0,LOCATION_MZONE)>1 then
		-- 满足追加条件时，从额外卡组筛选可作为融合素材且不免疫此效果的「异色眼」怪兽。
		local sg=Duel.GetMatchingGroup(c48144509.exfilter1,tp,LOCATION_EXTRA,0,nil,e)
		if sg:GetCount()>0 then
			mg1:Merge(sg)
			exmat=true
		end
	end
	if exmat then
		-- 设置额外检查函数，限制额外卡组素材数量不超过2张。
		aux.FCheckAdditional=c48144509.fcheck
		-- 设置素材组检查函数，限制额外卡组素材数量不超过2张。
		aux.GCheckAdditional=c48144509.gcheck
	end
	-- 用扩展后的素材组（含额外卡组异色眼素材）收集所有可融合召唤的龙族融合怪兽候选。
	local sg1=Duel.GetMatchingGroup(c48144509.filter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg1,nil,chkf)
	-- 清除额外检查函数。
	aux.FCheckAdditional=nil
	-- 清除全局检查函数。
	aux.GCheckAdditional=nil
	local mg2=nil
	local sg2=nil
	-- 获取玩家可用的连锁素材效果。
	local ce=Duel.GetChainMaterial(tp)
	if ce~=nil then
		local fgroup=ce:GetTarget()
		mg2=fgroup(ce,e,tp)
		local mf=ce:GetValue()
		-- 用连锁素材提供的素材组收集所有可融合召唤的龙族融合怪兽候选。
		sg2=Duel.GetMatchingGroup(c48144509.filter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg2,mf,chkf)
	end
	if sg1:GetCount()>0 or (sg2~=nil and sg2:GetCount()>0) then
		local sg=sg1:Clone()
		if sg2 then sg:Merge(sg2) end
		-- 提示玩家选择要特殊召唤的融合怪兽（消息‘请选择要特殊召唤的卡’）。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		local tg=sg:Select(tp,1,1,nil)
		local tc=tg:GetFirst()
		mg1:RemoveCard(tc)
		-- 判断所选怪兽是否走普通流程：若所选怪兽不在连锁素材候选组中，或玩家选择不使用连锁素材，则按普通素材进行融合召唤；否则走连锁素材流程。
		if sg1:IsContains(tc) and (sg2==nil or not sg2:IsContains(tc) or not Duel.SelectYesNo(tp,ce:GetDescription())) then
			if exmat then
				-- 在普通流程选择素材前，设置额外卡组素材数量检查函数。
				aux.FCheckAdditional=c48144509.fcheck
				-- 设置素材组数量检查函数。
				aux.GCheckAdditional=c48144509.gcheck
			end
			-- 让玩家选择该融合怪兽所需的融合素材（受额外卡组素材数量限制）。
			local mat1=Duel.SelectFusionMaterial(tp,tc,mg1,nil,chkf)
			-- 清除额外检查函数。
			aux.FCheckAdditional=nil
			-- 清除全局检查函数。
			aux.GCheckAdditional=nil
			tc:SetMaterial(mat1)
			-- 将选择的融合素材送去墓地，此送墓原因为效果、融合素材和融合召唤。
			Duel.SendtoGrave(mat1,REASON_EFFECT+REASON_MATERIAL+REASON_FUSION)
			-- 中断连锁处理，使素材送墓与特殊召唤不是同时处理，保证正确时点。
			Duel.BreakEffect()
			-- 以融合召唤方式将选定的融合怪兽正面攻击表示特殊召唤到自己的怪兽区。
			Duel.SpecialSummon(tc,SUMMON_TYPE_FUSION,tp,tp,false,false,POS_FACEUP)
		else
			-- 若使用连锁素材流程，则从连锁素材提供的素材组中选择融合素材。
			local mat2=Duel.SelectFusionMaterial(tp,tc,mg2,nil,chkf)
			local fop=ce:GetOperation()
			fop(ce,e,tp,tc,mat2)
		end
		tc:CompleteProcedure()
	end
end
