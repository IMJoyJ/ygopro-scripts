--オーバーロード・フュージョン
-- 效果：
-- ①：自己的场上·墓地的怪兽作为融合素材除外，把1只机械族·暗属性的融合怪兽融合召唤。
function c3659803.initial_effect(c)
	-- ①：自己的场上·墓地的怪兽作为融合素材除外，把1只机械族·暗属性的融合怪兽融合召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_REMOVE+CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c3659803.target)
	e1:SetOperation(c3659803.activate)
	c:RegisterEffect(e1)
end
-- 筛选出场上能够被除外的怪兽，作为发动判定的融合素材候选。
function c3659803.filter0(c)
	return c:IsOnField() and c:IsAbleToRemove()
end
-- 筛选出场上能够被除外且不免疫此效果的怪兽，作为实际可用的融合素材候选。
function c3659803.filter1(c,e)
	return c:IsOnField() and c:IsAbleToRemove() and not c:IsImmuneToEffect(e)
end
-- 判断额外卡组怪兽是否为机械族·暗属性的融合怪兽，且能用给定素材进行融合召唤并满足苏生限制。
function c3659803.filter2(c,e,tp,m,f,chkf)
	return c:IsType(TYPE_FUSION) and c:IsAttribute(ATTRIBUTE_DARK) and c:IsRace(RACE_MACHINE) and (not f or f(c))
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_FUSION,tp,false,false) and c:CheckFusionMaterial(m,nil,chkf)
end
-- 筛选出墓地中可作为融合素材且能够被除外的怪兽。
function c3659803.filter3(c)
	return c:IsType(TYPE_MONSTER) and c:IsCanBeFusionMaterial() and c:IsAbleToRemove()
end
-- 发动时的合法判定与操作信息设置：确认存在可用场上·墓地的素材融合召唤符合条件的机械族暗属性融合怪兽；若存在连锁素材效果也一并检测；满足后将特殊召唤和除外信息写入连锁。
function c3659803.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local chkf=tp
		-- 取得常规融合素材（手卡·场上等）中场上且可被除外的怪兽，作为候选素材组。
		local mg1=Duel.GetFusionMaterial(tp):Filter(c3659803.filter0,nil)
		-- 取得墓地中可作为融合素材且可被除外的怪兽，作为候选素材组。
		local mg2=Duel.GetMatchingGroup(c3659803.filter3,tp,LOCATION_GRAVE,0,nil)
		mg1:Merge(mg2)
		-- 检查额外卡组是否存在能用常规候选素材融合召唤的机械族暗属性融合怪兽。
		local res=Duel.IsExistingMatchingCard(c3659803.filter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg1,nil,chkf)
		if not res then
			-- 获取当前玩家可用的“连锁素材”类效果（若存在，用于扩展可用的融合素材）。
			local ce=Duel.GetChainMaterial(tp)
			if ce~=nil then
				local fgroup=ce:GetTarget()
				local mg3=fgroup(ce,e,tp)
				local mf=ce:GetValue()
				-- 使用连锁素材效果提供的素材组，检查额外卡组是否存在符合条件的融合怪兽。
				res=Duel.IsExistingMatchingCard(c3659803.filter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg3,mf,chkf)
			end
		end
		return res
	end
	-- 设定本次连锁将进行特殊召唤，目标为额外卡组（供发动时点检测等使用）。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
	-- 设定本次连锁将除外场上·墓地的融合素材。
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,tp,LOCATION_ONFIELD+LOCATION_GRAVE)
end
-- 效果处理时确定融合素材：将选中的场上·墓地的素材除外，把机械族暗属性融合怪兽以融合召唤方式特殊召唤；若使用连锁素材效果，则交由该效果处理融合。
function c3659803.activate(e,tp,eg,ep,ev,re,r,rp)
	local chkf=tp
	-- 取得常规融合素材中场上可被除外且不免疫此效果的怪兽，作为实际素材候选。
	local mg1=Duel.GetFusionMaterial(tp):Filter(c3659803.filter1,nil,e)
	-- 取得墓地中可作为融合素材且能被除外的怪兽，作为实际素材候选。
	local mg2=Duel.GetMatchingGroup(c3659803.filter3,tp,LOCATION_GRAVE,0,nil)
	mg1:Merge(mg2)
	-- 使用常规素材组（mg1+mg2）筛选出所有可融合召唤的机械族暗属性融合怪兽，作为待选列表。
	local sg1=Duel.GetMatchingGroup(c3659803.filter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg1,nil,chkf)
	local mg3=nil
	local sg2=nil
	-- 获取连锁素材效果（若存在）。
	local ce=Duel.GetChainMaterial(tp)
	if ce~=nil then
		local fgroup=ce:GetTarget()
		mg3=fgroup(ce,e,tp)
		local mf=ce:GetValue()
		-- 使用连锁素材提供的素材组筛选出可融合召唤的机械族暗属性融合怪兽，形成另一组待选列表。
		sg2=Duel.GetMatchingGroup(c3659803.filter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg3,mf,chkf)
	end
	if sg1:GetCount()>0 or (sg2~=nil and sg2:GetCount()>0) then
		local sg=sg1:Clone()
		if sg2 then sg:Merge(sg2) end
		-- 向玩家发送“请选择要特殊召唤的卡”的选择提示。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		local tg=sg:Select(tp,1,1,nil)
		local tc=tg:GetFirst()
		-- 如果所选怪兽属于常规素材可选组，且（没有连锁素材组、或所选怪兽不在连锁素材组中、或玩家选择不使用连锁素材效果），则走通常融合流程；否则走连锁素材流程。
		if sg1:IsContains(tc) and (sg2==nil or not sg2:IsContains(tc) or not Duel.SelectYesNo(tp,ce:GetDescription())) then
			-- 选择通常融合流程要使用的融合素材（并自动建立对象关联）。
			local mat1=Duel.SelectFusionMaterial(tp,tc,mg1,nil,chkf)
			tc:SetMaterial(mat1)
			-- 将选择的融合素材以表侧表示除外，处理原因为效果+融合素材+融合召唤。
			Duel.Remove(mat1,POS_FACEUP,REASON_EFFECT+REASON_MATERIAL+REASON_FUSION)
			-- 中断当前效果，使素材除外与后续特殊召唤视为不同时处理，以保证特殊召唤的时点正确。
			Duel.BreakEffect()
			-- 以融合召唤方式将选择的融合怪兽表侧表示特殊召唤到自己场上。
			Duel.SpecialSummon(tc,SUMMON_TYPE_FUSION,tp,tp,false,false,POS_FACEUP)
		else
			-- 在连锁素材流程中选择由连锁素材效果指定的融合素材，供其处理融合。
			local mat2=Duel.SelectFusionMaterial(tp,tc,mg3,nil,chkf)
			local fop=ce:GetOperation()
			fop(ce,e,tp,tc,mat2)
		end
		tc:CompleteProcedure()
	end
end
