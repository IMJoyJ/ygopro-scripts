--ペンデュラム・フュージョン
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：从自己场上把融合怪兽卡决定的融合素材怪兽送去墓地，把那1只融合怪兽从额外卡组融合召唤。自己的灵摆区域有2张卡存在的场合，自己的灵摆区域存在的融合素材怪兽也能作为融合素材使用。
function c65646587.initial_effect(c)
	-- 这个卡名的卡在1回合只能发动1张。①：从自己场上把融合怪兽卡决定的融合素材怪兽送去墓地，把那1只融合怪兽从额外卡组融合召唤。自己的灵摆区域有2张卡存在的场合，自己的灵摆区域存在的融合素材怪兽也能作为融合素材使用。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,65646587+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(c65646587.target)
	e1:SetOperation(c65646587.activate)
	c:RegisterEffect(e1)
end
-- 过滤函数：过滤可以作为融合素材且不受当前效果影响的卡片
function c65646587.filter0(c,e)
	return c:IsCanBeFusionMaterial() and not c:IsImmuneToEffect(e)
end
-- 过滤函数：过滤在场上且不受当前效果影响的卡片
function c65646587.filter1(c,e)
	return c:IsOnField() and not c:IsImmuneToEffect(e)
end
-- 过滤函数：过滤额外卡组中可以进行融合召唤且素材满足条件的融合怪兽
function c65646587.filter2(c,e,tp,m,f,chkf)
	return c:IsType(TYPE_FUSION) and (not f or f(c))
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_FUSION,tp,false,false) and c:CheckFusionMaterial(m,nil,chkf)
end
-- 效果发动的目标确认与合法性检查（Target阶段）
function c65646587.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local chkf=tp
		-- 获取玩家场上可用的融合素材
		local mg1=Duel.GetFusionMaterial(tp):Filter(Card.IsOnField,nil)
		-- 检查自己的灵摆区域是否存在2张卡
		if Duel.GetFieldGroupCount(tp,LOCATION_PZONE,0)>=2 then
			-- 将自己灵摆区域的卡合并到可用融合素材组中
			mg1:Merge(Duel.GetMatchingGroup(c65646587.filter0,tp,LOCATION_PZONE,0,nil,e))
		end
		-- 检查额外卡组是否存在可以使用当前素材进行融合召唤的怪兽
		local res=Duel.IsExistingMatchingCard(c65646587.filter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg1,nil,chkf)
		if not res then
			-- 获取玩家受到的连锁素材效果
			local ce=Duel.GetChainMaterial(tp)
			if ce~=nil then
				local fgroup=ce:GetTarget()
				local mg2=fgroup(ce,e,tp)
				local mf=ce:GetValue()
				-- 检查在连锁素材效果影响下，是否存在可以融合召唤的怪兽
				res=Duel.IsExistingMatchingCard(c65646587.filter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg2,mf,chkf)
			end
		end
		return res
	end
	-- 设置操作信息为从额外卡组特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- 效果处理的执行函数（Resolution阶段）
function c65646587.activate(e,tp,eg,ep,ev,re,r,rp)
	local chkf=tp
	-- 获取玩家场上不受此卡效果影响的可用融合素材
	local mg1=Duel.GetFusionMaterial(tp):Filter(c65646587.filter1,nil,e)
	-- 检查自己的灵摆区域是否存在2张卡
	if Duel.GetFieldGroupCount(tp,LOCATION_PZONE,0)>=2 then
		-- 将自己灵摆区域的卡合并到可用融合素材组中
		mg1:Merge(Duel.GetMatchingGroup(c65646587.filter0,tp,LOCATION_PZONE,0,nil,e))
	end
	-- 获取额外卡组中可以使用当前素材进行融合召唤的怪兽组
	local sg1=Duel.GetMatchingGroup(c65646587.filter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg1,nil,chkf)
	local mg2=nil
	local sg2=nil
	-- 获取玩家受到的连锁素材效果
	local ce=Duel.GetChainMaterial(tp)
	if ce~=nil then
		local fgroup=ce:GetTarget()
		mg2=fgroup(ce,e,tp)
		local mf=ce:GetValue()
		-- 获取在连锁素材效果影响下，可以融合召唤的怪兽组
		sg2=Duel.GetMatchingGroup(c65646587.filter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg2,mf,chkf)
	end
	if sg1:GetCount()>0 or (sg2~=nil and sg2:GetCount()>0) then
		local sg=sg1:Clone()
		if sg2 then sg:Merge(sg2) end
		-- 提示玩家选择要特殊召唤的怪兽
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		local tg=sg:Select(tp,1,1,nil)
		local tc=tg:GetFirst()
		-- 判断是否使用常规融合方式（而非连锁素材的效果）进行融合召唤
		if sg1:IsContains(tc) and (sg2==nil or not sg2:IsContains(tc) or not Duel.SelectYesNo(tp,ce:GetDescription())) then
			-- 玩家选择融合素材
			local mat1=Duel.SelectFusionMaterial(tp,tc,mg1,nil,chkf)
			tc:SetMaterial(mat1)
			-- 将选定的融合素材送去墓地
			Duel.SendtoGrave(mat1,REASON_EFFECT+REASON_MATERIAL+REASON_FUSION)
			-- 中断当前效果处理，使后续的特殊召唤不与送去墓地同时处理
			Duel.BreakEffect()
			-- 将融合怪兽从额外卡组进行融合召唤
			Duel.SpecialSummon(tc,SUMMON_TYPE_FUSION,tp,tp,false,false,POS_FACEUP)
		else
			-- 在连锁素材效果下，玩家选择融合素材
			local mat2=Duel.SelectFusionMaterial(tp,tc,mg2,nil,chkf)
			local fop=ce:GetOperation()
			fop(ce,e,tp,tc,mat2)
		end
		tc:CompleteProcedure()
	end
end
