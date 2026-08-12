--叛逆の堕天使
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：从自己的手卡·场上（表侧表示）把1只「堕天使」怪兽送去墓地才能发动。自己的手卡·场上的怪兽作为融合素材，把1只暗属性融合怪兽融合召唤。那之后，可以让自己基本分回复因为这张卡发动而送去墓地的怪兽的攻击力的数值。
function c54527349.initial_effect(c)
	-- 这个卡名的卡在1回合只能发动1张。①：从自己的手卡·场上（表侧表示）把1只「堕天使」怪兽送去墓地才能发动。自己的手卡·场上的怪兽作为融合素材，把1只暗属性融合怪兽融合召唤。那之后，可以让自己基本分回复因为这张卡发动而送去墓地的怪兽的攻击力的数值。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e1:SetCountLimit(1,54527349+EFFECT_COUNT_CODE_OATH)
	e1:SetCost(c54527349.cost)
	e1:SetTarget(c54527349.target)
	e1:SetOperation(c54527349.activate)
	c:RegisterEffect(e1)
end
-- 过滤不受效果影响的卡片
function c54527349.filter1(c,e)
	return not c:IsImmuneToEffect(e)
end
-- 过滤额外卡组中可以进行融合召唤的暗属性融合怪兽
function c54527349.filter2(c,e,tp,m,f,chkf)
	return c:IsType(TYPE_FUSION) and c:IsAttribute(ATTRIBUTE_DARK) and (not f or f(c))
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_FUSION,tp,false,false) and c:CheckFusionMaterial(m,nil,chkf)
end
-- 过滤手卡·场上可以作为发动Cost送去墓地且送去墓地后仍能进行融合召唤的「堕天使」怪兽
function c54527349.costfilter(c,e,tp)
	local chkf=tp
	-- 获取玩家可用的融合素材
	local mg1=Duel.GetFusionMaterial(tp)
	if mg1:IsContains(c) then mg1:RemoveCard(c) end
	-- 检查额外卡组是否存在可以融合召唤的暗属性融合怪兽
	local res=Duel.IsExistingMatchingCard(c54527349.filter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg1,nil,chkf)
	if not res then
		-- 获取玩家受到的连锁素材效果
		local ce=Duel.GetChainMaterial(tp)
		if ce~=nil then
			local fgroup=ce:GetTarget()
			local mg2=fgroup(ce,e,tp)
			if mg2:IsContains(c) then mg2:RemoveCard(c) end
			local mf=ce:GetValue()
			-- 检查在使用连锁素材效果时，额外卡组是否存在可以融合召唤的暗属性融合怪兽
			res=Duel.IsExistingMatchingCard(c54527349.filter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg2,mf,chkf)
		end
	end
	return (c:IsFaceup() or c:IsLocation(LOCATION_HAND)) and c:IsSetCard(0xef) and c:IsType(TYPE_MONSTER) and c:IsAbleToGraveAsCost() and res
end
-- 效果发动的Cost处理函数
function c54527349.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	e:SetLabel(100,0)
	-- 检查手卡·场上是否存在满足Cost条件的「堕天使」怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c54527349.costfilter,tp,LOCATION_HAND+LOCATION_MZONE,0,1,nil,e,tp) end
	-- 提示玩家选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 让玩家选择1只满足Cost条件的「堕天使」怪兽
	local g=Duel.SelectMatchingCard(tp,c54527349.costfilter,tp,LOCATION_HAND+LOCATION_MZONE,0,1,1,nil,e,tp)
	e:SetLabel(100,g:GetFirst():GetAttack())
	-- 将选择的怪兽作为Cost送去墓地
	Duel.SendtoGrave(g,REASON_COST)
