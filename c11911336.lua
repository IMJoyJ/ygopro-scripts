--大輪の魔導書
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：自己的卡组·墓地·除外状态的4只「灵使」怪兽加入手卡（相同属性最多1只）。那之后，选自己2张手卡回到卡组。
-- ②：把墓地的这张卡除外才能发动。自己的手卡·场上的「灵使」、「凭依装着」怪兽作为融合素材，把1只融合怪兽融合召唤。在那次融合召唤成功时对方不能把魔法·陷阱·怪兽的效果发动。
local s,id,o=GetID()
-- 初始化卡片效果函数
function s.initial_effect(c)
	-- ①：自己的卡组·墓地·除外状态的4只「灵使」怪兽加入手卡（相同属性最多1只）。那之后，选自己2张手卡回到卡组。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_TODECK)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	-- ②：把墓地的这张卡除外才能发动。自己的手卡·场上的「灵使」、「凭依装着」怪兽作为融合素材，把1只融合怪兽融合召唤。在那次融合召唤成功时对方不能把魔法·陷阱·怪兽的效果发动。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,id+o)
	-- 将此卡除外作为cost
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(s.fustg)
	e2:SetOperation(s.fusop)
	c:RegisterEffect(e2)
end
-- 检索过滤器函数，用于筛选「灵使」怪兽
function s.thfilter(c)
	return c:IsSetCard(0xbf) and c:IsType(TYPE_MONSTER) and c:IsFaceupEx() and c:IsAbleToHand()
end
-- 效果①的发动时点处理函数
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取满足条件的「灵使」怪兽组
	local g=Duel.GetMatchingGroup(s.thfilter,tp,LOCATION_DECK+LOCATION_GRAVE+LOCATION_REMOVED,0,nil)
	if chk==0 then return g:GetClassCount(Card.GetAttribute)>=4 end
	-- 设置效果①的处理信息：将4张怪兽送入手卡
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,4,tp,LOCATION_DECK+LOCATION_GRAVE+LOCATION_REMOVED)
	-- 设置效果①的处理信息：将2张手卡送回卡组
	Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,2,tp,LOCATION_HAND)
end
-- 效果①的发动处理函数
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取满足条件的「灵使」怪兽组（排除王家长眠之谷影响）
	local g=Duel.GetMatchingGroup(aux.NecroValleyFilter(s.thfilter),tp,LOCATION_DECK+LOCATION_GRAVE+LOCATION_REMOVED,0,nil)
	if g:GetClassCount(Card.GetAttribute)<4 then return end
	-- 提示玩家选择要送入手卡的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	-- 从符合条件的怪兽中选择4个属性各不相同的怪兽
	local sg=g:SelectSubGroup(tp,aux.dabcheck,false,4,4)
	-- 将选中的怪兽送入手卡
	if Duel.SendtoHand(sg,nil,REASON_EFFECT)>0 then
		-- 确认玩家手牌中的怪兽
		Duel.ConfirmCards(1-tp,sg)
		-- 判断是否满足送回手卡的条件
		if sg:IsExists(Card.IsLocation,1,nil,LOCATION_HAND) and Duel.GetFieldGroupCount(tp,LOCATION_HAND,0)>1 then
			-- 提示玩家选择要送回卡组的手卡
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
			-- 选择2张手卡送回卡组
			local dg=Duel.SelectMatchingCard(tp,Card.IsAbleToDeck,tp,LOCATION_HAND,0,2,2,nil)
			-- 中断当前效果处理
			Duel.BreakEffect()
			-- 洗切玩家手牌
			Duel.ShuffleHand(tp)
			-- 将选中的手卡送回卡组
			Duel.SendtoDeck(dg,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
		end
	end
end
-- 融合素材过滤器函数，用于筛选「灵使」或「凭依装着」怪兽
function s.filter0(c,e)
	return c:IsType(TYPE_MONSTER) and c:IsCanBeFusionMaterial() and not c:IsImmuneToEffect(e) and c:IsFusionSetCard(0xbf,0x10c0)
end
-- 融合怪兽过滤器函数，用于筛选可融合召唤的怪兽
function s.filter2(c,e,tp,m,f,chkf)
	return c:IsType(TYPE_FUSION) and (not f or f(c))
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_FUSION,tp,false,false) and c:CheckFusionMaterial(m,nil,chkf)
end
-- 效果②的发动时点处理函数
function s.fustg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local chkf=tp
		-- 获取玩家当前可用的融合素材
		local mg1=Duel.GetFusionMaterial(tp):Filter(s.filter0,nil,e)
		-- 检查是否存在可融合召唤的怪兽
		local res=Duel.IsExistingMatchingCard(s.filter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg1,nil,chkf)
		if not res then
			-- 获取当前连锁的融合素材效果
			local ce=Duel.GetChainMaterial(tp)
			if ce~=nil then
				local fgroup=ce:GetTarget()
				local mg2=fgroup(ce,e,tp)
				local mf=ce:GetValue()
				-- 检查是否存在可融合召唤的怪兽（使用连锁素材）
				res=Duel.IsExistingMatchingCard(s.filter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg2,mf,chkf)
			end
		end
		return res
	end
	-- 设置效果②的处理信息：特殊召唤1只融合怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- 效果②的发动处理函数
