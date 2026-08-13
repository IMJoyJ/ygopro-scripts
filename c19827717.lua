--死者の生還
-- 效果：
-- 自己的手卡的1张怪兽卡丢弃去墓地。这个回合因为战斗被破坏送去自己的墓地的怪兽1只回合结束的时候回到手卡。
function c19827717.initial_effect(c)
	-- 自己的手卡的1张怪兽卡丢弃去墓地。这个回合因为战斗被破坏送去自己的墓地的怪兽1只回合结束的时候回到手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCost(c19827717.cost)
	e1:SetOperation(c19827717.activate)
	c:RegisterEffect(e1)
end
-- 定义发动代价的筛选条件：手卡中的怪兽卡，可以被丢弃且能作为代价送去墓地。
function c19827717.costfilter(c)
	return c:IsDiscardable() and c:IsAbleToGraveAsCost() and c:IsType(TYPE_MONSTER)
end
-- 发动代价处理：检测是否满足代价条件，满足时从手卡丢弃1张怪兽卡作为代价。
function c19827717.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 代价检测阶段：确认自己手卡是否存在至少1张满足代价筛选条件的怪兽卡。
	if chk==0 then return Duel.IsExistingMatchingCard(c19827717.costfilter,tp,LOCATION_HAND,0,1,nil) end
	-- 执行代价：选择并丢弃自己手卡的1张满足条件的怪兽卡去墓地，原因记为代价与丢弃。
	Duel.DiscardHand(tp,c19827717.costfilter,1,1,REASON_COST+REASON_DISCARD)
end
-- 发动成功后创建并注册一个结束阶段触发的延迟效果，用于回收本回合战斗破坏送墓的怪兽。
function c19827717.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 这个回合因为战斗被破坏送去自己的墓地的怪兽1只回合结束的时候回到手卡。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetDescription(aux.Stringid(19827717,0))  --"返回手牌"
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_PHASE+PHASE_END)
	e1:SetCountLimit(1)
	e1:SetCondition(c19827717.retcon)
	e1:SetOperation(c19827717.retop)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将延迟效果注册到当前玩家，使该效果在回合结束阶段能够触发。
	Duel.RegisterEffect(e1,tp)
end
-- 定义可回收的怪兽条件：可以加入手卡、是怪兽卡、是本回合进入墓地且因战斗被破坏。
function c19827717.filter(c,tid)
	return c:IsAbleToHand() and c:IsType(TYPE_MONSTER) and c:GetTurnID()==tid and c:IsReason(REASON_BATTLE)
end
-- 延迟效果发动条件：当前回合自己墓地存在至少1只符合回收条件的怪兽。
function c19827717.retcon(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前回合数，用于限定“这个回合”被战斗破坏送墓的怪兽。
	local tid=Duel.GetTurnCount()
	-- 检查自己墓地是否存在满足条件的怪兽（本回合被战斗破坏且不受王家长眠之谷影响的怪兽）。
	return Duel.IsExistingMatchingCard(aux.NecroValleyFilter(c19827717.filter),tp,LOCATION_GRAVE,0,1,nil,tid)
end
-- 执行回收效果：从自己墓地选择1只符合条件的怪兽加入手卡，并让对方确认。
function c19827717.retop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前回合数，作为筛选本回合被战斗破坏怪兽的参数。
	local tid=Duel.GetTurnCount()
	-- 向玩家显示“请选择要加入手牌的卡”的提示信息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从自己墓地的符合条件的怪兽中选择1只（本回合被战斗破坏、可加入手卡且不受王家长眠之谷影响）。
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c19827717.filter),tp,LOCATION_GRAVE,0,1,1,nil,tid)
	if g:GetCount()>0 then
		-- 将选中的怪兽卡以效果原因送回其持有者的手卡。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 将加入手卡的怪兽卡展示给对方玩家确认。
		Duel.ConfirmCards(1-tp,g)
	end
end
