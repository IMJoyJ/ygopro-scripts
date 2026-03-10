--武神器－ヤサカニ
-- 效果：
-- 自己的主要阶段2，把这张卡从手卡送去墓地才能发动。从卡组把1只名字带有「武神」的怪兽加入手卡。这个效果发动的回合，自己不能把名字带有「武神」的卡以外的魔法·陷阱·效果怪兽的效果发动。「武神器-八尺琼」的效果1回合只能使用1次。
function c50474354.initial_effect(c)
	-- 效果原文内容：自己的主要阶段2，把这张卡从手卡送去墓地才能发动。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(50474354,0))  --"检索"
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,50474354)
	e1:SetCondition(c50474354.condition)
	e1:SetCost(c50474354.cost)
	e1:SetTarget(c50474354.target)
	e1:SetOperation(c50474354.operation)
	c:RegisterEffect(e1)
	-- 设置操作类型为发动效果、代号为50474354的计数器，用于限制每回合只能发动一次效果
	Duel.AddCustomActivityCounter(50474354,ACTIVITY_CHAIN,c50474354.chainfilter)
end
-- 过滤函数，判断是否为名字带有「武神」的卡
function c50474354.chainfilter(re,tp,cid)
	return re:GetHandler():IsSetCard(0x88)
end
-- 效果原文内容：自己的主要阶段2
function c50474354.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检查当前阶段是否为主要阶段2
	return Duel.GetCurrentPhase()==PHASE_MAIN2
end
-- 效果原文内容：把这张卡从手卡送去墓地才能发动。
function c50474354.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 检查是否满足发动条件：本回合未发动过名字带有「武神」的卡的效果且自身可以作为墓地代价
	if chk==0 then return Duel.GetCustomActivityCount(50474354,tp,ACTIVITY_CHAIN)==0 and c:IsAbleToGraveAsCost() end
	-- 将自身送去墓地作为发动代价
	Duel.SendtoGrave(c,REASON_COST)
	-- 效果原文内容：这个效果发动的回合，自己不能把名字带有「武神」的卡以外的魔法·陷阱·效果怪兽的效果发动。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e1:SetCode(EFFECT_CANNOT_ACTIVATE)
	e1:SetTargetRange(1,0)
	e1:SetValue(c50474354.aclimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 注册一个影响玩家的永续型效果，使对方不能发动非「武神」卡的效果
	Duel.RegisterEffect(e1,tp)
end
-- 效果原文内容：「武神器-八尺琼」的效果1回合只能使用1次。
function c50474354.aclimit(e,re,tp)
	return not re:GetHandler():IsSetCard(0x88)
end
-- 过滤函数，筛选名字带有「武神」的怪兽
function c50474354.filter(c)
	return c:IsSetCard(0x88) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
-- 效果原文内容：从卡组把1只名字带有「武神」的怪兽加入手卡。
function c50474354.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否在卡组中存在满足条件的卡片
	if chk==0 then return Duel.IsExistingMatchingCard(c50474354.filter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置连锁操作信息，表示将要从卡组检索一张名字带有「武神」的怪兽加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果原文内容：从卡组把1只名字带有「武神」的怪兽加入手卡。
function c50474354.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择满足条件的一张卡
	local g=Duel.SelectMatchingCard(tp,c50474354.filter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡加入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 确认对方查看了加入手牌的卡
		Duel.ConfirmCards(1-tp,g)
	end
end
