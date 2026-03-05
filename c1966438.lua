--雙極の破械神
-- 效果：
-- 自己对「双极之破械神」1回合只能有1次特殊召唤。
-- ①：自己场上的卡被战斗·效果破坏的场合才能发动。这张卡从手卡特殊召唤。
-- ②：这张卡特殊召唤的场合，丢弃1张手卡才能发动。场上1张卡破坏。
-- ③：场上的这张卡被破坏送去墓地的回合的结束阶段才能发动。这张卡从墓地特殊召唤。这个效果特殊召唤的这张卡从场上离开的场合回到卡组最下面。
function c1966438.initial_effect(c)
	c:SetSPSummonOnce(1966438)
	-- 效果原文：①：自己场上的卡被战斗·效果破坏的场合才能发动。这张卡从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(1966438,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_CUSTOM+1966438)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(c1966438.spcon)
	e1:SetTarget(c1966438.sptg)
	e1:SetOperation(c1966438.spop)
	c:RegisterEffect(e1)
	-- 效果原文：②：这张卡特殊召唤的场合，丢弃1张手卡才能发动。场上1张卡破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(1966438,1))
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCost(c1966438.descost)
	e2:SetTarget(c1966438.destg)
	e2:SetOperation(c1966438.desop)
	c:RegisterEffect(e2)
	-- 效果原文：③：场上的这张卡被破坏送去墓地的回合的结束阶段才能发动。这张卡从墓地特殊召唤。这个效果特殊召唤的这张卡从场上离开的场合回到卡组最下面。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e3:SetCode(EVENT_TO_GRAVE)
	e3:SetCondition(c1966438.regcon1)
	e3:SetOperation(c1966438.regop1)
	c:RegisterEffect(e3)
	-- 注册一个在结束阶段触发的效果，用于处理③效果的特殊召唤
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(1966438,2))
	e4:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_PHASE+PHASE_END)
	e4:SetRange(LOCATION_GRAVE)
	e4:SetCountLimit(1)
	e4:SetCondition(c1966438.spcon2)
	e4:SetTarget(c1966438.sptg2)
	e4:SetOperation(c1966438.spop2)
	c:RegisterEffect(e4)
	if not c1966438.global_check then
		c1966438.global_check=true
		-- 创建一个全局持续效果，用于监听卡片被破坏的事件并触发自定义事件
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_DESTROYED)
		ge1:SetCondition(c1966438.regcon)
		ge1:SetOperation(c1966438.regop)
		-- 将全局效果ge1注册到玩家0（通常是游戏开始时的玩家）
		Duel.RegisterEffect(ge1,0)
	end
end
-- 判断卡片被破坏且之前在场上，用于触发③效果
function c1966438.regcon1(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsReason(REASON_DESTROY) and c:IsPreviousLocation(LOCATION_ONFIELD)
end
-- 为卡片注册一个标记，表示其已被破坏并进入墓地
function c1966438.regop1(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	c:RegisterFlagEffect(1966438,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1)
end
-- 过滤函数，用于判断卡片是否因战斗或效果被破坏且之前在场上
function c1966438.spcfilter(c,tp)
	return c:IsReason(REASON_BATTLE+REASON_EFFECT) and c:IsPreviousControler(tp) and c:IsPreviousLocation(LOCATION_ONFIELD)
end
-- 判断是否满足触发条件，即是否有玩家的场上卡被破坏
function c1966438.regcon(e,tp,eg,ep,ev,re,r,rp)
	local v=0
	if eg:IsExists(c1966438.spcfilter,1,nil,0) then v=v+1 end
	if eg:IsExists(c1966438.spcfilter,1,nil,1) then v=v+2 end
	if v==0 then return false end
	e:SetLabel(({0,1,PLAYER_ALL})[v])
	return true
end
-- 触发自定义事件，通知所有玩家有卡片被破坏
function c1966438.regop(e,tp,eg,ep,ev,re,r,rp)
	-- 触发自定义事件，通知所有玩家有卡片被破坏
	Duel.RaiseEvent(eg,EVENT_CUSTOM+1966438,re,r,rp,ep,e:GetLabel())
end
-- 判断是否满足①效果的发动条件，即是否是自己场上的卡被破坏
function c1966438.spcon(e,tp,eg,ep,ev,re,r,rp)
	return ev==tp or ev==PLAYER_ALL
end
-- 设置特殊召唤的处理目标，即自己
function c1966438.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 检查是否有足够的场上空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置操作信息，表示将特殊召唤此卡
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
-- 执行特殊召唤操作
function c1966438.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 将卡片特殊召唤到场上
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 设置丢弃手卡作为②效果的费用
function c1966438.descost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否有可丢弃的手卡
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,nil) end
	-- 丢弃一张手卡
	Duel.DiscardHand(tp,Card.IsDiscardable,1,1,REASON_COST+REASON_DISCARD)
end
-- 设置破坏效果的目标，即场上所有卡
function c1966438.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取场上所有卡的集合
	local g=Duel.GetMatchingGroup(aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
	if chk==0 then return g:GetCount()>0 end
	-- 设置操作信息，表示将破坏这些卡
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 执行破坏操作
function c1966438.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择场上一张卡进行破坏
	local g=Duel.SelectMatchingCard(tp,aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
	if g:GetCount()>0 then
		-- 显示被选为对象的卡
		Duel.HintSelection(g)
		-- 将选中的卡破坏
		Duel.Destroy(g,REASON_EFFECT)
	end
end
-- 判断是否满足③效果的发动条件，即是否拥有标记
function c1966438.spcon2(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetFlagEffect(1966438)>0
end
-- 设置特殊召唤的处理目标，即自己
function c1966438.sptg2(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否有足够的场上空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置操作信息，表示将特殊召唤此卡
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,tp,LOCATION_GRAVE)
end
-- 执行特殊召唤操作
function c1966438.spop2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 判断特殊召唤是否成功
		if Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)~=0 then
			-- 效果原文：这个效果特殊召唤的这张卡从场上离开的场合回到卡组最下面。
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
			e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			e1:SetReset(RESET_EVENT+RESETS_REDIRECT)
			e1:SetValue(LOCATION_DECKBOT)
			c:RegisterEffect(e1)
		end
	end
end
