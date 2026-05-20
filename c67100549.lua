--烙印凶鳴
-- 效果：
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：融合怪兽被送去自己墓地的回合才能发动。自己的墓地·除外状态的1只融合怪兽特殊召唤。
-- ②：这张卡为让「阿不思的落胤」的效果发动而被送去墓地的回合的结束阶段才能发动。这张卡在自己场上盖放。
function c67100549.initial_effect(c)
	-- 在卡片中注册记载了「阿不思的落胤」卡名
	aux.AddCodeList(c,68468459)
	-- ①：融合怪兽被送去自己墓地的回合才能发动。自己的墓地·除外状态的1只融合怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(67100549,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e1:SetCondition(c67100549.conditon)
	e1:SetTarget(c67100549.target)
	e1:SetOperation(c67100549.activate)
	c:RegisterEffect(e1)
	-- ②：这张卡为让「阿不思的落胤」的效果发动而被送去墓地
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetCondition(c67100549.regcon)
	e2:SetOperation(c67100549.regop)
	c:RegisterEffect(e2)
	-- ②：这张卡为让「阿不思的落胤」的效果发动而被送去墓地的回合的结束阶段才能发动。这张卡在自己场上盖放。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(67100549,1))
	e3:SetCategory(CATEGORY_SSET)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetRange(LOCATION_GRAVE)
	e3:SetCountLimit(1,67100549)
	e3:SetHintTiming(TIMING_END_PHASE)
	e3:SetCondition(c67100549.setcon)
	e3:SetTarget(c67100549.settg)
	e3:SetOperation(c67100549.setop)
	c:RegisterEffect(e3)
	if not c67100549.global_check then
		c67100549.global_check=true
		-- ①：融合怪兽被送去自己墓地的回合才能发动。
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_TO_GRAVE)
		ge1:SetCondition(c67100549.checkcon)
		ge1:SetOperation(c67100549.checkop)
		-- 注册全局环境下的辅助效果，用于检测是否有融合怪兽被送去墓地
		Duel.RegisterEffect(ge1,0)
	end
end
-- 全局检测效果的触发条件：送去墓地的卡中存在融合怪兽
function c67100549.checkcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(Card.IsType,1,nil,TYPE_FUSION)
end
-- 全局检测效果的操作：为融合怪兽被送去墓地的玩家注册对应的回合标识
function c67100549.checkop(e,tp,eg,ep,ev,re,r,rp)
	local g=eg:Filter(Card.IsType,nil,TYPE_FUSION)
	local tc=g:GetFirst()
	while tc do
		-- 检查该融合怪兽的持有者在本回合是否还未注册过融合怪兽送墓的标识
		if Duel.GetFlagEffect(tc:GetControler(),67100549)==0 then
			-- 给该玩家注册一个持续到回合结束的标识，表示本回合有融合怪兽送去其墓地
			Duel.RegisterFlagEffect(tc:GetControler(),67100549,RESET_PHASE+PHASE_END,0,1)
		end
		-- 如果双方玩家都已经注册了该标识，则提前结束循环
		if Duel.GetFlagEffect(0,67100549)>0 and Duel.GetFlagEffect(1,67100549)>0 then
			break
		end
		tc=g:GetNext()
	end
end
-- 效果①的发动条件：本回合有融合怪兽被送去自己墓地
function c67100549.conditon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己是否拥有融合怪兽送墓的回合标识
	return Duel.GetFlagEffect(tp,67100549)>0
end
-- 过滤条件：自己墓地或除外状态的、可以特殊召唤的融合怪兽
function c67100549.spfilter(c,e,tp)
	return (c:IsFaceup() or c:IsLocation(LOCATION_GRAVE)) and c:IsType(TYPE_FUSION) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果①的发动准备（检查怪兽区域空位、是否存在合法目标，并设置特殊召唤的操作信息）
function c67100549.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有空怪兽格，以及墓地或除外状态是否存在可特殊召唤的融合怪兽
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.IsExistingMatchingCard(c67100549.spfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,nil,e,tp) end
	-- 设置特殊召唤的操作信息（从墓地或除外状态特殊召唤1只怪兽）
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE+LOCATION_REMOVED)
end
-- 效果①的处理：选择自己墓地或除外状态的1只融合怪兽特殊召唤
function c67100549.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否有空怪兽格，若无则不处理
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 玩家选择1只自己墓地或除外状态的、满足特殊召唤条件且不受「王家长眠之谷」影响的融合怪兽
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c67100549.spfilter),tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的怪兽以表侧表示特殊召唤到自己场上
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 辅助效果②的触发条件：这张卡作为发动「阿不思的落胤」效果的Cost被送去墓地
function c67100549.regcon(e,tp,eg,ep,ev,re,r,rp)
	-- 获取触发该送墓事件的连锁效果对应的卡片密码
	local code1,code2=Duel.GetChainInfo(ev,CHAININFO_TRIGGERING_CODE,CHAININFO_TRIGGERING_CODE2)
	return e:GetHandler():IsReason(REASON_COST) and re and re:IsActivated() and (code1==68468459 or code2==68468459)
end
-- 辅助效果②的操作：为这张卡自身注册一个持续到回合结束的标识，表示其满足了盖放条件
function c67100549.regop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	c:RegisterFlagEffect(67100549,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1)
end
-- 效果②的发动条件：在结束阶段，且这张卡在本回合因「阿不思的落胤」的效果发动而被送去墓地
function c67100549.setcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查这张卡是否带有满足送墓条件的标识，且当前是否处于结束阶段
	return e:GetHandler():GetFlagEffect(67100549)>0 and Duel.GetCurrentPhase()&PHASE_END~=0
end
-- 效果②的发动准备（检查这张卡是否可以盖放，并设置离开墓地的操作信息）
function c67100549.settg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsSSetable() end
	-- 设置离开墓地的操作信息
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,e:GetHandler(),1,0,0)
end
-- 效果②的处理：将墓地的这张卡在自己场上盖放
function c67100549.setop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 将这张卡在自己场上盖放
		Duel.SSet(tp,c)
	end
end
