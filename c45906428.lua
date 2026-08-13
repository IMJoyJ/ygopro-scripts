--ミラクル・フュージョン
-- 效果：
-- ①：自己的场上·墓地的怪兽作为融合素材除外，把1只「元素英雄」融合怪兽融合召唤。
function c45906428.initial_effect(c)
	-- ①：自己的场上·墓地的怪兽作为融合素材除外，把1只「元素英雄」融合怪兽融合召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_REMOVE+CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c45906428.target)
	e1:SetOperation(c45906428.activate)
	c:RegisterEffect(e1)
end
-- 筛选出位于场上且可以被除外的怪兽卡，作为通常融合素材时的场上素材候选。
function c45906428.filter0(c)
	return c:IsOnField() and c:IsAbleToRemove()
end
-- 筛选出位于场上、可以被除外且不免疫此效果的怪兽卡，用于效果处理时实际选择并除外素材。
function c45906428.filter1(c,e)
	return c:IsOnField() and c:IsAbleToRemove() and not c:IsImmuneToEffect(e)
end
-- 筛选出额外卡组中可作为融合召唤对象的「元素英雄」融合怪兽：必须是融合怪兽、拥有「元素英雄」字段、满足连锁素材的追加条件（f）、能被以融合召唤方式特殊召唤，并且能用给定素材m进行融合召唤。
function c45906428.filter2(c,e,tp,m,f,chkf)
	return c:IsType(TYPE_FUSION) and c:IsSetCard(0x3008) and (not f or f(c))
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_FUSION,tp,false,false) and c:CheckFusionMaterial(m,nil,chkf)
end
-- 筛选出墓地中可作为融合素材且能被除外的怪兽卡。
function c45906428.filter3(c)
	return c:IsType(TYPE_MONSTER) and c:IsCanBeFusionMaterial() and c:IsAbleToRemove()
