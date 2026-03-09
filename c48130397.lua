--超融合
-- 效果：
-- 不能对应这张卡的发动让魔法·陷阱·怪兽的效果发动。
-- ①：丢弃1张手卡才能发动。自己·对方场上的怪兽作为融合素材，把1只融合怪兽融合召唤。
function c48130397.initial_effect(c)
	-- 创建超融合卡的效果，设置其为发动时点、特殊召唤和融合召唤类别，并设定连锁限制
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e1:SetCost(c48130397.cost)
	e1:SetTarget(c48130397.target)
	e1:SetOperation(c48130397.activate)
	c:RegisterEffect(e1)
end
-- 过滤函数：检查场上正面表示的怪兽是否可以作为融合素材
function c48130397.filter0(c)
	return c:IsFaceup() and c:IsCanBeFusionMaterial()
end
-- 过滤函数：检查场上正面表示的怪兽是否可以作为融合素材且未被效果免疫
function c48130397.filter1(c,e)
	return c:IsFaceup() and c:IsCanBeFusionMaterial() and not c:IsImmuneToEffect(e)
end
-- 过滤函数：检查额外卡组中是否含有可特殊召唤的融合怪兽且满足融合素材条件
function c48130397.filter2(c,e,tp,m,f,chkf)
	return c:IsType(TYPE_FUSION) and (not f or f(c))
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_FUSION,tp,false,false) and c:CheckFusionMaterial(m,nil,chkf)
end
-- 过滤函数：检查场上怪兽是否未被效果免疫
function c48130397.filter3(c,e)
	return c:IsOnField() and not c:IsImmuneToEffect(e)
end
-- 发动时的费用处理：丢弃1张手牌作为代价
function c48130397.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断是否满足丢弃手牌的费用条件
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,e:GetHandler()) end
	-- 执行丢弃1张手牌的操作
	Duel.DiscardHand(tp,Card.IsDiscardable,1,1,REASON_COST+REASON_DISCARD)
end
-- 设定超融合的发动目标，检查是否存在可融合召唤的怪兽并设置连锁限制
function c48130397.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local chkf=tp
		-- 获取玩家当前可用的融合素材组，并筛选出在场上的怪兽
		local mg1=Duel.GetFusionMaterial(tp):Filter(Card.IsOnField,nil)
		-- 获取玩家场上正面表示且可作为融合素材的怪兽
		local mg2=Duel.GetMatchingGroup(c48130397.filter0,tp,0,LOCATION_MZONE,nil)
		mg1:Merge(mg2)
		-- 检查额外卡组中是否存在满足条件的融合怪兽
		local res=Duel.IsExistingMatchingCard(c48130397.filter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg1,nil,chkf)
		if not res then
			-- 获取当前连锁中的融合素材效果
			local ce=Duel.GetChainMaterial(tp)
			if ce~=nil then
				local fgroup=ce:GetTarget()
				local mg3=fgroup(ce,e,tp)
				local mf=ce:GetValue()
				-- 若存在连锁融合素材效果，则再次检查额外卡组中是否含有满足条件的融合怪兽
				res=Duel.IsExistingMatchingCard(c48130397.filter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg3,mf,chkf)
			end
		end
		return res
	end
	-- 设置操作信息，表示将要特殊召唤一只融合怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
	if e:IsHasType(EFFECT_TYPE_ACTIVATE) then
		-- 设置连锁限制为不许连锁任何效果
		Duel.SetChainLimit(aux.FALSE)
	end
end
-- 发动超融合的效果处理函数，选择并特殊召唤融合怪兽
function c48130397.activate(e,tp,eg,ep,ev,re,r,rp)
	local chkf=tp
	-- 获取玩家当前可用的融合素材组，并筛选出未被免疫的怪兽
	local mg1=Duel.GetFusionMaterial(tp):Filter(c48130397.filter3,nil,e)
	-- 获取玩家场上正面表示且可作为融合素材的怪兽（受效果影响）
	local mg2=Duel.GetMatchingGroup(c48130397.filter1,tp,0,LOCATION_MZONE,nil,e)
	mg1:Merge(mg2)
	-- 从额外卡组中筛选出满足条件的融合怪兽
	local sg1=Duel.GetMatchingGroup(c48130397.filter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg1,nil,chkf)
	local mg3=nil
	local sg2=nil
	-- 获取当前连锁中的融合素材效果
	local ce=Duel.GetChainMaterial(tp)
	if ce~=nil then
		local fgroup=ce:GetTarget()
		mg3=fgroup(ce,e,tp)
		local mf=ce:GetValue()
		-- 若存在连锁融合素材效果，则再次从额外卡组中筛选满足条件的融合怪兽
		sg2=Duel.GetMatchingGroup(c48130397.filter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg3,mf,chkf)
	end
	if sg1:GetCount()>0 or (sg2~=nil and sg2:GetCount()>0) then
		local sg=sg1:Clone()
		if sg2 then sg:Merge(sg2) end
		-- 提示玩家选择要特殊召唤的融合怪兽
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		local tg=sg:Select(tp,1,1,nil)
		local tc=tg:GetFirst()
		-- 判断是否使用原融合素材或连锁融合素材进行处理
		if sg1:IsContains(tc) and (sg2==nil or not sg2:IsContains(tc) or not Duel.SelectYesNo(tp,ce:GetDescription())) then
			-- 选择融合怪兽所需的融合素材
			local mat1=Duel.SelectFusionMaterial(tp,tc,mg1,nil,chkf)
			tc:SetMaterial(mat1)
			-- 将融合素材送入墓地
			Duel.SendtoGrave(mat1,REASON_EFFECT+REASON_MATERIAL+REASON_FUSION)
			-- 中断当前效果，使后续效果不同时处理
			Duel.BreakEffect()
			-- 将选定的融合怪兽特殊召唤到场上
			Duel.SpecialSummon(tc,SUMMON_TYPE_FUSION,tp,tp,false,false,POS_FACEUP)
		else
			-- 若使用连锁融合素材，则选择对应的融合素材
			local mat2=Duel.SelectFusionMaterial(tp,tc,mg3,nil,chkf)
			local fop=ce:GetOperation()
			fop(ce,e,tp,tc,mat2)
		end
		tc:CompleteProcedure()
	end
end
