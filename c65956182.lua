--暗黒界の登極
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：双方的主要阶段才能发动。从自己的场上·墓地把恶魔族融合怪兽卡决定的融合素材怪兽除外，把那1只融合怪兽从额外卡组融合召唤。「暗黑界」怪兽融合召唤的场合，也能把手卡的怪兽丢弃作为融合素材。
-- ②：这张卡在墓地存在的场合，自己主要阶段才能发动。这张卡加入手卡。那之后，从手卡选1只「暗黑界」怪兽丢弃。
function c65956182.initial_effect(c)
	-- ①：双方的主要阶段才能发动。从自己的场上·墓地把恶魔族融合怪兽卡决定的融合素材怪兽除外，把那1只融合怪兽从额外卡组融合召唤。「暗黑界」怪兽融合召唤的场合，也能把手卡的怪兽丢弃作为融合素材。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(65956182,0))
	e1:SetCategory(CATEGORY_REMOVE+CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON+CATEGORY_HANDES_SELF)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,65956182)
	e1:SetCondition(c65956182.condition)
	e1:SetTarget(c65956182.target)
	e1:SetOperation(c65956182.activate)
	c:RegisterEffect(e1)
	-- ②：这张卡在墓地存在的场合，自己主要阶段才能发动。这张卡加入手卡。那之后，从手卡选1只「暗黑界」怪兽丢弃。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(65956182,1))
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_HANDES_SELF)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,65956183)
	e2:SetTarget(c65956182.thtg)
	e2:SetOperation(c65956182.thop)
	c:RegisterEffect(e2)
end
-- 定义①号效果的发动条件
function c65956182.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前是否为双方的主要阶段
	return Duel.GetCurrentPhase()&(PHASE_MAIN1+PHASE_MAIN2)>0
end
-- 过滤场上可以作为融合素材且能被除外的卡
function c65956182.filter1(c,e)
	return c:IsAbleToRemove() and not c:IsImmuneToEffect(e) and c:IsLocation(LOCATION_ONFIELD)
end
-- 过滤额外卡组中可以进行融合召唤的恶魔族融合怪兽，并处理「暗黑界」怪兽可使用手牌作为素材的规则
function c65956182.filter2(c,e,tp,mg1,dm,f,chkf)
	local mg=mg1:Clone()
	if c:IsSetCard(0x6) then
		mg:Merge(dm)
	end
	return c:IsType(TYPE_FUSION) and c:IsRace(RACE_FIEND) and (not f or f(c))
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_FUSION,tp,false,false) and c:CheckFusionMaterial(mg,nil,chkf)
end
-- 过滤墓地中可以作为融合素材且能被除外的怪兽
function c65956182.filter3(c,e)
	return c:IsType(TYPE_MONSTER) and c:IsCanBeFusionMaterial() and c:IsAbleToRemove() and not c:IsImmuneToEffect(e)
end
-- 过滤手牌中可以作为融合素材且能被丢弃的怪兽
function c65956182.filter4(c,e)
	return c:IsType(TYPE_MONSTER) and c:IsCanBeFusionMaterial() and c:IsDiscardable() and not c:IsImmuneToEffect(e)
