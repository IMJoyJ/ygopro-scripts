--魔玩具融合
-- 效果：
-- 「魔玩具融合」在1回合只能发动1张。
-- ①：从自己的场上·墓地把「魔玩具」融合怪兽卡决定的融合素材怪兽除外，把那1只融合怪兽从额外卡组融合召唤。
function c6077601.initial_effect(c)
	-- 「魔玩具融合」在1回合只能发动1张。①：从自己的场上·墓地把「魔玩具」融合怪兽卡决定的融合素材怪兽除外，把那1只融合怪兽从额外卡组融合召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_REMOVE+CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,6077601+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(c6077601.target)
	e1:SetOperation(c6077601.activate)
	c:RegisterEffect(e1)
end
-- 过滤场上可以被除外的卡片（用于在发动准备阶段筛选融合素材）
function c6077601.filter0(c)
	return c:IsOnField() and c:IsAbleToRemove()
end
-- 过滤场上可以被除外且不受此效果影响的卡片（用于效果处理时筛选融合素材）
function c6077601.filter1(c,e)
	return c:IsOnField() and c:IsAbleToRemove() and not c:IsImmuneToEffect(e)
end
-- 过滤额外卡组中可以进行融合召唤的「魔玩具」融合怪兽
function c6077601.filter2(c,e,tp,m,f,chkf)
	return c:IsType(TYPE_FUSION) and c:IsSetCard(0xad) and (not f or f(c))
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_FUSION,tp,false,false) and c:CheckFusionMaterial(m,nil,chkf)
end
-- 过滤墓地中可以作为融合素材且可以被除外的怪兽卡
function c6077601.filter3(c)
	return c:IsType(TYPE_MONSTER) and c:IsCanBeFusionMaterial() and c:IsAbleToRemove()
end
-- 效果发动时的合法性检测（Target阶段），判断是否存在可融合召唤的合法组合，并声明特殊召唤和除外的操作信息
function c6077601.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local chkf=tp
		-- 获取玩家场上可作为融合素材且能被除外的卡片组
		local mg1=Duel.GetFusionMaterial(tp):Filter(c6077601.filter0,nil)
		-- 获取玩家墓地中可作为融合素材且能被除外的怪兽卡片组
		local mg2=Duel.GetMatchingGroup(c6077601.filter3,tp,LOCATION_GRAVE,0,nil)
		mg1:Merge(mg2)
		-- 检查额外卡组中是否存在可以使用当前场上和墓地素材进行融合召唤的「魔玩具」融合怪兽
		local res=Duel.IsExistingMatchingCard(c6077601.filter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg1,nil,chkf)
		if not res then
			-- 获取玩家受到的连锁素材（如「连锁素材」）效果
			local ce=Duel.GetChainMaterial(tp)
			if ce~=nil then
				local fgroup=ce:GetTarget()
				local mg3=fgroup(ce,e,tp)
				local mf=ce:GetValue()
				-- 在存在连锁素材效果时，检查是否可以使用连锁素材效果提供的素材进行融合召唤
				res=Duel.IsExistingMatchingCard(c6077601.filter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg3,mf,chkf)
			end
		end
		return res
	end
	-- 设置连锁操作信息，表明此效果包含从额外卡组特殊召唤1只怪兽的操作
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
	-- 设置连锁操作信息，表明此效果包含从场上或墓地除外卡片的操作
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,tp,LOCATION_ONFIELD+LOCATION_GRAVE)
end
-- 效果处理（Resolution阶段），执行融合素材的选择、除外以及融合怪兽的特殊召唤
function c6077601.activate(e,tp,eg,ep,ev,re,r,rp)
	local chkf=tp
	-- 获取玩家场上可作为融合素材、能被除外且不受此效果影响的卡片组
	local mg1=Duel.GetFusionMaterial(tp):Filter(c6077601.filter1,nil,e)
	-- 获取玩家墓地中可作为融合素材且能被除外的怪兽卡片组
	local mg2=Duel.GetMatchingGroup(c6077601.filter3,tp,LOCATION_GRAVE,0,nil)
	mg1:Merge(mg2)
	-- 筛选出额外卡组中可以使用场上和墓地素材进行融合召唤的「魔玩具」融合怪兽组
	local sg1=Duel.GetMatchingGroup(c6077601.filter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg1,nil,chkf)
	local mg3=nil
	local sg2=nil
	-- 获取玩家受到的连锁素材效果
	local ce=Duel.GetChainMaterial(tp)
	if ce~=nil then
		local fgroup=ce:GetTarget()
		mg3=fgroup(ce,e,tp)
		local mf=ce:GetValue()
		-- 筛选出额外卡组中可以使用连锁素材效果提供的素材进行融合召唤的「魔玩具」融合怪兽组
		sg2=Duel.GetMatchingGroup(c6077601.filter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg3,mf,chkf)
	end
	if sg1:GetCount()>0 or (sg2~=nil and sg2:GetCount()>0) then
		local sg=sg1:Clone()
		if sg2 then sg:Merge(sg2) end
		-- 提示玩家选择要特殊召唤的怪兽
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		local tg=sg:Select(tp,1,1,nil)
		local tc=tg:GetFirst()
		-- 判断是否使用本卡自身的效果进行融合召唤（若不使用连锁素材效果，或玩家选择不使用连锁素材效果）
		if sg1:IsContains(tc) and (sg2==nil or not sg2:IsContains(tc) or not Duel.SelectYesNo(tp,ce:GetDescription())) then
			-- 让玩家从场上和墓地的素材中选择一组符合所选融合怪兽要求的融合素材
			local mat1=Duel.SelectFusionMaterial(tp,tc,mg1,nil,chkf)
			tc:SetMaterial(mat1)
			-- 将选定的融合素材以表侧表示除外
			Duel.Remove(mat1,POS_FACEUP,REASON_EFFECT+REASON_MATERIAL+REASON_FUSION)
			-- 中断当前效果处理，使后续的特殊召唤处理与除外处理不视为同时进行
			Duel.BreakEffect()
			-- 将选定的融合怪兽以表侧表示融合召唤特殊召唤到场上
			Duel.SpecialSummon(tc,SUMMON_TYPE_FUSION,tp,tp,false,false,POS_FACEUP)
		else
			-- 让玩家从连锁素材效果提供的素材中选择一组符合所选融合怪兽要求的融合素材
			local mat2=Duel.SelectFusionMaterial(tp,tc,mg3,nil,chkf)
			local fop=ce:GetOperation()
			fop(ce,e,tp,tc,mat2)
		end
		tc:CompleteProcedure()
	end
end
