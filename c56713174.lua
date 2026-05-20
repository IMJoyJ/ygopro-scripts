--雷電龍－サンダー・ドラゴン
-- 效果：
-- 这个卡名的①②的效果1回合只能有1次使用其中任意1个。
-- ①：自己·对方回合，把这张卡从手卡丢弃才能发动。从卡组把1只「雷电龙-雷龙」加入手卡。
-- ②：这张卡被除外的场合或者从场上送去墓地的场合才能发动。从卡组把「雷电龙-雷龙」以外的1张「雷龙」卡加入手卡。
function c56713174.initial_effect(c)
	-- ①：自己·对方回合，把这张卡从手卡丢弃才能发动。从卡组把1只「雷电龙-雷龙」加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(56713174,0))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(TIMING_END_PHASE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,56713174)
	e1:SetCost(c56713174.cost)
	e1:SetTarget(c56713174.target)
	e1:SetOperation(c56713174.operation)
	c:RegisterEffect(e1)
	c56713174.discard_effect=e1
	-- ②：这张卡被除外的场合或者从场上送去墓地的场合才能发动。从卡组把「雷电龙-雷龙」以外的1张「雷龙」卡加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(56713174,1))
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_REMOVE)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCountLimit(1,56713174)
	e2:SetTarget(c56713174.thtg)
	e2:SetOperation(c56713174.thop)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EVENT_TO_GRAVE)
	e3:SetCondition(c56713174.thcon)
	c:RegisterEffect(e3)
end
-- ①号效果的代价（Cost）函数：检查自身是否可以丢弃，并执行丢弃操作
function c56713174.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsDiscardable() end
	-- 将自身作为发动代价丢弃送去墓地
	Duel.SendtoGrave(e:GetHandler(),REASON_COST+REASON_DISCARD)
end
-- 过滤条件：卡名为「雷电龙-雷龙」且可以加入手牌
function c56713174.filter(c)
	return c:IsCode(56713174) and c:IsAbleToHand()
end
-- ①号效果的发动准备（Target）函数：检查卡组中是否存在可检索的卡，并设置操作信息
function c56713174.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动准备阶段，检查卡组中是否存在满足过滤条件的卡
	if chk==0 then return Duel.IsExistingMatchingCard(c56713174.filter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息：从卡组将1张卡加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- ①号效果的效果处理（Operation）函数：从卡组将1只「雷电龙-雷龙」加入手牌
function c56713174.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从卡组中选择1张满足过滤条件的卡
	local g=Duel.SelectMatchingCard(tp,c56713174.filter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡片加入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方玩家确认加入手牌的卡片
		Duel.ConfirmCards(1-tp,g)
	end
end
-- ②号效果（送去墓地时）的发动条件：这张卡必须是从场上送去墓地
function c56713174.thcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousLocation(LOCATION_ONFIELD)
end
-- 过滤条件：属于「雷龙」系列、卡名不是「雷电龙-雷龙」且可以加入手牌
function c56713174.thfilter(c)
	return c:IsSetCard(0x11c) and not c:IsCode(56713174) and c:IsAbleToHand()
end
-- ②号效果的发动准备（Target）函数：检查卡组中是否存在可检索的卡，并设置操作信息
function c56713174.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动准备阶段，检查卡组中是否存在满足过滤条件的卡
	if chk==0 then return Duel.IsExistingMatchingCard(c56713174.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息：从卡组将1张卡加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- ②号效果的效果处理（Operation）函数：从卡组将「雷电龙-雷龙」以外的1张「雷龙」卡加入手牌
function c56713174.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从卡组中选择1张满足过滤条件的卡
	local g=Duel.SelectMatchingCard(tp,c56713174.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡片加入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方玩家确认加入手牌的卡片
		Duel.ConfirmCards(1-tp,g)
	end
end
