--死者の生還
-- 效果：
-- 自己的手卡的1张怪兽卡丢弃去墓地。这个回合因为战斗被破坏送去自己的墓地的怪兽1只回合结束的时候回到手卡。
function c19827717.initial_effect(c)
	-- 卡片效果：自己的手卡的1张怪兽卡丢弃去墓地。这个回合因为战斗被破坏送去自己的墓地的怪兽1只回合结束的时候回到手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCost(c19827717.cost)
	e1:SetOperation(c19827717.activate)
	c:RegisterEffect(e1)
end
-- 过滤函数：检查手卡中是否有一张可丢弃且能送入墓地的怪兽卡。
function c19827717.costfilter(c)
	return c:IsDiscardable() and c:IsAbleToGraveAsCost() and c:IsType(TYPE_MONSTER)
end
-- 发动时的费用处理：检查是否有满足条件的怪兽卡并丢弃一张。
function c19827717.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否满足丢弃条件。
	if chk==0 then return Duel.IsExistingMatchingCard(c19827717.costfilter,tp,LOCATION_HAND,0,1,nil) end
	-- 执行丢弃操作，丢弃一张符合条件的怪兽卡。
	Duel.DiscardHand(tp,c19827717.costfilter,1,1,REASON_COST+REASON_DISCARD)
end
-- 发动效果：在结束阶段时触发，检查是否有符合条件的怪兽卡返回手卡。
function c19827717.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 创建并注册一个在结束阶段触发的效果，用于将符合条件的怪兽卡返回手牌。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetDescription(aux.Stringid(19827717,0))  --"返回手牌"
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_PHASE+PHASE_END)
	e1:SetCountLimit(1)
	e1:SetCondition(c19827717.retcon)
	e1:SetOperation(c19827717.retop)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将效果注册到玩家的全局环境。
	Duel.RegisterEffect(e1,tp)
end
-- 过滤函数：检查墓地中的怪兽卡是否在本回合因战斗破坏且可以返回手牌。
function c19827717.filter(c,tid)
	return c:IsAbleToHand() and c:IsType(TYPE_MONSTER) and c:GetTurnID()==tid and c:IsReason(REASON_BATTLE)
end
-- 条件判断：检查是否有满足条件的怪兽卡。
function c19827717.retcon(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前回合数。
	local tid=Duel.GetTurnCount()
	-- 检查是否存在满足条件的怪兽卡。
	return Duel.IsExistingMatchingCard(aux.NecroValleyFilter(c19827717.filter),tp,LOCATION_GRAVE,0,1,nil,tid)
end
-- 处理返回手牌的逻辑：选择并返回符合条件的怪兽卡。
function c19827717.retop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前回合数。
	local tid=Duel.GetTurnCount()
	-- 提示玩家选择要返回手牌的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择满足条件的怪兽卡。
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c19827717.filter),tp,LOCATION_GRAVE,0,1,1,nil,tid)
	if g:GetCount()>0 then
		-- 将选中的怪兽卡送回手牌。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方确认返回手牌的卡。
		Duel.ConfirmCards(1-tp,g)
	end
end
