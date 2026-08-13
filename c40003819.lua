--転臨の守護竜
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：从自己的场上·墓地把融合怪兽卡决定的融合素材怪兽除外，把那1只融合怪兽从额外卡组融合召唤。那个时候，融合素材怪兽必须全部是连接怪兽。
function c40003819.initial_effect(c)
	-- 这个卡名的卡在1回合只能发动1张。①：从自己的场上·墓地把融合怪兽卡决定的融合素材怪兽除外，把那1只融合怪兽从额外卡组融合召唤。那个时候，融合素材怪兽必须全部是连接怪兽。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_REMOVE+CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,40003819+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(c40003819.target)
	e1:SetOperation(c40003819.activate)
	c:RegisterEffect(e1)
end
-- 从系统取得的可用融合素材中，筛选出自己场上存在的连接怪兽，且可以被除外，作为能否发动融合召唤的素材候选。
function c40003819.filter0(c)
	return c:IsOnField() and c:IsType(TYPE_LINK) and c:IsAbleToRemove()
end
-- 实际处理时进一步筛选素材：场上存在的连接怪兽、可除外且不免疫此效果的卡，避免将不受本效果影响的卡作为融合素材。
function c40003819.filter1(c,e)
	return c:IsOnField() and c:IsType(TYPE_LINK) and c:IsAbleToRemove() and not c:IsImmuneToEffect(e)
end
-- 筛选额外卡组中的融合怪兽：必须是融合怪兽、满足额外素材条件f、可用给定素材组m进行融合召唤，且满足融合召唤特殊召唤的限制（不忽略召唤条件与苏生限制）。
function c40003819.filter2(c,e,tp,m,f,chkf)
	return c:IsType(TYPE_FUSION) and (not f or f(c))
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_FUSION,tp,false,false) and c:CheckFusionMaterial(m,nil,chkf)
end
-- 筛选自己墓地中的可用素材：是怪兽、连接怪兽、可作为融合素材且能被除外。
function c40003819.filter3(c)
	return c:IsType(TYPE_MONSTER) and c:IsType(TYPE_LINK) and c:IsCanBeFusionMaterial() and c:IsAbleToRemove()
