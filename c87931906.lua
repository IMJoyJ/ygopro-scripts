--月光融合
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：从自己的手卡·场上把「月光」融合怪兽卡决定的融合素材怪兽送去墓地，把那1只融合怪兽从额外卡组融合召唤。对方场上有从额外卡组特殊召唤的怪兽存在的场合自己的卡组·额外卡组的「月光」怪兽也能有最多1只作为融合素材。
function c87931906.initial_effect(c)
	-- 这个卡名的卡在1回合只能发动1张。①：从自己的手卡·场上把「月光」融合怪兽卡决定的融合素材怪兽送去墓地，把那1只融合怪兽从额外卡组融合召唤。对方场上有从额外卡组特殊召唤的怪兽存在的场合自己的卡组·额外卡组的「月光」怪兽也能有最多1只作为融合素材。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON+CATEGORY_DECKDES)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,87931906+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(c87931906.target)
	e1:SetOperation(c87931906.activate)
	c:RegisterEffect(e1)
end
-- 过滤卡组·额外卡组中可以作为融合素材且能送去墓地的「月光」怪兽
function c87931906.filter0(c)
	return c:IsSetCard(0xdf) and c:IsType(TYPE_MONSTER) and c:IsCanBeFusionMaterial() and c:IsAbleToGrave()
end
-- 过滤不受当前效果影响的怪兽
function c87931906.filter1(c,e)
	return not c:IsImmuneToEffect(e)
end
-- 过滤额外卡组中可以融合召唤的「月光」融合怪兽
function c87931906.filter2(c,e,tp,m,f,chkf)
	return c:IsType(TYPE_FUSION) and c:IsSetCard(0xdf) and (not f or f(c))
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_FUSION,tp,false,false) and c:CheckFusionMaterial(m,nil,chkf)
end
-- 过滤从额外卡组特殊召唤的怪兽
function c87931906.cfilter(c)
	return c:IsSummonLocation(LOCATION_EXTRA)
end
-- 限制从卡组或额外卡组选择的融合素材数量最多为1张
function c87931906.fcheck(tp,sg,fc)
	return sg:FilterCount(Card.IsLocation,nil,LOCATION_DECK+LOCATION_EXTRA)<=1
end
-- 限制融合素材组中来自卡组或额外卡组的卡片数量最多为1张
function c87931906.gcheck(sg)
	return sg:FilterCount(Card.IsLocation,nil,LOCATION_DECK+LOCATION_EXTRA)<=1
