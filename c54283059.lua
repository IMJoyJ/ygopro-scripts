--平行世界融合
-- 效果：
-- 这张卡发动的回合，自己不能用这张卡的效果以外把怪兽特殊召唤。
-- ①：除外的由「元素英雄」融合怪兽卡决定的自己的融合素材怪兽回到卡组，把那1只融合怪兽从额外卡组融合召唤。
function c54283059.initial_effect(c)
	-- 这张卡发动的回合，自己不能用这张卡的效果以外把怪兽特殊召唤。①：除外的由「元素英雄」融合怪兽卡决定的自己的融合素材怪兽回到卡组，把那1只融合怪兽从额外卡组融合召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCost(c54283059.cost)
	e1:SetTarget(c54283059.target)
	e1:SetOperation(c54283059.activate)
	c:RegisterEffect(e1)
end
-- 检查本回合是否未进行过特殊召唤，并注册本回合不能用此卡以外的效果特殊召唤的誓约效果。
function c54283059.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查本回合玩家是否进行过特殊召唤。
	if chk==0 then return Duel.GetActivityCount(tp,ACTIVITY_SPSUMMON)==0 end
	-- 这张卡发动的回合，自己不能用这张卡的效果以外把怪兽特殊召唤。①：除外的由「元素英雄」融合怪兽卡决定的自己的融合素材怪兽回到卡组，把那1只融合怪兽从额外卡组融合召唤。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetReset(RESET_PHASE+PHASE_END)
	e1:SetLabelObject(e)
	e1:SetTargetRange(1,0)
	e1:SetTarget(c54283059.sumlimit)
	-- 注册不能特殊召唤的玩家效果。
	Duel.RegisterEffect(e1,tp)
end
-- 限制除了当前发动效果（平行世界融合）以外的特殊召唤。
function c54283059.sumlimit(e,c,sump,sumtype,sumpos,targetp,se)
	return e:GetLabelObject()~=se
end
-- 过滤除外状态、表侧表示、可以作为融合素材且能回到卡组的怪兽。
function c54283059.filter0(c)
	return c:IsFaceup() and c:IsType(TYPE_MONSTER) and c:IsCanBeFusionMaterial() and c:IsAbleToDeck()
end
-- 过滤除外状态、表侧表示、可以作为融合素材、能回到卡组且不免疫当前效果影响的怪兽。
function c54283059.filter1(c,e)
	return c:IsFaceup() and c:IsType(TYPE_MONSTER) and c:IsCanBeFusionMaterial() and c:IsAbleToDeck() and not c:IsImmuneToEffect(e)
end
-- 过滤额外卡组中可以用指定素材进行融合召唤的「元素英雄」融合怪兽。
function c54283059.filter2(c,e,tp,m,f,chkf)
	return c:IsType(TYPE_FUSION) and c:IsSetCard(0x3008) and (not f or f(c))
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_FUSION,tp,false,false) and c:CheckFusionMaterial(m,nil,chkf)
end
-- target函数：检查是否存在合法的融合素材和可融合召唤的怪兽，并设置特殊召唤的操作信息。
function c54283059.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local chkf=tp
		-- 获取自己除外区中所有满足条件的可用融合素材怪兽。
		local mg=Duel.GetMatchingGroup(c54283059.filter0,tp,LOCATION_REMOVED,0,nil)
		-- 检查额外卡组中是否存在可以使用除外区素材进行融合召唤的「元素英雄」融合怪兽。
		local res=Duel.IsExistingMatchingCard(c54283059.filter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg,nil,chkf)
		if not res then
			-- 获取玩家受到的连锁素材效果。
			local ce=Duel.GetChainMaterial(tp)
			if ce~=nil then
				local fgroup=ce:GetTarget()
				local mg3=fgroup(ce,e,tp)
				local mf=ce:GetValue()
				-- 检查在连锁素材效果影响下，额外卡组中是否存在可融合召唤的「元素英雄」融合怪兽。
				res=Duel.IsExistingMatchingCard(c54283059.filter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg3,mf,chkf)
			end
		end
		return res
	end
	-- 设置当前连锁的操作信息为从额外卡组特殊召唤1只怪兽。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- activate函数：选择融合怪兽，将除外的融合素材回到卡组，并从额外卡组融合召唤该怪兽。
function c54283059.activate(e,tp,eg,ep,ev,re,r,rp)
	local chkf=tp
	-- 获取自己除外区中所有满足条件且不受此卡效果影响的可用融合素材怪兽。
	local mg=Duel.GetMatchingGroup(c54283059.filter1,tp,LOCATION_REMOVED,0,nil,e)
	-- 获取额外卡组中所有可以使用除外区素材进行融合召唤的「元素英雄」融合怪兽。
	local sg1=Duel.GetMatchingGroup(c54283059.filter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg,nil,chkf)
	local mg3=nil
	local sg2=nil
	-- 获取玩家受到的连锁素材效果。
	local ce=Duel.GetChainMaterial(tp)
	if ce~=nil then
		local fgroup=ce:GetTarget()
		mg3=fgroup(ce,e,tp)
		local mf=ce:GetValue()
		-- 获取在连锁素材效果影响下，额外卡组中所有可融合召唤的「元素英雄」融合怪兽。
		sg2=Duel.GetMatchingGroup(c54283059.filter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg3,mf,chkf)
	end
	if sg1:GetCount()>0 or (sg2~=nil and sg2:GetCount()>0) then
		local sg=sg1:Clone()
		if sg2 then sg:Merge(sg2) end
		-- 提示玩家选择要特殊召唤的怪兽。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		local tg=sg:Select(tp,1,1,nil)
		local tc=tg:GetFirst()
		-- 判断是否使用本卡自身的效果进行融合召唤（而非使用连锁素材的效果）。
		if sg1:IsContains(tc) and (sg2==nil or not sg2:IsContains(tc) or not Duel.SelectYesNo(tp,ce:GetDescription())) then
			-- 让玩家从除外区选择一组满足融合召唤条件的融合素材。
			local mat=Duel.SelectFusionMaterial(tp,tc,mg,nil,chkf)
			tc:SetMaterial(mat)
			-- 选中融合素材并显示选中动画。
			Duel.HintSelection(mat)
			-- 将选中的融合素材怪兽送回持有者卡组并洗牌。
			Duel.SendtoDeck(mat,nil,SEQ_DECKSHUFFLE,REASON_EFFECT+REASON_MATERIAL+REASON_FUSION)
			-- 中断当前效果处理，使后续的特殊召唤不与回到卡组同时处理。
			Duel.BreakEffect()
			-- 将选中的融合怪兽以融合召唤的方式从额外卡组表侧表示特殊召唤。
			Duel.SpecialSummon(tc,SUMMON_TYPE_FUSION,tp,tp,false,false,POS_FACEUP)
		else
			-- 在使用连锁素材效果时，让玩家选择对应的融合素材。
			local mat2=Duel.SelectFusionMaterial(tp,tc,mg3,nil,chkf)
			local fop=ce:GetOperation()
			fop(ce,e,tp,tc,mat2)
		end
		tc:CompleteProcedure()
	end
end