function s.fusop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local chkf=tp
	-- 获取玩家当前可用的融合素材
	local mg1=Duel.GetFusionMaterial(tp):Filter(s.filter0,nil,e)
	-- 获取可融合召唤的怪兽组
	local sg1=Duel.GetMatchingGroup(s.filter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg1,nil,chkf)
	local mg2=nil
	local sg2=nil
	-- 获取当前连锁的融合素材效果
	local ce=Duel.GetChainMaterial(tp)
	if ce~=nil then
		local fgroup=ce:GetTarget()
		mg2=fgroup(ce,e,tp)
		local mf=ce:GetValue()
		-- 获取可融合召唤的怪兽组（使用连锁素材）
		sg2=Duel.GetMatchingGroup(s.filter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg2,mf,chkf)
	end
	if sg1:GetCount()>0 or (sg2~=nil and sg2:GetCount()>0) then
		local sg=sg1:Clone()
		if sg2 then sg:Merge(sg2) end
		-- 提示玩家选择要特殊召唤的融合怪兽
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local tg=sg:Select(tp,1,1,nil)
		local tc=tg:GetFirst()
		-- 注册连锁成功时的处理效果
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_SPSUMMON_SUCCESS)
		e1:SetLabelObject(tc)
		e1:SetCondition(s.sumcon)
		e1:SetOperation(s.sumop)
		-- 注册效果②的连锁成功处理
		Duel.RegisterEffect(e1,tp)
		-- 注册连锁结束时的处理效果
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e2:SetCode(EVENT_CHAIN_END)
		e2:SetLabelObject(e1)
		e2:SetOperation(s.cedop)
		-- 注册效果②的连锁结束处理
		Duel.RegisterEffect(e2,tp)
		-- 判断是否使用原始融合素材
		if sg1:IsContains(tc) and (sg2==nil or not sg2:IsContains(tc) or ce and not Duel.SelectYesNo(tp,ce:GetDescription())) then
			-- 选择融合素材
			local mat1=Duel.SelectFusionMaterial(tp,tc,mg1,nil,chkf)
			tc:SetMaterial(mat1)
			-- 将融合素材送入墓地
			Duel.SendtoGrave(mat1,REASON_EFFECT+REASON_MATERIAL+REASON_FUSION)
			-- 中断当前效果处理
			Duel.BreakEffect()
			-- 特殊召唤融合怪兽
			Duel.SpecialSummon(tc,SUMMON_TYPE_FUSION,tp,tp,false,false,POS_FACEUP)
		elseif ce then
			-- 选择融合素材（使用连锁素材）
			local mat2=Duel.SelectFusionMaterial(tp,tc,mg2,nil,chkf)
			local fop=ce:GetOperation()
			fop(ce,e,tp,tc,mat2)
		end
		tc:CompleteProcedure()
	end
end
-- 连锁成功条件判断函数
function s.sumcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsContains(e:GetLabelObject())
end
-- 连锁成功处理函数
function s.sumop(e,tp,eg,ep,ev,re,r,rp)
	e:SetLabel(1)
	-- 判断当前连锁序号
	if Duel.GetCurrentChain()==0 then
		-- 设置连锁限制直到连锁结束
		Duel.SetChainLimitTillChainEnd(s.chainlm)
	-- 判断当前连锁序号
	elseif Duel.GetCurrentChain()==1 then
		e:GetHandler():RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD,0,1)
		-- 注册连锁中和中断效果的处理
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_CHAINING)
		e1:SetOperation(s.resetop)
		-- 注册连锁中处理
		Duel.RegisterEffect(e1,tp)
		local e2=e1:Clone()
		e2:SetCode(EVENT_BREAK_EFFECT)
		e2:SetReset(RESET_CHAIN)
		-- 注册中断效果处理
		Duel.RegisterEffect(e2,tp)
	end
end
-- 重置标志效果的处理函数
function s.resetop(e,tp,eg,ep,ev,re,r,rp)
	e:GetHandler():ResetFlagEffect(id)
	e:Reset()
end
-- 连锁结束时的处理函数
function s.cedop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查是否满足连锁结束时的处理条件
	if Duel.CheckEvent(EVENT_SPSUMMON_SUCCESS) and e:GetLabelObject():GetLabel()==1 and e:GetHandler():GetFlagEffect(id)~=0 then
		-- 设置连锁限制直到连锁结束
		Duel.SetChainLimitTillChainEnd(s.chainlm)
	end
	e:GetHandler():ResetFlagEffect(id)
	e:Reset()
end
-- 连锁限制函数
function s.chainlm(e,rp,tp)
	return tp==rp
end