end
-- 效果发动的Target处理函数
function c54527349.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local label,rec=e:GetLabel()
	if chk==0 then
		local chkf=tp
		-- 获取玩家可用的融合素材
		local mg1=Duel.GetFusionMaterial(tp)
		-- 检查额外卡组是否存在可以融合召唤的暗属性融合怪兽
		local res=Duel.IsExistingMatchingCard(c54527349.filter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg1,nil,chkf)
		if not res then
			-- 获取玩家受到的连锁素材效果
			local ce=Duel.GetChainMaterial(tp)
			if ce~=nil then
				local fgroup=ce:GetTarget()
				local mg2=fgroup(ce,e,tp)
				local mf=ce:GetValue()
				-- 检查在使用连锁素材效果时，额外卡组是否存在可以融合召唤的暗属性融合怪兽
				res=Duel.IsExistingMatchingCard(c54527349.filter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg2,mf,chkf)
			end
		end
		e:SetLabel(0,0)
		return label==100 or res
	end
	-- 设置当前连锁的操作信息为从额外卡组特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
	local cat=e:GetCategory()
	if e:IsHasType(EFFECT_TYPE_ACTIVATE) and label==100 and rec>0 then
		e:SetCategory(bit.bor(cat,CATEGORY_RECOVER))
	else
		e:SetCategory(bit.band(cat,bit.bnot(CATEGORY_RECOVER)))
	end
end
-- 效果处理的Activate（发动）函数
function c54527349.activate(e,tp,eg,ep,ev,re,r,rp)
	local chkf=tp
	-- 获取玩家可用且不受效果影响的融合素材
	local mg1=Duel.GetFusionMaterial(tp):Filter(c54527349.filter1,nil,e)
	-- 获取额外卡组中可以使用当前素材融合召唤的暗属性融合怪兽组
	local sg1=Duel.GetMatchingGroup(c54527349.filter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg1,nil,chkf)
	local mg2=nil
	local sg2=nil
	-- 获取玩家受到的连锁素材效果
	local ce=Duel.GetChainMaterial(tp)
	if ce~=nil then
		local fgroup=ce:GetTarget()
		mg2=fgroup(ce,e,tp)
		local mf=ce:GetValue()
		-- 获取在使用连锁素材效果时，额外卡组中可以融合召唤的暗属性融合怪兽组
		sg2=Duel.GetMatchingGroup(c54527349.filter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg2,mf,chkf)
	end
	if sg1:GetCount()>0 or (sg2~=nil and sg2:GetCount()>0) then
		local sg=sg1:Clone()
		if sg2 then sg:Merge(sg2) end
		-- 提示玩家选择要特殊召唤的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		local tg=sg:Select(tp,1,1,nil)
		local tc=tg:GetFirst()
		-- 判断是否使用常规融合素材进行融合召唤
		if sg1:IsContains(tc) and (sg2==nil or not sg2:IsContains(tc) or not Duel.SelectYesNo(tp,ce:GetDescription())) then
			-- 让玩家选择融合怪兽所需的融合素材
			local mat1=Duel.SelectFusionMaterial(tp,tc,mg1,nil,chkf)
			tc:SetMaterial(mat1)
			-- 将融合素材送去墓地
			Duel.SendtoGrave(mat1,REASON_EFFECT+REASON_MATERIAL+REASON_FUSION)
			-- 中断当前效果，使后续的特殊召唤处理与送去墓地不视为同时处理
			Duel.BreakEffect()
			-- 将融合怪兽以融合召唤的方式表侧表示特殊召唤
			Duel.SpecialSummon(tc,SUMMON_TYPE_FUSION,tp,tp,false,false,POS_FACEUP)
		else
			-- 让玩家从连锁素材效果提供的素材中选择融合素材
			local mat2=Duel.SelectFusionMaterial(tp,tc,mg2,nil,chkf)
			local fop=ce:GetOperation()
			fop(ce,e,tp,tc,mat2)
		end
		tc:CompleteProcedure()
		local label,rec=e:GetLabel()
		-- 判断是否满足回复基本分的条件，并询问玩家是否进行回复
		if e:IsHasType(EFFECT_TYPE_ACTIVATE) and label==100 and rec>0 and Duel.SelectYesNo(tp,aux.Stringid(54527349,0)) then  --"是否回复基本分？"
			-- 中断当前效果，使后续的回复基本分处理与融合召唤不视为同时处理
			Duel.BreakEffect()
			-- 回复玩家等同于作为Cost送去墓地的怪兽攻击力数值的基本分
			Duel.Recover(tp,rec,REASON_EFFECT)
		end
	end
end