end
-- 效果发动时的合法性检查：收集场上·墓地的可除外融合素材（必要时检查连锁素材），确认额外卡组中存在能用这些素材融合召唤的「元素英雄」融合怪兽；满足后设置本次效果的除外与特殊召唤操作信息。
function c45906428.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local chkf=tp
		-- 获取玩家tp可用的融合素材组（通常包括手卡·场上的怪兽以及受额外融合素材效果影响的卡），再筛选出其中在场上且能被除外的卡，作为普通素材候选。
		local mg1=Duel.GetFusionMaterial(tp):Filter(c45906428.filter0,nil)
		-- 获取玩家tp墓地中满足filter3（怪兽、可作为融合素材、可除外）的卡，作为墓地素材候选。
		local mg2=Duel.GetMatchingGroup(c45906428.filter3,tp,LOCATION_GRAVE,0,nil)
		mg1:Merge(mg2)
		-- 检查额外卡组中是否存在1张「元素英雄」融合怪兽，能用场上·墓地的候选素材mg1完成融合召唤（chkf=tp表示融合素材区域限定为自己可控的区域）。
		local res=Duel.IsExistingMatchingCard(c45906428.filter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg1,nil,chkf)
		if not res then
			-- 获取玩家tp当前适用的连锁素材效果（用于替代融合素材的特殊效果），以便在普通素材不满足时尝试使用替代融合素材。
			local ce=Duel.GetChainMaterial(tp)
			if ce~=nil then
				local fgroup=ce:GetTarget()
				local mg3=fgroup(ce,e,tp)
				local mf=ce:GetValue()
				-- 使用连锁素材提供的一组素材mg3和特殊限制mf，再次检查额外卡组是否存在可融合召唤的「元素英雄」融合怪兽。
				res=Duel.IsExistingMatchingCard(c45906428.filter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg3,mf,chkf)
			end
		end
		return res
	end
	-- 设置操作信息：这次效果处理将进行特殊召唤，预计从额外卡组特殊召唤1只怪兽（对象在效果处理时确定，因此targets为nil）。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
	-- 设置操作信息：这次效果处理将进行除外，预计从场上·墓地除外1张以上的素材（具体数量与对象在效果处理时确定）。
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,tp,LOCATION_ONFIELD+LOCATION_GRAVE)
end
-- 效果处理：收集可用的普通融合素材（场上·墓地且不免疫此效果）以及连锁素材替代素材；从额外卡组选择1只「元素英雄」融合怪兽；若使用普通素材，则选择融合素材、将其除外，再以融合召唤方式特殊召唤；若使用连锁素材，则调用连锁素材的融合操作；最后完成融合召唤的处理流程。
function c45906428.activate(e,tp,eg,ep,ev,re,r,rp)
	local chkf=tp
	-- 获取通常融合素材候选，并筛除在场上、可除外且不免疫此效果的怪兽（处理时需确认实际可除外）。
	local mg1=Duel.GetFusionMaterial(tp):Filter(c45906428.filter1,nil,e)
	-- 获取墓地中符合条件的素材候选。
	local mg2=Duel.GetMatchingGroup(c45906428.filter3,tp,LOCATION_GRAVE,0,nil)
	mg1:Merge(mg2)
	-- 用通常素材mg1筛选出额外卡组中当前可融合召唤的「元素英雄」融合怪兽，作为候选特殊召唤对象。
	local sg1=Duel.GetMatchingGroup(c45906428.filter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg1,nil,chkf)
	local mg3=nil
	local sg2=nil
	-- 获取连锁素材效果（如果有），用于后续尝试使用替代素材。
	local ce=Duel.GetChainMaterial(tp)
	if ce~=nil then
		local fgroup=ce:GetTarget()
		mg3=fgroup(ce,e,tp)
		local mf=ce:GetValue()
		-- 使用连锁素材提供的替代素材mg3及特殊条件mf，再次筛选额外卡组中可融合召唤的「元素英雄」融合怪兽，作为另一组候选。
		sg2=Duel.GetMatchingGroup(c45906428.filter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg3,mf,chkf)
	end
	if sg1:GetCount()>0 or (sg2~=nil and sg2:GetCount()>0) then
		local sg=sg1:Clone()
		if sg2 then sg:Merge(sg2) end
		-- 向玩家显示“请选择要特殊召唤的卡”的选择提示。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		local tg=sg:Select(tp,1,1,nil)
		local tc=tg:GetFirst()
		-- 判断所选怪兽是否属于通常素材融合范围：如果该怪兽可用普通素材融合，且（没有连锁素材可用、或该怪兽不在连锁素材候选内、或玩家选择不使用连锁素材），则按通常融合处理；否则使用连锁素材处理。
		if sg1:IsContains(tc) and (sg2==nil or not sg2:IsContains(tc) or not Duel.SelectYesNo(tp,ce:GetDescription())) then
			-- 让玩家从普通素材候选mg1中选择融合怪兽tc所需的融合素材（一组）。
			local mat1=Duel.SelectFusionMaterial(tp,tc,mg1,nil,chkf)
			tc:SetMaterial(mat1)
			-- 将选择的融合素材以表侧表示除外，除外原因记为效果+作为融合素材。
			Duel.Remove(mat1,POS_FACEUP,REASON_EFFECT+REASON_MATERIAL+REASON_FUSION)
			-- 中断当前效果处理，使后续融合召唤处理视为不同时进行（避免时点合并，确保融合召唤成功时点独立）。
			Duel.BreakEffect()
			-- 以融合召唤方式将融合怪兽tc表侧表示特殊召唤到己方场上（不检查召唤条件/苏生限制，因为融合召唤本身已满足）。
			Duel.SpecialSummon(tc,SUMMON_TYPE_FUSION,tp,tp,false,false,POS_FACEUP)
		else
			-- 在使用连锁素材的情况下，让玩家从连锁素材提供的替代素材mg3中选择融合怪兽tc所需的融合素材。
			local mat2=Duel.SelectFusionMaterial(tp,tc,mg3,nil,chkf)
			local fop=ce:GetOperation()
			fop(ce,e,tp,tc,mat2)
		end
		tc:CompleteProcedure()
	end
end
