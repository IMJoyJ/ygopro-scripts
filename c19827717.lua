--死者の生還
-- 效果：
-- 自己的手卡的1张怪兽卡丢弃去墓地。这个回合因为战斗被破坏送去自己的墓地的怪兽1只回合结束的时候回到手卡。
function c19827717.initial_effect(c)
	-- 自己的手卡的1张怪兽卡丢弃去墓地。这个回合因为战斗被破坏送去自己的墓地的怪兽1只回合结束的时候回到手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_GRAVE_ACTION)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCost(c19827717.cost)
	e1:SetOperation(c19827717.activate)
	c:RegisterEffect(e1)
end
-- 代价过滤函数：筛选手卡中可丢弃且可作为代价送去墓地的怪兽卡
function c19827717.costfilter(c)
	return c:IsDiscardable() and c:IsAbleToGraveAsCost() and c:IsType(TYPE_MONSTER)
end
-- 发动代价处理：检查并从手卡丢弃1张怪兽卡送去墓地
function c19827717.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己手卡是否存在至少1张满足代价条件的怪兽卡
	if chk==0 then return Duel.IsExistingMatchingCard(c19827717.costfilter,tp,LOCATION_HAND,0,1,nil) end
	-- 让玩家选择并丢弃手卡中的1张怪兽卡作为代价
	Duel.DiscardHand(tp,c19827717.costfilter,1,1,REASON_COST+REASON_DISCARD)
end
-- 卡片发动效果处理：注册一个持续到回合结束阶段的延迟处理效果
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
	-- 为发动玩家注册结束阶段执行的全局持续效果
	Duel.RegisterEffect(e1,tp)
end
-- 回收对象过滤函数：筛选本回合因战斗破坏送去墓地且可加入手卡的怪兽
function c19827717.filter(c,tid)
	return c:IsAbleToHand() and c:IsType(TYPE_MONSTER) and c:GetTurnID()==tid and c:IsReason(REASON_BATTLE)
end
-- 结束阶段触发条件：检查墓地是否存在符合条件的战破怪兽
function c19827717.retcon(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前回合数以比对怪兽进入墓地的回合
	local tid=Duel.GetTurnCount()
	-- 检查自己墓地是否存在本回合战破送墓且不受王家长眠之谷影响、可回手的怪兽
	return Duel.IsExistingMatchingCard(aux.NecroValleyFilter(c19827717.filter),tp,LOCATION_GRAVE,0,1,nil,tid)
end
-- 结束阶段回收处理：从自己墓地选择1只符合条件的怪兽加入手卡并向对方展示
function c19827717.retop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前回合数用于筛选本回合战破送墓的怪兽
	local tid=Duel.GetTurnCount()
	-- 向玩家显示选择加入手牌卡片的提示信息
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从自己墓地选择1只本回合战破送墓且不受王家长眠之谷影响的怪兽
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c19827717.filter),tp,LOCATION_GRAVE,0,1,1,nil,tid)
	if g:GetCount()>0 then
		-- 以效果原因将选中的怪兽加入持有者手卡
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 将加入手卡的怪兽向对方玩家公开确认
		Duel.ConfirmCards(1-tp,g)
	end
end