end
-- 定义①号效果的发动准备与可行性检查
function c65956182.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local chkf=tp
		-- 获取场上可用的融合素材怪兽
		local mg1=Duel.GetFusionMaterial(tp):Filter(c65956182.filter1,nil,e)
		-- 获取墓地中可作为融合素材除外的怪兽
		local mg2=Duel.GetMatchingGroup(c65956182.filter3,tp,LOCATION_GRAVE,0,nil,e)
		-- 获取手牌中可作为融合素材丢弃的怪兽
		local dg=Duel.GetMatchingGroup(c65956182.filter4,tp,LOCATION_HAND,0,nil,e)
		mg1:Merge(mg2)
		-- 检查额外卡组是否存在可以使用上述素材进行融合召唤的恶魔族融合怪兽
		local res=Duel.IsExistingMatchingCard(c65956182.filter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg1,dg,nil,chkf)
		if not res then
			-- 获取玩家受到的连锁素材效果
			local ce=Duel.GetChainMaterial(tp)
			if ce~=nil then
				local fgroup=ce:GetTarget()
				local mg3=fgroup(ce,e,tp)
				local mf=ce:GetValue()
				-- 在连锁素材效果存在时，检查是否存在合法的融合怪兽
				res=Duel.IsExistingMatchingCard(c65956182.filter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg3,dg,mf,chkf)
			end
		end
		return res
	end
	-- 设置特殊召唤的操作信息（从额外卡组特殊召唤1只怪兽）
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
	-- 设置除外的操作信息（从场上或墓地除外卡片）
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,tp,LOCATION_ONFIELD+LOCATION_GRAVE)
end
-- 定义①号效果的效果处理（融合召唤）
function c65956182.activate(e,tp,eg,ep,ev,re,r,rp)
	local chkf=tp
	-- 获取场上可用的融合素材怪兽
	local mg1=Duel.GetFusionMaterial(tp):Filter(c65956182.filter1,nil,e)
	-- 获取墓地中可作为融合素材除外的怪兽
	local mg2=Duel.GetMatchingGroup(c65956182.filter3,tp,LOCATION_GRAVE,0,nil,e)
	-- 获取手牌中可作为融合素材丢弃的怪兽
	local dg=Duel.GetMatchingGroup(c65956182.filter4,tp,LOCATION_HAND,0,nil,e)
	mg1:Merge(mg2)
	-- 筛选额外卡组中可以使用当前素材融合召唤的恶魔族融合怪兽
	local sg1=Duel.GetMatchingGroup(c65956182.filter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg1,dg,nil,chkf)
	local mg3=nil
	local sg2=nil
	-- 获取玩家受到的连锁素材效果
	local ce=Duel.GetChainMaterial(tp)
	if ce~=nil then
		local fgroup=ce:GetTarget()
		mg3=fgroup(ce,e,tp)
		local mf=ce:GetValue()
		-- 筛选在连锁素材效果下可以融合召唤的恶魔族融合怪兽
		sg2=Duel.GetMatchingGroup(c65956182.filter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg3,dg,mf,chkf)
	end
	if #sg1>0 or (sg2~=nil and #sg2>0) then
		local sg=sg1:Clone()
		if sg2 then sg:Merge(sg2) end
		-- 提示玩家选择要特殊召唤的怪兽
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		local tg=sg:Select(tp,1,1,nil)
		local tc=tg:GetFirst()
		-- 判断是否使用本卡的效果进行融合召唤（而非连锁素材等其他效果）
		if sg1:IsContains(tc) and (sg2==nil or not sg2:IsContains(tc) or not Duel.SelectYesNo(tp,ce:GetDescription())) then
			if tc:IsSetCard(0x6) then mg1:Merge(dg) end
			-- 让玩家选择融合素材
			local mat1=Duel.SelectFusionMaterial(tp,tc,mg1,nil,chkf)
			tc:SetMaterial(mat1)
			-- 遍历选定的融合素材
			for gc in aux.Next(mat1) do
				if gc:IsLocation(LOCATION_HAND) then
					-- 如果素材在手牌，则作为融合素材丢弃送去墓地
					Duel.SendtoGrave(gc,REASON_EFFECT+REASON_DISCARD+REASON_FUSION+REASON_MATERIAL)
				else
					-- 如果素材在场上或墓地，则作为融合素材除外
					Duel.Remove(gc,POS_FACEUP,REASON_EFFECT+REASON_FUSION+REASON_MATERIAL)
				end
			end
			-- 中断当前效果，使后续的特殊召唤不与素材处理同时进行
			Duel.BreakEffect()
			-- 将融合怪兽从额外卡组融合召唤
			Duel.SpecialSummon(tc,SUMMON_TYPE_FUSION,tp,tp,false,false,POS_FACEUP)
		else
			-- 使用连锁素材效果时，让玩家选择对应的融合素材
			local mat2=Duel.SelectFusionMaterial(tp,tc,mg3,nil,chkf)
			local fop=ce:GetOperation()
			fop(ce,e,tp,tc,mat2)
		end
		tc:CompleteProcedure()
	end
end
-- 过滤手牌中可以丢弃的「暗黑界」怪兽
function c65956182.thfilter(c)
	return c:IsDiscardable() and c:IsType(TYPE_MONSTER) and c:IsSetCard(0x6)
end
-- 定义②号效果的发动准备与可行性检查
function c65956182.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsAbleToHand()
		-- 检查手牌中是否存在至少1只可以丢弃的「暗黑界」怪兽
		and Duel.IsExistingMatchingCard(c65956182.thfilter,tp,LOCATION_HAND,0,1,nil) end
	-- 设置回收的操作信息（将墓地的这张卡加入手牌）
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,c,1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_HANDES_SELF,nil,0,tp,1)
end
-- 定义②号效果的效果处理（回收此卡并丢弃1张手牌中的「暗黑界」怪兽）
function c65956182.thop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 如果这张卡仍存在于墓地，则将其加入手牌
	if c:IsRelateToEffect(e) and Duel.SendtoHand(c,nil,REASON_EFFECT)>0 then
		-- 洗切手牌
		Duel.ShuffleHand(tp)
		-- 中断当前效果，使后续的丢弃手牌不与加入手牌同时进行
		Duel.BreakEffect()
		-- 提示玩家选择要丢弃的手牌
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISCARD)  --"请选择要丢弃的手牌"
		-- 从手牌选择1只「暗黑界」怪兽丢弃
		Duel.DiscardHand(tp,c65956182.thfilter,1,1,REASON_EFFECT+REASON_DISCARD)
	end
end
