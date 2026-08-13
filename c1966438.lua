--雙極の破械神
-- 效果：
-- 自己对「双极之破械神」1回合只能有1次特殊召唤。
-- ①：自己场上的卡被战斗·效果破坏的场合才能发动。这张卡从手卡特殊召唤。
-- ②：这张卡特殊召唤的场合，丢弃1张手卡才能发动。场上1张卡破坏。
-- ③：场上的这张卡被破坏送去墓地的回合的结束阶段才能发动。这张卡从墓地特殊召唤。这个效果特殊召唤的这张卡从场上离开的场合回到卡组最下面。
function c1966438.initial_effect(c)
	c:SetSPSummonOnce(1966438)
	-- ①：自己场上的卡被战斗·效果破坏的场合才能发动。这张卡从手卡特殊召唤。
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
	-- ②：这张卡特殊召唤的场合，丢弃1张手卡才能发动。场上1张卡破坏。
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
	-- ③：场上的这张卡被破坏送去墓地。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e3:SetCode(EVENT_TO_GRAVE)
	e3:SetCondition(c1966438.regcon1)
	e3:SetOperation(c1966438.regop1)
	c:RegisterEffect(e3)
	-- ③：场上的这张卡被破坏送去墓地的回合的结束阶段才能发动。这张卡从墓地特殊召唤。这个效果特殊召唤的这张卡从场上离开的场合回到卡组最下面。
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
		-- ①：自己场上的卡被战斗·效果破坏的场合。
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_DESTROYED)
		ge1:SetCondition(c1966438.regcon)
		ge1:SetOperation(c1966438.regop)
		-- 将监视“场上卡片被破坏”的全局效果注册到游戏（由玩家0持有），使双方场上的破坏事件都能触发此卡的①条件。
		Duel.RegisterEffect(ge1,0)
	end
end
-- 判断这张卡被送去墓地是否因为破坏且原本在场上，即确认“场上的这张卡被破坏送去墓地”的事实。
function c1966438.regcon1(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsReason(REASON_DESTROY) and c:IsPreviousLocation(LOCATION_ONFIELD)
end
-- 给这张卡添加1966438标记，持续到本回合结束阶段，用于供③在结束阶段判断是否可以发动。
function c1966438.regop1(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	c:RegisterFlagEffect(1966438,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1)
end
-- 过滤函数：判断被破坏的卡是玩家tp场上的卡且破坏原因为战斗或效果，用于筛选“自己场上的卡被战斗·效果破坏”的事件。
function c1966438.spcfilter(c,tp)
	return c:IsReason(REASON_BATTLE+REASON_EFFECT) and c:IsPreviousControler(tp) and c:IsPreviousLocation(LOCATION_ONFIELD)
end
-- 监视条件：根据被破坏卡中属于玩家0/1的符合条件的卡，设置标签（0/1/双方），以便正确通知对应的手牌此卡发动①。
function c1966438.regcon(e,tp,eg,ep,ev,re,r,rp)
	local v=0
	if eg:IsExists(c1966438.spcfilter,1,nil,0) then v=v+1 end
	if eg:IsExists(c1966438.spcfilter,1,nil,1) then v=v+2 end
	if v==0 then return false end
	e:SetLabel(({0,1,PLAYER_ALL})[v])
	return true
end
-- 当满足条件时，用被破坏的卡组触发自定义事件，并将记录的玩家信息传入事件，让手牌中的此卡感知到自己场上的卡被破坏。
function c1966438.regop(e,tp,eg,ep,ev,re,r,rp)
	-- 以被破坏的卡组为对象触发EVENT_CUSTOM+1966438自定义事件，传递本次破坏的玩家归属信息。
	Duel.RaiseEvent(eg,EVENT_CUSTOM+1966438,re,r,rp,ep,e:GetLabel())
end
-- e1的发动条件：检查自定义事件携带的玩家参数是否为当前玩家或双方，确保只有在自己场上的卡被破坏时才能发动。
function c1966438.spcon(e,tp,eg,ep,ev,re,r,rp)
	return ev==tp or ev==PLAYER_ALL
end
-- e1的发动目标：检查自己场上是否有可用怪兽区域且这张卡能够被特殊召唤，满足则准备发动①。
function c1966438.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 检查自己场上是否有可用的怪兽区域。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设定操作信息：本效果将特殊召唤这张卡，供其他卡进行连锁判定。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
-- e1的效果处理：若这张卡仍与此效果相关，则将它从手卡特殊召唤到自己的怪兽区。
function c1966438.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 将这张卡以表侧攻击表示特殊召唤到自己场上。
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- e2的发动代价：从手牌丢弃1张卡作为发动代价。
function c1966438.descost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查手牌中是否存在至少1张可以丢弃的卡。
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,nil) end
	-- 从手牌选择1张卡丢弃（作为cost）。
	Duel.DiscardHand(tp,Card.IsDiscardable,1,1,REASON_COST+REASON_DISCARD)
end
-- e2的发动目标：获取场上所有卡作为可破坏对象，检查是否存在至少1张卡可以破坏。
function c1966438.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取场上双方的怪兽区和魔法陷阱区的所有卡。
	local g=Duel.GetMatchingGroup(aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
	if chk==0 then return g:GetCount()>0 end
	-- 设定操作信息：本效果将破坏1张卡（目标集合为场上所有卡），用于连锁判定。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- e2的效果处理：从场上选择1张卡并破坏。
function c1966438.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 显示“请选择要破坏的卡”的提示文字。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 从场上所有卡中选择1张卡作为破坏对象。
	local g=Duel.SelectMatchingCard(tp,aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
	if g:GetCount()>0 then
		-- 显示选中卡片的对象动画，并标记其为本效果的对象。
		Duel.HintSelection(g)
		-- 以效果破坏方式破坏选中的卡。
		Duel.Destroy(g,REASON_EFFECT)
	end
end
-- e4的发动条件：这张卡带有1966438标记，即本回合曾被破坏送去墓地，才允许在结束阶段发动③。
function c1966438.spcon2(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetFlagEffect(1966438)>0
end
-- e4的发动目标：确认自己场上有空位且这张卡能够从墓地特殊召唤，满足则准备发动③。
function c1966438.sptg2(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有可用的怪兽区域。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设定操作信息：本效果将从墓地特殊召唤这张卡。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,tp,LOCATION_GRAVE)
end
-- e4的效果处理：若这张卡仍在墓地且与此效果相关，则将其特殊召唤；若成功，则附加“离场时回到卡组最下面”的效果。
function c1966438.spop2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 执行特殊召唤；若特殊召唤成功，则给这张卡设置离场时回到卡组最下面的效果。
		if Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)~=0 then
			-- 这个效果特殊召唤的这张卡从场上离开的场合回到卡组最下面。
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
