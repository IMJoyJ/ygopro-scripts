--フュージョン・ミュートリアス
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：从自己的手卡·场上把「秘异三变」融合怪兽卡决定的融合素材怪兽除外，把那1只融合怪兽从额外卡组融合召唤。这个回合对方是已把卡的效果发动的场合，自己的卡组·墓地的怪兽也各能有最多1只作为融合素材。
function c42577802.initial_effect(c)
	-- 这个卡名的卡在1回合只能发动1张。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_REMOVE+CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON+CATEGORY_GRAVE_ACTION)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,42577802+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(c42577802.target)
	e1:SetOperation(c42577802.activate)
	c:RegisterEffect(e1)
	-- 设置一个计数器，用于记录对方在该回合是否发动过卡的效果
	Duel.AddCustomActivityCounter(42577802,ACTIVITY_CHAIN,aux.FALSE)
end
-- 过滤函数，用于筛选可以作为融合素材的怪兽（必须是怪兽卡、可作为融合素材、可除外）
function c42577802.filter0(c)
	return c:IsType(TYPE_MONSTER) and c:IsCanBeFusionMaterial() and c:IsAbleToRemove()
end
-- 过滤函数，用于筛选可以除外的卡（可除外、不被效果免疫）
function c42577802.filter1(c,e)
	return c:IsAbleToRemove() and not c:IsImmuneToEffect(e)
end
-- 过滤函数，用于筛选可以特殊召唤的融合怪兽（必须是融合怪兽、属于秘异三变卡包、可特殊召唤、融合素材满足条件）
function c42577802.filter2(c,e,tp,m,f,chkf)
	return c:IsType(TYPE_FUSION) and c:IsSetCard(0x157) and (not f or f(c))
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_FUSION,tp,false,false) and c:CheckFusionMaterial(m,nil,chkf)
end
-- 额外检查函数，确保融合素材中来自卡组和墓地的怪兽数量不超过1只
function c42577802.fcheck(tp,sg,fc)
	return sg:FilterCount(Card.IsLocation,nil,LOCATION_DECK)<=1 and sg:FilterCount(Card.IsLocation,nil,LOCATION_GRAVE)<=1
end
-- 额外检查函数，确保融合素材中来自卡组和墓地的怪兽数量不超过1只
function c42577802.gcheck(sg)
	return sg:FilterCount(Card.IsLocation,nil,LOCATION_DECK)<=1 and sg:FilterCount(Card.IsLocation,nil,LOCATION_GRAVE)<=1
end
-- 效果处理函数，用于判断是否可以发动此效果
function c42577802.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local chkf=tp
		-- 获取玩家当前可用的融合素材（手卡和场上的怪兽）
		local mg1=Duel.GetFusionMaterial(tp):Filter(c42577802.filter1,nil,e)
		-- 判断对方是否在本回合发动过卡的效果
		if Duel.GetCustomActivityCount(42577802,1-tp,ACTIVITY_CHAIN)~=0 then
			-- 获取玩家卡组和墓地中所有可作为融合素材的怪兽
			local mg2=Duel.GetMatchingGroup(c42577802.filter0,tp,LOCATION_DECK+LOCATION_GRAVE,0,nil)
			if mg2:GetCount()>0 then
				mg1:Merge(mg2)
				-- 设置额外的融合素材检查函数，用于限制卡组和墓地的怪兽数量
				aux.FCheckAdditional=c42577802.fcheck
				-- 设置额外的融合素材检查函数，用于限制卡组和墓地的怪兽数量
				aux.GCheckAdditional=c42577802.gcheck
			end
		end
		-- 检查是否存在满足条件的融合怪兽可以特殊召唤
		local res=Duel.IsExistingMatchingCard(c42577802.filter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg1,nil,chkf)
		-- 清除额外的融合素材检查函数
		aux.FCheckAdditional=nil
		-- 清除额外的融合素材检查函数
		aux.GCheckAdditional=nil
		if not res then
			-- 获取当前连锁中的融合素材效果
			local ce=Duel.GetChainMaterial(tp)
			if ce~=nil then
				local fgroup=ce:GetTarget()
				local mg3=fgroup(ce,e,tp)
				local mf=ce:GetValue()
				-- 检查是否存在满足连锁融合素材条件的融合怪兽
				res=Duel.IsExistingMatchingCard(c42577802.filter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg3,mf,chkf)
			end
		end
		return res
	end
	-- 设置效果处理信息，提示将要特殊召唤融合怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- 效果发动函数，用于执行融合召唤操作