end
-- 效果发动的准备与合法性检测（Target阶段）
function c87931906.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local chkf=tp
		-- 获取玩家手卡和场上可用的融合素材
		local mg1=Duel.GetFusionMaterial(tp)
		-- 检查对方场上是否存在从额外卡组特殊召唤的怪兽
		if Duel.IsExistingMatchingCard(c87931906.cfilter,tp,0,LOCATION_MZONE,1,nil) then
			-- 获取自己卡组·额外卡组中满足条件的「月光」怪兽
			local mg2=Duel.GetMatchingGroup(c87931906.filter0,tp,LOCATION_DECK+LOCATION_EXTRA,0,nil)
			if mg2:GetCount()>0 then
				mg1:Merge(mg2)
				-- 设定融合素材检查的附加过滤函数（限制卡组·额外卡组素材数）
				aux.FCheckAdditional=c87931906.fcheck
				-- 设定融合素材组选择的附加过滤函数（限制卡组·额外卡组素材数）
				aux.GCheckAdditional=c87931906.gcheck
			end
		end
		-- 检查是否存在可以使用当前素材进行融合召唤的「月光」融合怪兽
		local res=Duel.IsExistingMatchingCard(c87931906.filter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg1,nil,chkf)
		-- 重置融合素材检查的附加过滤函数
		aux.FCheckAdditional=nil
		-- 重置融合素材组选择的附加过滤函数
		aux.GCheckAdditional=nil
		if not res then
			-- 获取玩家受到的连锁素材效果
			local ce=Duel.GetChainMaterial(tp)
			if ce~=nil then
				local fgroup=ce:GetTarget()
				local mg3=fgroup(ce,e,tp)
				local mf=ce:GetValue()
				-- 检查在连锁素材效果下是否存在可融合召唤的「月光」融合怪兽
				res=Duel.IsExistingMatchingCard(c87931906.filter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg3,mf,chkf)
			end
		end
		return res
	end
	-- 设置连锁信息，表明此效果包含从额外卡组特殊召唤怪兽的操作
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- 效果处理的执行（Activate阶段）
function c87931906.activate(e,tp,eg,ep,ev,re,r,rp)
	local chkf=tp
	-- 获取手卡·场上不受此卡效果影响以外的可用融合素材
	local mg1=Duel.GetFusionMaterial(tp):Filter(c87931906.filter1,nil,e)
	local exmat=false
	-- 检查对方场上是否存在从额外卡组特殊召唤的怪兽
	if Duel.IsExistingMatchingCard(c87931906.cfilter,tp,0,LOCATION_MZONE,1,nil) then
		-- 获取自己卡组·额外卡组中满足条件的「月光」怪兽
		local mg2=Duel.GetMatchingGroup(c87931906.filter0,tp,LOCATION_DECK+LOCATION_EXTRA,0,nil)
		if mg2:GetCount()>0 then
			mg1:Merge(mg2)
			exmat=true
		end
	end
	if exmat then
		-- 设定融合素材检查的附加过滤函数（限制卡组·额外卡组素材数）
		aux.FCheckAdditional=c87931906.fcheck
		-- 设定融合素材组选择的附加过滤函数（限制卡组·额外卡组素材数）
		aux.GCheckAdditional=c87931906.gcheck
	end
	-- 获取当前素材下可以融合召唤的「月光」融合怪兽组
	local sg1=Duel.GetMatchingGroup(c87931906.filter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg1,nil,chkf)
	-- 重置融合素材检查的附加过滤函数
	aux.FCheckAdditional=nil
	-- 重置融合素材组选择的附加过滤函数
	aux.GCheckAdditional=nil
	local mg3=nil
	local sg2=nil
	-- 获取玩家受到的连锁素材效果
	local ce=Duel.GetChainMaterial(tp)
	if ce~=nil then
		local fgroup=ce:GetTarget()
		mg3=fgroup(ce,e,tp)
		local mf=ce:GetValue()
		-- 获取在连锁素材效果下可以融合召唤的「月光」融合怪兽组
		sg2=Duel.GetMatchingGroup(c87931906.filter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg3,mf,chkf)
	end
	if sg1:GetCount()>0 or (sg2~=nil and sg2:GetCount()>0) then
		local sg=sg1:Clone()
		if sg2 then sg:Merge(sg2) end
		-- 提示玩家选择要特殊召唤的怪兽
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		local tg=sg:Select(tp,1,1,nil)
		local tc=tg:GetFirst()
		mg1:RemoveCard(tc)
		-- 判断是否使用本卡的效果进行融合召唤（而非连锁素材的效果）
		if sg1:IsContains(tc) and (sg2==nil or not sg2:IsContains(tc) or not Duel.SelectYesNo(tp,ce:GetDescription())) then
			if exmat then
				-- 设定融合素材检查的附加过滤函数（限制卡组·额外卡组素材数）
				aux.FCheckAdditional=c87931906.fcheck
				-- 设定融合素材组选择的附加过滤函数（限制卡组·额外卡组素材数）
				aux.GCheckAdditional=c87931906.gcheck
			end
			-- 让玩家选择融合素材
			local mat1=Duel.SelectFusionMaterial(tp,tc,mg1,nil,chkf)
			-- 重置融合素材检查的附加过滤函数
			aux.FCheckAdditional=nil
			-- 重置融合素材组选择的附加过滤函数
			aux.GCheckAdditional=nil
			tc:SetMaterial(mat1)
			-- 将选定的融合素材送去墓地
			Duel.SendtoGrave(mat1,REASON_EFFECT+REASON_MATERIAL+REASON_FUSION)
			-- 中断当前效果，使后续的特殊召唤处理不与送去墓地同时处理
			Duel.BreakEffect()
			-- 将融合怪兽从额外卡组融合召唤
			Duel.SpecialSummon(tc,SUMMON_TYPE_FUSION,tp,tp,false,false,POS_FACEUP)
		else
			-- 在连锁素材效果下让玩家选择融合素材
			local mat2=Duel.SelectFusionMaterial(tp,tc,mg3,nil,chkf)
			local fop=ce:GetOperation()
			fop(ce,e,tp,tc,mat2)
		end
		tc:CompleteProcedure()
	end
end
