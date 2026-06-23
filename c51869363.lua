--超電導閃輝プラズマ・ブラスト
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：可以把发动回合的以下效果发动。
-- ●自己回合：从卡组选1只雷族·岩石族怪兽在卡组最上面放置。自己的场上或墓地有雷族·岩石族怪兽的其中任意种存在的场合，可以再把场上1张卡破坏。
-- ●对方回合：自己的场上·墓地·除外状态的1只雷族·岩石族怪兽加入手卡。这个回合是已有怪兽被战斗·效果破坏的场合，也能从卡组选加入手卡的怪兽。
local s,id,o=GetID()
-- 初始化卡片效果，注册此卡的发动效果，并注册全局怪兽被破坏的事件监测效果
function s.initial_effect(c)
	-- 这个卡名的卡在1回合只能发动1张。①：可以把发动回合的以下效果发动。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"发动"
	e1:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND+CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	if not s.global_check then
		s.global_check=true
		-- 这个回合是已有怪兽被战斗·效果破坏的场合，也能从卡组选加入手卡的怪兽
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_DESTROYED)
		ge1:SetOperation(s.regop)
		-- 在全局环境注册怪兽被破坏的监听效果
		Duel.RegisterEffect(ge1,0)
	end
end
-- 过滤被战斗或效果破坏的怪兽的条件函数
function s.dcfilter(c)
	return c:IsReason(REASON_BATTLE+REASON_EFFECT)
		and c:IsPreviousLocation(LOCATION_MZONE)
		or not c:IsPreviousLocation(LOCATION_MZONE) and c:IsType(TYPE_MONSTER)
end
-- 当有怪兽被破坏时，在全局注册一个本回合怪兽被破坏的标记效果
function s.regop(e,tp,eg,ep,ev,re,r,rp)
	if eg:IsExists(s.dcfilter,1,nil) then
		-- 注册直到回合结束时有效的全局怪兽被破坏标记
		Duel.RegisterFlagEffect(0,id,RESET_PHASE+PHASE_END,0,1)
	end
end
-- 过滤雷族·岩石族怪兽的条件函数
function s.tdfilter(c)
	return c:IsRace(RACE_THUNDER+RACE_ROCK)
end
-- 过滤可以加入手卡的雷族·岩石族怪兽的条件函数，若是从卡组检索则要求本回合有怪兽被破坏
function s.thfilter(c)
	return c:IsFaceupEx() and c:IsRace(RACE_THUNDER+RACE_ROCK) and c:IsAbleToHand()
		-- 判断目标怪兽是否不在卡组中，或者本回合有怪兽被破坏
		and (not c:IsLocation(LOCATION_DECK) or Duel.GetFlagEffect(0,id)>0)
end
-- 效果的发动目标，根据当前是自己还是对方的回合来分别进行条件判断与分类设置
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		-- 判断当前是否为自己的回合
		if Duel.GetTurnPlayer()==tp then
			-- 检查自己卡组是否存在至少1只雷族·岩石族怪兽
			return Duel.IsExistingMatchingCard(s.tdfilter,tp,LOCATION_DECK,0,1,nil)
		else
			-- 检查卡组、场上、墓地、除外状态是否存在可以加入手卡的雷族·岩石族怪兽
			return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK+LOCATION_MZONE+LOCATION_GRAVE+LOCATION_REMOVED,0,1,nil)
		end
	end
	-- 判断当前是否为自己的回合
	if Duel.GetTurnPlayer()==tp then
		if e:IsCostChecked() then
			e:SetCategory(CATEGORY_DESTROY)
		end
	else
		if e:IsCostChecked() then
			e:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
		end
		-- 设置效果处理信息为将卡组、场上、墓地或除外状态的1张卡加入手卡
		Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK+LOCATION_MZONE+LOCATION_GRAVE+LOCATION_REMOVED)
	end
end
-- 过滤场上或墓地中表侧表示的雷族·岩石族怪兽的条件函数
function s.cfilter(c)
	return c:IsFaceupEx() and c:IsRace(RACE_THUNDER+RACE_ROCK)
end
-- 效果的实际处理，根据当前是自己还是对方的回合来分别执行对应效果的操作
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前是否为自己的回合
	if Duel.GetTurnPlayer()==tp then
		-- 获取卡组中所有的雷族·岩石族怪兽
		local g=Duel.GetMatchingGroup(s.tdfilter,tp,LOCATION_DECK,0,nil)
		if #g>0 then
			-- 提示玩家选择要放置到卡组最上面的卡片
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
			local tc=g:Select(tp,1,1,nil):GetFirst()
			-- 洗切自己卡组
			Duel.ShuffleDeck(tp)
			-- 将选择的怪兽放置在卡组最上面
			Duel.MoveSequence(tc,SEQ_DECKTOP)
			-- 确认自己卡组最上面的一张卡
			Duel.ConfirmDecktop(tp,1)
			-- 检查自己场上或墓地是否有雷族·岩石族怪兽存在
			if Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_MZONE+LOCATION_GRAVE,0,1,nil)
				-- 且场上存在至少1张除此卡以外的卡
				and Duel.IsExistingMatchingCard(aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,aux.ExceptThisCard(e))
				-- 让玩家选择是否把场上的卡破坏
				and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then  --"是否把卡破坏？"
				-- 使后续的破坏处理与之前的卡组放置处理不视为同时进行
				Duel.BreakEffect()
				-- 提示玩家选择要破坏的卡
				Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
				-- 从场上选择1张要破坏的卡
				local sg=Duel.SelectMatchingCard(tp,aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,aux.ExceptThisCard(e))
				-- 将选择的卡破坏
				Duel.Destroy(sg,REASON_EFFECT)
			end
		end
	else
		-- 提示玩家选择要加入手卡的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
		-- 选择卡组、场上、墓地或除外状态的1只雷族·岩石族怪兽，并过滤受「王家之谷」影响的卡
		local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.thfilter),tp,LOCATION_DECK+LOCATION_MZONE+LOCATION_GRAVE+LOCATION_REMOVED,0,1,1,nil)
		if g:GetCount()>0 then
			-- 将选择的怪兽加入手卡
			Duel.SendtoHand(g,nil,REASON_EFFECT)
			-- 将这些卡给对方确认
			Duel.ConfirmCards(1-tp,g)
		end
	end
end
