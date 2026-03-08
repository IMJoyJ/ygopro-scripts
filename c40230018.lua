--魔導書庫クレッセン
-- 效果：
-- 自己墓地没有名字带有「魔导书」的魔法卡存在的场合才能发动。从卡组选名字带有「魔导书」的魔法卡3种类给对方观看，对方从那之中随机选1张。对方选的1张卡加入自己手卡，剩下的卡回到卡组。「魔导书库 科瑞森」在1回合只能发动1张，这张卡发动的回合，自己不能把名字带有「魔导书」的卡以外的魔法卡发动。
function c40230018.initial_effect(c)
	-- 效果原文内容：自己墓地没有名字带有「魔导书」的魔法卡存在的场合才能发动。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(40230018,0))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,40230018+EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(c40230018.condition)
	e1:SetCost(c40230018.cost)
	e1:SetTarget(c40230018.target)
	e1:SetOperation(c40230018.operation)
	c:RegisterEffect(e1)
	-- 设置发动次数限制为1次，且不能在发动后再次发动。
	Duel.AddCustomActivityCounter(40230018,ACTIVITY_CHAIN,c40230018.chainfilter)
end
-- 过滤函数，用于判断是否为「魔导书」系列的魔法卡。
function c40230018.chainfilter(re,tp,cid)
	return not (re:IsHasType(EFFECT_TYPE_ACTIVATE) and re:IsActiveType(TYPE_SPELL) and not re:GetHandler():IsSetCard(0x106e))
end
-- 判断是否为「魔导书」系列的魔法卡。
function c40230018.cfilter(c)
	return c:IsSetCard(0x106e) and c:IsType(TYPE_SPELL)
end
-- 判断自己墓地是否存在「魔导书」系列的魔法卡。
function c40230018.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 判断自己墓地是否存在「魔导书」系列的魔法卡。
	return not Duel.IsExistingMatchingCard(c40230018.cfilter,tp,LOCATION_GRAVE,0,1,nil)
end
-- 设置发动时的费用，限制只能发动一次。
function c40230018.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断是否为第一次发动。
	if chk==0 then return Duel.GetCustomActivityCount(40230018,tp,ACTIVITY_CHAIN)==0 end
	-- 创建并注册一个禁止发动魔法卡的效果。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e1:SetCode(EFFECT_CANNOT_ACTIVATE)
	e1:SetTargetRange(1,0)
	e1:SetValue(c40230018.aclimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将效果注册给玩家。
	Duel.RegisterEffect(e1,tp)
end
-- 判断是否为非「魔导书」系列的魔法卡发动。
function c40230018.aclimit(e,re,tp)
	return re:IsHasType(EFFECT_TYPE_ACTIVATE) and re:IsActiveType(TYPE_SPELL) and not re:GetHandler():IsSetCard(0x106e)
end
-- 过滤函数，用于筛选「魔导书」系列的魔法卡。
function c40230018.filter(c)
	return c:IsSetCard(0x106e) and c:IsType(TYPE_SPELL) and c:IsAbleToHand()
end
-- 设置发动时的处理信息。
function c40230018.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		-- 获取满足条件的卡组卡片。
		local g=Duel.GetMatchingGroup(c40230018.filter,tp,LOCATION_DECK,0,nil)
		return g:GetClassCount(Card.GetCode)>=3
	end
	-- 设置操作信息，用于确定效果处理时要处理的卡。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,0,LOCATION_DECK)
end
-- 处理效果的发动。
function c40230018.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取满足条件的卡组卡片。
	local g=Duel.GetMatchingGroup(c40230018.filter,tp,LOCATION_DECK,0,nil)
	if g:GetClassCount(Card.GetCode)>=3 then
		-- 提示玩家选择要给对方确认的卡。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)  --"请选择给对方确认的卡"
		-- 从满足条件的卡中选择3张不同卡名的卡。
		local sg1=g:SelectSubGroup(tp,aux.dncheck,false,3,3)
		-- 向对方确认选择的卡。
		Duel.ConfirmCards(1-tp,sg1)
		-- 洗切自己的卡组。
		Duel.ShuffleDeck(tp)
		-- 提示对方选择要加入手牌的卡。
		Duel.Hint(HINT_SELECTMSG,1-tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
		local tg=sg1:Select(1-tp,1,1,nil)
		local tc=tg:GetFirst()
		tc:SetStatus(STATUS_TO_HAND_WITHOUT_CONFIRM,true)
		-- 将选择的卡加入手牌。
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end