end
-- target函数：chk==0时检查用通常素材或连锁素材能否融合召唤额外卡组中的一只融合怪兽；chk==1时登记特殊召唤与除外的操作信息。
function c40003819.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local chkf=tp
		-- 从系统检索到的可融合素材中，筛出自己场上存在的连接怪兽，且可除外，作为玩家在场上的候选融合素材。
		local mg1=Duel.GetFusionMaterial(tp):Filter(c40003819.filter0,nil)
		-- 从自己墓地中检索可作为融合素材且可除外的连接怪兽，加入候选素材组。
		local mg2=Duel.GetMatchingGroup(c40003819.filter3,tp,LOCATION_GRAVE,0,nil)
		mg1:Merge(mg2)
		-- 检查额外卡组是否存在一只融合怪兽，能够以mg1（场上·墓地候选素材）为素材进行融合召唤。
		local res=Duel.IsExistingMatchingCard(c40003819.filter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg1,nil,chkf)
		if not res then
			-- 获取当前玩家可用的连锁素材效果（例如“连锁素材”卡的替代素材效果），以便在通常素材不足时使用替代素材。
			local ce=Duel.GetChainMaterial(tp)
			if ce~=nil then
				local fgroup=ce:GetTarget()
				local mg3=fgroup(ce,e,tp)
				local mf=ce:GetValue()
				-- 若通常素材无法找到可融合怪兽，则用连锁素材提供的素材组mg3及条件mf再次检查额外卡组中是否存在可融合召唤的融合怪兽。
				res=Duel.IsExistingMatchingCard(c40003819.filter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg3,mf,chkf)
			end
		end
		return res
	end
	-- 确认发动时登记操作信息：本效果将把额外卡组的1只怪兽进行特殊召唤，供系统检测特殊召唤效果。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
	-- 确认发动时登记操作信息：本效果将把自己场上·墓地的卡除外（数量以1登记，供系统检测除外效果）。
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,tp,LOCATION_ONFIELD+LOCATION_GRAVE)
end
-- 融合召唤处理：重新整理可用素材和可融合怪兽列表，由玩家选择要融合召唤的额外怪兽；若使用通常素材则选择素材并除外后融合召唤，若使用连锁素材则交给连锁素材效果处理，最后完成融合召唤手续。
function c40003819.activate(e,tp,eg,ep,ev,re,r,rp)
	local chkf=tp
	-- 处理阶段重新筛出自己场上存在的、可除外且不免疫本效果的连接怪兽作为可用素材。
	local mg1=Duel.GetFusionMaterial(tp):Filter(c40003819.filter1,nil,e)
	-- 处理阶段从自己墓地中检索可作为融合素材且可除外的连接怪兽，补充候选素材。
	local mg2=Duel.GetMatchingGroup(c40003819.filter3,tp,LOCATION_GRAVE,0,nil)
	mg1:Merge(mg2)
	-- 用场上·墓地的候选素材mg1，筛选出额外卡组中所有可融合召唤的融合怪兽，构成可选列表。
	local sg1=Duel.GetMatchingGroup(c40003819.filter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg1,nil,chkf)
	local mg3=nil
	local sg2=nil
	-- 处理阶段再次获取当前玩家可用的连锁素材效果，用于判断是否走连锁素材融合路线。
	local ce=Duel.GetChainMaterial(tp)
	if ce~=nil then
		local fgroup=ce:GetTarget()
		mg3=fgroup(ce,e,tp)
		local mf=ce:GetValue()
		-- 若存在连锁素材，则用连锁素材提供的素材组mg3及条件mf筛选额外卡组中的可融合怪兽，并加入可选列表。
		sg2=Duel.GetMatchingGroup(c40003819.filter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg3,mf,chkf)
	end
	if sg1:GetCount()>0 or (sg2~=nil and sg2:GetCount()>0) then
		local sg=sg1:Clone()
		if sg2 then sg:Merge(sg2) end
		-- 提示玩家选择要融合召唤的特殊召唤对象（从符合条件的额外融合怪兽中选择1只）。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		local tg=sg:Select(tp,1,1,nil)
		local tc=tg:GetFirst()
		-- 判断选择的怪兽是否使用通常素材：若该怪兽可用通常素材融合，且（没有连锁素材组、或它不在连锁素材组中、或玩家选择不使用连锁素材），则用通常素材；否则用连锁素材。
		if sg1:IsContains(tc) and (sg2==nil or not sg2:IsContains(tc) or not Duel.SelectYesNo(tp,ce:GetDescription())) then
			-- 从通常素材候选组mg1中为选择的融合怪兽选择一组融合素材。
			local mat1=Duel.SelectFusionMaterial(tp,tc,mg1,nil,chkf)
			tc:SetMaterial(mat1)
			-- 将选中的融合素材以表侧表示除外，原因为效果处理、作为融合素材以及进行融合召唤。
			Duel.Remove(mat1,POS_FACEUP,REASON_EFFECT+REASON_MATERIAL+REASON_FUSION)
			-- 中断当前效果处理，使除外素材与随后的融合召唤不被视为同时处理，以符合融合召唤的时点规则。
			Duel.BreakEffect()
			-- 以融合召唤方式将选择的融合怪兽特殊召唤到自己场上，形式为表侧表示。
			Duel.SpecialSummon(tc,SUMMON_TYPE_FUSION,tp,tp,false,false,POS_FACEUP)
		else
			-- 在连锁素材路线下，从连锁素材效果提供的素材组mg3中为该融合怪兽选择一组融合素材。
			local mat2=Duel.SelectFusionMaterial(tp,tc,mg3,nil,chkf)
			local fop=ce:GetOperation()
			fop(ce,e,tp,tc,mat2)
		end
		tc:CompleteProcedure()
	end
end
