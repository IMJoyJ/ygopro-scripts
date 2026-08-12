--混錬装融合
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：从自己的手卡·场上的怪兽以及自己的额外卡组的表侧表示的灵摆怪兽之中把「炼装」融合怪兽卡决定的融合素材怪兽送去墓地，把那1只融合怪兽从额外卡组融合召唤。那个时候，从手卡·场上·额外卡组各只能有最多1只作为融合素材。
function c58549532.initial_effect(c)
	-- 这个卡名的卡在1回合只能发动1张。①：从自己的手卡·场上的怪兽以及自己的额外卡组的表侧表示的灵摆怪兽之中把「炼装」融合怪兽卡决定的融合素材怪兽送去墓地，把那1只融合怪兽从额外卡组融合召唤。那个时候，从手卡·场上·额外卡组各只能有最多1只作为融合素材。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,58549532+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(c58549532.target)
	e1:SetOperation(c58549532.activate)
	c:RegisterEffect(e1)
end
-- 过滤额外卡组表侧表示的灵摆怪兽作为融合素材
function c58549532.filter0(c,e)
	return c:IsCanBeFusionMaterial() and c:IsFaceup() and c:IsType(TYPE_PENDULUM) and not c:IsImmuneToEffect(e)
end
-- 过滤不受效果影响的怪兽
function c58549532.filter1(c,e)
	return not c:IsImmuneToEffect(e)
end
-- 过滤额外卡组中可以进行融合召唤的「炼装」融合怪兽
function c58549532.filter2(c,e,tp,m,f,chkf)
	return c:IsType(TYPE_FUSION) and c:IsSetCard(0xe1) and (not f or f(c))
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_FUSION,tp,false,false) and c:CheckFusionMaterial(m,nil,chkf)
end
-- 检查融合素材是否满足“从手卡·场上·额外卡组各只能有最多1只作为融合素材”的限制（即每个位置最多选1张）
function c58549532.fcheck(tp,sg,fc)
	return sg:GetClassCount(Card.GetLocation)==#sg
end
-- 检查选择的融合素材组合中，各卡片的位置是否互不相同（手卡、场上、额外卡组各最多1张）
function c58549532.gcheck(sg)
	return sg:GetClassCount(Card.GetLocation)==#sg
end
-- 效果发动的目标确认与合法性检测
function c58549532.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local chkf=tp
		-- 获取玩家可用的常规融合素材（手卡·场上）
		local mg1=Duel.GetFusionMaterial(tp)
		-- 将额外卡组表侧表示的灵摆怪兽合并到可用融合素材组中
		mg1:Merge(Duel.GetMatchingGroup(c58549532.filter0,tp,LOCATION_EXTRA,0,nil,e))
		-- 设置融合素材合法性检查的附加函数（限制各位置最多1张）
		aux.FCheckAdditional=c58549532.fcheck
		-- 设置融合素材选择过程中的动态检查附加函数（限制各位置最多1张）
		aux.GCheckAdditional=c58549532.gcheck
		-- 检查额外卡组是否存在可以使用当前素材进行融合召唤的「炼装」融合怪兽
		local res=Duel.IsExistingMatchingCard(c58549532.filter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg1,nil,chkf)
		if not res then
			-- 检查是否存在适用的连锁素材效果
			local ce=Duel.GetChainMaterial(tp)
			if ce~=nil then
				local fgroup=ce:GetTarget()
				local mg2=fgroup(ce,e,tp)
				local mf=ce:GetValue()
				-- 检查在连锁素材效果下是否存在可融合召唤的「炼装」融合怪兽
				res=Duel.IsExistingMatchingCard(c58549532.filter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg2,mf,chkf)
			end
		end
		-- 清除融合素材合法性检查的附加函数
		aux.FCheckAdditional=nil
		-- 清除融合素材选择过程中的动态检查附加函数
		aux.GCheckAdditional=nil
		return res
	end
	-- 设置特殊召唤的操作信息（从额外卡组特殊召唤1只怪兽）
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- 效果处理的执行函数
function c58549532.activate(e,tp,eg,ep,ev,re,r,rp)
	local chkf=tp
	-- 获取并过滤受效果影响的常规融合素材（手卡·场上）
	local mg1=Duel.GetFusionMaterial(tp):Filter(c58549532.filter1,nil,e)
	-- 将额外卡组表侧表示的灵摆怪兽合并到可用融合素材组中
	mg1:Merge(Duel.GetMatchingGroup(c58549532.filter0,tp,LOCATION_EXTRA,0,nil,e))
	-- 设置融合素材合法性检查的附加函数（限制各位置最多1张）
	aux.FCheckAdditional=c58549532.fcheck
	-- 设置融合素材选择过程中的动态检查附加函数（限制各位置最多1张）
	aux.GCheckAdditional=c58549532.gcheck
	-- 获取可使用当前素材融合召唤的「炼装」融合怪兽组
	local sg1=Duel.GetMatchingGroup(c58549532.filter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg1,nil,chkf)
	local mg2=nil
	local sg2=nil
	-- 检查是否存在适用的连锁素材效果
	local ce=Duel.GetChainMaterial(tp)
	if ce~=nil then
		local fgroup=ce:GetTarget()
		mg2=fgroup(ce,e,tp)
		local mf=ce:GetValue()
		-- 获取在连锁素材效果下可融合召唤的「炼装」融合怪兽组
		sg2=Duel.GetMatchingGroup(c58549532.filter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg2,mf,chkf)
	end
	if sg1:GetCount()>0 or (sg2~=nil and sg2:GetCount()>0) then
		local sg=sg1:Clone()
		if sg2 then sg:Merge(sg2) end
		-- 提示玩家选择要特殊召唤的怪兽
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		local tg=sg:Select(tp,1,1,nil)
		local tc=tg:GetFirst()
		-- 判断是否使用本卡的效果进行融合召唤（而非连锁素材效果）
		if sg1:IsContains(tc) and (sg2==nil or not sg2:IsContains(tc) or not Duel.SelectYesNo(tp,ce:GetDescription())) then
			-- 玩家选择融合素材（受各位置最多1张的限制）
			local mat1=Duel.SelectFusionMaterial(tp,tc,mg1,nil,chkf)
			tc:SetMaterial(mat1)
			-- 将选定的融合素材送去墓地
			Duel.SendtoGrave(mat1,REASON_EFFECT+REASON_MATERIAL+REASON_FUSION)
			-- 产生时点中断，使后续的特殊召唤不与送去墓地同时处理
			Duel.BreakEffect()
			-- 将融合怪兽从额外卡组进行融合召唤
			Duel.SpecialSummon(tc,SUMMON_TYPE_FUSION,tp,tp,false,false,POS_FACEUP)
		else
			-- 在连锁素材效果下选择融合素材
			local mat2=Duel.SelectFusionMaterial(tp,tc,mg2,nil,chkf)
			local fop=ce:GetOperation()
			fop(ce,e,tp,tc,mat2)
		end
		tc:CompleteProcedure()
	end
	-- 清除融合素材合法性检查的附加函数
	aux.FCheckAdditional=nil
	-- 清除融合素材选择过程中的动态检查附加函数
	aux.GCheckAdditional=nil
end