function c42577802.activate(e,tp,eg,ep,ev,re,r,rp)
	local chkf=tp
	-- 获取玩家当前可用的融合素材（手卡和场上的怪兽）
	local mg1=Duel.GetFusionMaterial(tp):Filter(c42577802.filter1,nil,e)
	local exmat=false
	-- 判断对方是否在本回合发动过卡的效果
	if Duel.GetCustomActivityCount(42577802,1-tp,ACTIVITY_CHAIN)~=0 then
		-- 获取玩家卡组和墓地中所有可作为融合素材的怪兽
		local mg2=Duel.GetMatchingGroup(c42577802.filter0,tp,LOCATION_DECK+LOCATION_GRAVE,0,nil)
		if mg2:GetCount()>0 then
			mg1:Merge(mg2)
			exmat=true
		end
	end
	if exmat then
		-- 设置额外的融合素材检查函数，用于限制卡组和墓地的怪兽数量
		aux.FCheckAdditional=c42577802.fcheck
		-- 设置额外的融合素材检查函数，用于限制卡组和墓地的怪兽数量
		aux.GCheckAdditional=c42577802.gcheck
	end
	-- 获取玩家额外卡组中所有满足条件的融合怪兽
	local sg1=Duel.GetMatchingGroup(c42577802.filter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg1,nil,chkf)
	-- 清除额外的融合素材检查函数
	aux.FCheckAdditional=nil
	-- 清除额外的融合素材检查函数
	aux.GCheckAdditional=nil
	local mg3=nil
	local sg2=nil
	-- 获取当前连锁中的融合素材效果
	local ce=Duel.GetChainMaterial(tp)
	if ce~=nil then
		local fgroup=ce:GetTarget()
		mg3=fgroup(ce,e,tp)
		local mf=ce:GetValue()
		-- 获取满足连锁融合素材条件的融合怪兽
		sg2=Duel.GetMatchingGroup(c42577802.filter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg3,mf,chkf)
	end
	if sg1:GetCount()>0 or (sg2~=nil and sg2:GetCount()>0) then
		local sg=sg1:Clone()
		if sg2 then sg:Merge(sg2) end
		-- 提示玩家选择要特殊召唤的融合怪兽
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		local tg=sg:Select(tp,1,1,nil)
		local tc=tg:GetFirst()
		mg1:RemoveCard(tc)
		-- 判断是否使用额外卡组和墓地的怪兽作为融合素材
		if sg1:IsContains(tc) and (sg2==nil or not sg2:IsContains(tc) or not Duel.SelectYesNo(tp,ce:GetDescription())) then
			if exmat then
				-- 设置额外的融合素材检查函数，用于限制卡组和墓地的怪兽数量
				aux.FCheckAdditional=c42577802.fcheck
				-- 设置额外的融合素材检查函数，用于限制卡组和墓地的怪兽数量
				aux.GCheckAdditional=c42577802.gcheck
			end
			-- 选择融合怪兽的融合素材
			local mat1=Duel.SelectFusionMaterial(tp,tc,mg1,nil,chkf)
			-- 清除额外的融合素材检查函数
			aux.FCheckAdditional=nil
			-- 清除额外的融合素材检查函数
			aux.GCheckAdditional=nil
			tc:SetMaterial(mat1)
			-- 将融合素材从场上除外
			Duel.Remove(mat1,POS_FACEUP,REASON_EFFECT+REASON_MATERIAL+REASON_FUSION)
			-- 中断当前效果，使后续处理视为不同时处理
			Duel.BreakEffect()
			-- 将融合怪兽特殊召唤到场上
			Duel.SpecialSummon(tc,SUMMON_TYPE_FUSION,tp,tp,false,false,POS_FACEUP)
		else
			-- 选择融合怪兽的融合素材（来自连锁效果）
			local mat2=Duel.SelectFusionMaterial(tp,tc,mg3,nil,chkf)
			local fop=ce:GetOperation()
			fop(ce,e,tp,tc,mat2)
		end
		tc:CompleteProcedure()
	end
end
