--補強要員
-- 效果：
-- 这个卡名的①②的效果1回合只能有1次使用其中任意1个。
-- ①：自己从卡组抽出对方场上的卡的数量。那之后，选抽出数量的自己手卡用喜欢的顺序回到卡组下面。
-- ②：这张卡在墓地存在，对方场上的卡数量比自己场上的卡多的场合，结束阶段才能发动。这张卡在自己场上盖放。这个效果盖放的这张卡从场上离开的场合除外。
local s,id,o=GetID()
-- 注册卡片效果：①效果（抽卡并回卡组）和②效果（墓地自身盖放并添加离场除外约束）。
function s.initial_effect(c)
	-- ①：自己从卡组抽出对方场上的卡的数量。那之后，选抽出数量的自己手卡用喜欢的顺序回到卡组下面。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DRAW+CATEGORY_TODECK)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetHintTiming(0,TIMING_END_PHASE)
	e1:SetTarget(s.tg)
	e1:SetOperation(s.act)
	c:RegisterEffect(e1)
	-- ②：这张卡在墓地存在，对方场上的卡数量比自己场上的卡多的场合，结束阶段才能发动。这张卡在自己场上盖放。这个效果盖放的这张卡从场上离开的场合除外。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_SSET)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,id)
	e2:SetHintTiming(TIMING_END_PHASE)
	e2:SetCondition(s.setcon)
	e2:SetTarget(s.settg)
	e2:SetOperation(s.setop)
	c:RegisterEffect(e2)
end
-- ①效果的发动准备与合法性检测：获取对方场上卡片数量，确认玩家是否能抽对应数量的卡，并设置操作信息。
function s.tg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取对方场上的卡片数量。
	local ct=Duel.GetFieldGroupCount(tp,0,LOCATION_ONFIELD)
	-- 步骤0（检测可行性）：检查自己是否能从卡组抽出对方场上卡片数量的卡。
	if chk==0 then return Duel.IsPlayerCanDraw(tp,ct) end
	-- 设置当前连锁的对象玩家为自己。
	Duel.SetTargetPlayer(tp)
	-- 设置操作信息：由自己抽出对方场上卡片数量的卡。
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,ct)
	-- 设置操作信息：将对应数量的手卡送回卡组。
	Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,ct,tp,LOCATION_HAND)
end
-- ①效果的处理：自己抽出对方场上卡片数量的卡，然后选择相同数量的手卡以任意顺序放回卡组最下方。
function s.act(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的目标玩家（自己）。
	local p=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER)
	-- 再次获取对方场上的卡片数量（效果处理时）。
	local d=Duel.GetFieldGroupCount(tp,0,LOCATION_ONFIELD)
	-- 让目标玩家因效果抽出对应数量的卡，并记录实际抽卡的数量。
	local dc=Duel.Draw(p,d,REASON_EFFECT)
	if dc>0 then
		-- 中断当前效果处理，使后续的“放回卡组”与“抽卡”不视为同时处理。
		Duel.BreakEffect()
		-- 提示玩家选择要放回卡组的卡。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
		-- 让玩家从手卡中选择与实际抽出数量相同数量的卡。
		local g=Duel.GetFieldGroup(p,LOCATION_HAND,0):Select(p,dc,dc,nil)
		-- 洗切玩家的手卡。
		Duel.ShuffleHand(tp)
		-- 将选中的卡以玩家喜欢的顺序放回卡组最下方。
		aux.PlaceCardsOnDeckBottom(tp,g)
	end
end
-- ②效果的发动条件：当前为结束阶段，且对方场上的卡片数量比自己场上的卡片数量多。
function s.setcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查当前阶段是否为结束阶段。
	return Duel.GetCurrentPhase()==PHASE_END
		-- 检查对方场上的卡片数量是否大于自己场上的卡片数量。
		and Duel.GetFieldGroupCount(tp,0,LOCATION_ONFIELD)>Duel.GetFieldGroupCount(tp,LOCATION_ONFIELD,0)
end
-- ②效果的发动准备：确认此卡是否可以盖放，并设置操作信息。
function s.settg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsSSetable() end
	-- 设置操作信息：此卡将离开墓地。
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,e:GetHandler(),1,0,0)
end
-- ②效果的处理：将墓地的这张卡在自己场上盖放，并添加“从场上离开的场合除外”的约束。
function s.setop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 若此卡仍存在于墓地，则将其在自己场上盖放。
	if c:IsRelateToEffect(e) and Duel.SSet(tp,c)~=0 then
		-- 这个效果盖放的这张卡从场上离开的场合除外。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_REDIRECT)
		e1:SetValue(LOCATION_REMOVED)
		c:RegisterEffect(e1)
	end
end
