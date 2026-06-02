--超電導閃輝プラズマ・ブラスト
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：可以把发动回合的以下效果发动。
-- ●自己回合：从卡组选1只雷族·岩石族怪兽在卡组最上面放置。自己的场上或墓地有雷族·岩石族怪兽的其中任意种存在的场合，可以再把场上1张卡破坏。
-- ●对方回合：自己的场上·墓地·除外状态的1只雷族·岩石族怪兽加入手卡。这个回合是已有怪兽被战斗·效果破坏的场合，也能从卡组选加入手卡的怪兽。
local s,id,o=GetID()
-- 注册卡片效果的初始化函数，包括注册卡片发动效果，以及在此卡尚未注册全局监测效果时注册监测怪兽被破坏事件的全局效果
function s.initial_effect(c)
	-- ①：可以把发动回合的以下效果发动。
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
		-- 这个回合是已有怪兽被战斗·效果破坏的场合，也能从卡组选加入手卡的怪兽。
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_DESTROYED)
		ge1:SetOperation(s.regop)
		-- 注册监测卡片破坏事件的全局系统效果
		Duel.RegisterEffect(ge1,0)
	end
end
-- 被破坏的怪兽卡过滤条件：因战斗或效果被破坏的场上怪兽，或是其他区域被破坏的怪兽
function s.dcfilter(c)
	return c:IsReason(REASON_BATTLE+REASON_EFFECT)
		and c:IsPreviousLocation(LOCATION_MZONE)
		or not c:IsPreviousLocation(LOCATION_MZONE) and c:IsType(TYPE_MONSTER)
end
-- 破坏事件注册操作：若有怪兽被破坏，则为双方玩家注册回合结束时重置的标记效果
function s.regop(e,tp,eg,ep,ev,re,r,rp)
	if eg:IsExists(s.dcfilter,1,nil) then
		-- 注册在本回合内已有怪兽被破坏的标记效果（通过获取破坏操作者或相关玩家来记录）
		Duel.RegisterFlagEffect(rp,id,RESET_PHASE+PHASE_END,0,1)
	end
end
-- 卡组中雷族或岩石族怪兽的过滤条件
function s.tdfilter(c)
	return c:IsRace(RACE_THUNDER+RACE_ROCK)
end
-- 加入手牌的雷族或岩石族怪兽过滤条件：若卡片在卡组中，则必须在当前回合内已有怪兽被破坏的条件下才可以被检索
function s.thfilter(c,tp)
	return c:IsFaceupEx() and c:IsRace(RACE_THUNDER+RACE_ROCK) and c:IsAbleToHand()
		-- 限制条件：只有在当前回合内已有怪兽被破坏的情况下，才允许从卡组中选择怪兽加入手牌
		and (not c:IsLocation(LOCATION_DECK) or Duel.GetFlagEffect(tp,id)>0)
end
-- 卡片发动时的目标检测，区分自己回合（选卡放置在卡组最上方）与对方回合（雷族·岩石族怪兽加入手牌）进行不同条件的检测，并注册相应的操作分类
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		-- 判断当前是否为自己的回合
		if Duel.GetTurnPlayer()==tp then
			-- 在自己回合，检查卡组中是否存在雷族或岩石族怪兽
			return Duel.IsExistingMatchingCard(s.tdfilter,tp,LOCATION_DECK,0,1,nil)
		else
			-- 在对方回合，检查各区域中是否存在可加入手牌的雷族或岩石族怪兽
			return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK+LOCATION_MZONE+LOCATION_GRAVE+LOCATION_REMOVED,0,1,nil,tp)
		end
	end
	-- 效果处理的目标注册阶段，判断当前是否为自己回合
	if Duel.GetTurnPlayer()==tp then
		if e:IsCostChecked() then
			e:SetCategory(CATEGORY_DESTROY)
		end
	else
		if e:IsCostChecked() then
			e:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
		end
		-- 设置在效果处理时将1张指定区域的卡加入手牌的操作信息
		Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK+LOCATION_MZONE+LOCATION_GRAVE+LOCATION_REMOVED)
	end
end
-- 场上或墓地中雷族或岩石族怪兽的过滤条件
function s.cfilter(c)
	return c:IsFaceupEx() and c:IsRace(RACE_THUNDER+RACE_ROCK)
end
-- 卡片发动效果的处理：在自己回合执行卡组放顶并可选择破坏场上1张卡，在对方回合从指定位置将1只雷族或岩石族怪兽加入手牌
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 效果处理开始，判断当前是否为自己回合
	if Duel.GetTurnPlayer()==tp then
		-- 获取卡组中所有符合条件的雷族和岩石族怪兽
		local g=Duel.GetMatchingGroup(s.tdfilter,tp,LOCATION_DECK,0,nil)
		if #g>0 then
			-- 向玩家发送提示，指示选择放置于卡组最上方的卡片
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
			local tc=g:Select(tp,1,1,nil):GetFirst()
			-- 洗切玩家的卡组
			Duel.ShuffleDeck(tp)
			-- 将选择的怪兽卡移动到卡组最上方
			Duel.MoveSequence(tc,SEQ_DECKTOP)
			-- 让玩家确认卡组最上方的1张卡
			Duel.ConfirmDecktop(tp,1)
			-- 检查自己的场上或墓地是否存在雷族或岩石族怪兽
			if Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_MZONE+LOCATION_GRAVE,0,1,nil)
				-- 检查场上是否存在除此卡以外的可以被破坏的卡
				and Duel.IsExistingMatchingCard(aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,aux.ExceptThisCard(e))
				-- 让玩家选择是否执行破坏场上1张卡的效果
				and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then  --"是否把卡破坏？"
				-- 中断当前效果，以进行下一步破坏场上卡片的操作
				Duel.BreakEffect()
				-- 向玩家发送提示，指示选择要破坏的卡片
				Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
				-- 让玩家从场上选择1张除此卡以外的卡
				local sg=Duel.SelectMatchingCard(tp,aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,aux.ExceptThisCard(e))
				-- 因效果破坏选择的卡片
				Duel.Destroy(sg,REASON_EFFECT)
			end
		end
	else
		-- 向玩家发送提示，指示选择要加入手牌的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
		-- 让玩家从卡组、场上、墓地或除外区选择1张雷族或岩石族怪兽，若在墓地选择时受「王家长眠之谷」影响
		local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.thfilter),tp,LOCATION_DECK+LOCATION_MZONE+LOCATION_GRAVE+LOCATION_REMOVED,0,1,1,nil,tp)
		if g:GetCount()>0 then
			-- 将选择的怪兽卡加入手牌
			Duel.SendtoHand(g,nil,REASON_EFFECT)
			-- 向对方玩家展示并确认加入手牌的卡
			Duel.ConfirmCards(1-tp,g)
		end
	end
end
