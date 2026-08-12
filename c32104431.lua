--破壊剣の追憶
-- 效果：
-- ①：从手卡丢弃1张「破坏剑」卡才能发动。从卡组把1只「破坏之剑士」怪兽特殊召唤。
-- ②：把墓地的这张卡除外才能发动。「龙破坏的剑士-破坏之剑士」决定的融合素材怪兽从自己墓地除外，把那1只融合怪兽从额外卡组融合召唤。
function c32104431.initial_effect(c)
	-- ①：从手卡丢弃1张「破坏剑」卡才能发动。从卡组把1只「破坏之剑士」怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCost(c32104431.cost)
	e1:SetTarget(c32104431.target)
	e1:SetOperation(c32104431.operation)
	c:RegisterEffect(e1)
	-- ②：把墓地的这张卡除外才能发动。「龙破坏的剑士-破坏之剑士」决定的融合素材怪兽从自己墓地除外，把那1只融合怪兽从额外卡组融合召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetHintTiming(0,TIMINGS_CHECK_MONSTER)
	e2:SetRange(LOCATION_GRAVE)
	-- 将此卡除外作为费用
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(c32104431.fusiontg)
	e2:SetOperation(c32104431.fusionop)
	c:RegisterEffect(e2)
end
-- 过滤函数：检查手卡中是否存在1张「破坏剑」卡且可丢弃
function c32104431.costfilter(c)
	return c:IsSetCard(0xd6) and c:IsDiscardable()
end
-- 效果发动时的费用处理：检查手卡是否存在满足条件的卡并丢弃1张
function c32104431.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查手卡是否存在满足条件的卡
	if chk==0 then return Duel.IsExistingMatchingCard(c32104431.costfilter,tp,LOCATION_HAND,0,1,e:GetHandler()) end
	-- 丢弃手卡中满足条件的1张卡
	Duel.DiscardHand(tp,c32104431.costfilter,1,1,REASON_COST+REASON_DISCARD)
end
-- 过滤函数：检查卡组中是否存在1只「破坏之剑士」怪兽且可特殊召唤
function c32104431.spfilter(c,e,tp)
	return c:IsSetCard(0xd7) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果发动时的处理：检查场上是否有空位且卡组是否存在满足条件的怪兽
function c32104431.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查场上是否有空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查卡组是否存在满足条件的怪兽
		and Duel.IsExistingMatchingCard(c32104431.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置连锁操作信息：准备特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 效果发动时的处理：选择并特殊召唤1只满足条件的怪兽
function c32104431.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 检查场上是否有空位
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择满足条件的1只怪兽
	local g=Duel.SelectMatchingCard(tp,c32104431.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的怪兽特殊召唤到场上
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 过滤函数：检查墓地中是否存在可作为融合素材的怪兽
function c32104431.filter0(c)
	return c:IsType(TYPE_MONSTER) and c:IsCanBeFusionMaterial() and c:IsAbleToRemove()
end
-- 过滤函数：检查墓地中是否存在可作为融合素材的怪兽且未被效果免疫
function c32104431.filter1(c,e)
	return c:IsType(TYPE_MONSTER) and c:IsCanBeFusionMaterial() and c:IsAbleToRemove() and not c:IsImmuneToEffect(e)
end
-- 过滤函数：检查额外卡组中是否存在可融合召唤的「龙破坏的剑士-破坏之剑士」
function c32104431.filter2(c,e,tp,m,f,chkf)
	return c:IsType(TYPE_FUSION) and c:IsCode(86240887) and (not f or f(c))
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_FUSION,tp,false,false) and c:CheckFusionMaterial(m,nil,chkf)
end
-- 融合召唤效果发动时的处理：检查是否存在满足条件的融合怪兽
function c32104431.fusiontg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local chkf=tp
		-- 获取墓地中所有可作为融合素材的怪兽
		local mg1=Duel.GetMatchingGroup(c32104431.filter0,tp,LOCATION_GRAVE,0,nil)
		-- 检查额外卡组是否存在满足条件的融合怪兽
		local res=Duel.IsExistingMatchingCard(c32104431.filter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg1,nil,chkf)
		if not res then
			-- 获取当前连锁的融合素材效果
			local ce=Duel.GetChainMaterial(tp)
			if ce~=nil then
				local fgroup=ce:GetTarget()
				local mg2=fgroup(ce,e,tp)
				local mf=ce:GetValue()
				-- 检查额外卡组是否存在满足条件的融合怪兽
				res=Duel.IsExistingMatchingCard(c32104431.filter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg2,mf,chkf)
			end
		end
		return res
	end
	-- 设置连锁操作信息：准备特殊召唤1只融合怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
	-- 设置连锁操作信息：准备除外1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,tp,LOCATION_GRAVE)
end
-- 融合召唤效果发动时的处理：选择并融合召唤1只满足条件的融合怪兽
function c32104431.fusionop(e,tp,eg,ep,ev,re,r,rp)
	local chkf=tp
	-- 获取墓地中所有可作为融合素材的怪兽
	local mg1=Duel.GetMatchingGroup(c32104431.filter1,tp,LOCATION_GRAVE,0,nil,e)
	-- 获取额外卡组中所有满足条件的融合怪兽
	local sg1=Duel.GetMatchingGroup(c32104431.filter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg1,nil,chkf)
	local mg2=nil
	local sg2=nil
	-- 获取当前连锁的融合素材效果
	local ce=Duel.GetChainMaterial(tp)
	if ce~=nil then
		local fgroup=ce:GetTarget()
		mg2=fgroup(ce,e,tp)
		local mf=ce:GetValue()
		-- 获取额外卡组中所有满足条件的融合怪兽
		sg2=Duel.GetMatchingGroup(c32104431.filter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg2,mf,chkf)
	end
	if sg1:GetCount()>0 or (sg2~=nil and sg2:GetCount()>0) then
		local sg=sg1:Clone()
		if sg2 then sg:Merge(sg2) end
		-- 提示玩家选择要特殊召唤的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		local tg=sg:Select(tp,1,1,nil)
		local tc=tg:GetFirst()
		-- 判断是否使用原融合素材效果
		if sg1:IsContains(tc) and (sg2==nil or not sg2:IsContains(tc) or not Duel.SelectYesNo(tp,ce:GetDescription())) then
			-- 选择融合召唤所需的融合素材
			local mat1=Duel.SelectFusionMaterial(tp,tc,mg1,nil,chkf)
			tc:SetMaterial(mat1)
			-- 将融合素材从墓地除外
			Duel.Remove(mat1,POS_FACEUP,REASON_EFFECT+REASON_MATERIAL+REASON_FUSION)
			-- 中断当前效果处理
			Duel.BreakEffect()
			-- 将选中的融合怪兽特殊召唤到场上
			Duel.SpecialSummon(tc,SUMMON_TYPE_FUSION,tp,tp,false,false,POS_FACEUP)
		else
			-- 选择融合召唤所需的融合素材
			local mat2=Duel.SelectFusionMaterial(tp,tc,mg2,nil,chkf)
			local fop=ce:GetOperation()
			fop(ce,e,tp,tc,mat2)
		end
		tc:CompleteProcedure()
	end
end
