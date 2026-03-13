--絶神鳥シムルグ
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：自己主要阶段，自己对鸟兽族怪兽的召唤·特殊召唤成功的场合，把手卡的这张卡给对方观看才能发动。把1只「斯摩夫」怪兽召唤。
-- ②：这张卡召唤成功的场合，从卡组把1只「斯摩夫」怪兽送去墓地才能发动。从卡组把1张「斯摩夫」魔法·陷阱卡加入手卡。
-- ③：只要这张卡在怪兽区域存在，这张卡的属性也当作「风」使用。
function c52843699.initial_effect(c)
	-- ③：只要这张卡在怪兽区域存在，这张卡的属性也当作「风」使用。
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e0:SetCode(EFFECT_ADD_ATTRIBUTE)
	e0:SetRange(LOCATION_MZONE)
	e0:SetValue(ATTRIBUTE_WIND)
	c:RegisterEffect(e0)
	-- ①：自己主要阶段，自己对鸟兽族怪兽的召唤·特殊召唤成功的场合，把手卡的这张卡给对方观看才能发动。把1只「斯摩夫」怪兽召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(52843699,0))
	e1:SetCategory(CATEGORY_SUMMON)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,52843699)
	e1:SetCost(c52843699.sumcost)
	e1:SetCondition(c52843699.sumcon)
	e1:SetTarget(c52843699.sumtg)
	e1:SetOperation(c52843699.sumop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
	-- ②：这张卡召唤成功的场合，从卡组把1只「斯摩夫」怪兽送去墓地才能发动。从卡组把1张「斯摩夫」魔法·陷阱卡加入手卡。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(52843699,1))
	e3:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_SUMMON_SUCCESS)
	e3:SetCountLimit(1,52843700)
	e3:SetCost(c52843699.cost)
	e3:SetTarget(c52843699.target)
	e3:SetOperation(c52843699.operation)
	c:RegisterEffect(e3)
end
-- 检查手卡的这张卡是否已公开（未公开则不能发动）
function c52843699.sumcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return not e:GetHandler():IsPublic() end
end
-- 过滤函数：判断目标怪兽是否为表侧表示的鸟兽族怪兽且是自己召唤的
function c52843699.sumcfilter(c,tp)
	return c:IsFaceup() and c:IsRace(RACE_WINDBEAST) and c:IsType(TYPE_MONSTER) and c:IsSummonPlayer(tp)
end
-- 效果发动条件：当前回合玩家为发动者，且处于主要阶段1或主要阶段2，并且有满足条件的怪兽被召唤或特殊召唤成功
function c52843699.sumcon(e,tp,eg,ep,ev,re,r,rp)
	-- 当前回合玩家为发动者，且处于主要阶段1或主要阶段2
	return Duel.GetTurnPlayer()==tp and (Duel.GetCurrentPhase()==PHASE_MAIN1 or Duel.GetCurrentPhase()==PHASE_MAIN2)
		and eg:IsExists(c52843699.sumcfilter,1,nil,tp)
end
-- 过滤函数：判断目标卡是否为「斯摩夫」怪兽且可通常召唤
function c52843699.filter(c)
	return c:IsSetCard(0x12d) and c:IsType(TYPE_MONSTER) and c:IsSummonable(true,nil)
end
-- 设置效果处理时要操作的卡片信息：选择1只「斯摩夫」怪兽进行召唤
function c52843699.sumtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查手牌或场上是否存在满足条件的「斯摩夫」怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c52843699.filter,tp,LOCATION_HAND+LOCATION_MZONE,0,1,nil) end
	-- 设置连锁操作信息：将要进行召唤操作
	Duel.SetOperationInfo(0,CATEGORY_SUMMON,nil,1,0,0)
end
-- 效果处理函数：选择并召唤一只「斯摩夫」怪兽
function c52843699.sumop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SUMMON)  --"请选择要召唤的卡"
	-- 从手牌或场上选择满足条件的「斯摩夫」怪兽
	local g=Duel.SelectMatchingCard(tp,c52843699.filter,tp,LOCATION_HAND+LOCATION_MZONE,0,1,1,nil)
	local tc=g:GetFirst()
	if tc then
		-- 执行通常召唤操作
		Duel.Summon(tp,tc,true,nil)
	end
end
-- 过滤函数：判断目标卡是否为「斯摩夫」怪兽且可送入墓地作为费用
function c52843699.cfilter(c)
	return c:IsSetCard(0x12d) and c:IsType(TYPE_MONSTER) and c:IsAbleToGraveAsCost()
end
-- 效果处理函数：支付费用，从卡组选择一只「斯摩夫」怪兽送去墓地
function c52843699.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组是否存在满足条件的「斯摩夫」怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c52843699.cfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 提示玩家选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 从卡组中选择一只「斯摩夫」怪兽送入墓地
	local g=Duel.SelectMatchingCard(tp,c52843699.cfilter,tp,LOCATION_DECK,0,1,1,nil)
	-- 将选中的卡送入墓地作为费用
	Duel.SendtoGrave(g,REASON_COST)
end
-- 过滤函数：判断目标卡是否为「斯摩夫」魔法·陷阱卡且可加入手牌
function c52843699.thfilter(c)
	return c:IsSetCard(0x12d) and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsAbleToHand()
end
-- 设置效果处理时要操作的卡片信息：从卡组选择一张「斯摩夫」魔法·陷阱卡加入手牌
function c52843699.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组是否存在满足条件的「斯摩夫」魔法·陷阱卡
	if chk==0 then return Duel.IsExistingMatchingCard(c52843699.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置连锁操作信息：将要进行加入手牌操作
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果处理函数：从卡组选择一张「斯摩夫」魔法·陷阱卡加入手牌
function c52843699.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从卡组中选择一张「斯摩夫」魔法·陷阱卡
	local g=Duel.SelectMatchingCard(tp,c52843699.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡加入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方确认加入手牌的卡
		Duel.ConfirmCards(1-tp,g)
	end
end
