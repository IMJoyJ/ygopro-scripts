--ライトロードの裁き
-- 效果：
-- ①：这张卡回到卡组最上面。
-- ②：这张卡被「光道」怪兽的效果从卡组送去墓地的场合才能发动。从卡组把1只「裁决之龙」加入手卡。
function c66194206.initial_effect(c)
	-- ①：这张卡回到卡组最上面。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TODECK)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c66194206.target)
	e1:SetOperation(c66194206.activate)
	c:RegisterEffect(e1)
	-- ②：这张卡被「光道」怪兽的效果从卡组送去墓地的场合才能发动。从卡组把1只「裁决之龙」加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCondition(c66194206.thcon)
	e2:SetTarget(c66194206.thtg)
	e2:SetOperation(c66194206.thop)
	c:RegisterEffect(e2)
end
-- ①效果的发动准备：检查自身是否能回到卡组，并设置操作信息
function c66194206.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToDeck() end
	-- 设置操作信息为将1张自身卡片送回卡组
	Duel.SetOperationInfo(0,CATEGORY_TODECK,e:GetHandler(),1,0,0)
end
-- ①效果的处理：将自身卡片不送去墓地而是回到卡组最上面
function c66194206.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		c:CancelToGrave()
		-- 将自身卡片以效果原因送回持有者卡组的最上面
		Duel.SendtoDeck(c,nil,SEQ_DECKTOP,REASON_EFFECT)
	end
end
-- 检查发动条件：这张卡之前的位置是卡组，且是由「光道」怪兽的效果因效果送去墓地
function c66194206.thcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousLocation(LOCATION_DECK) and re:IsActiveType(TYPE_MONSTER) and re:GetHandler():IsSetCard(0x38)
		and bit.band(r,REASON_EFFECT)~=0
end
-- 过滤条件：卡名为「裁决之龙」且可以加入手卡
function c66194206.thfilter(c)
	return c:IsCode(57774843) and c:IsAbleToHand()
end
-- ②效果的发动准备：检查卡组是否存在「裁决之龙」，并设置操作信息
function c66194206.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自身卡组是否存在至少1张满足过滤条件的「裁决之龙」
	if chk==0 then return Duel.IsExistingMatchingCard(c66194206.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息为从卡组将1张卡加入手卡
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- ②效果的处理：从卡组将1只「裁决之龙」加入手卡并给对方确认
function c66194206.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取卡组中第一张满足过滤条件的「裁决之龙」
	local tc=Duel.GetFirstMatchingCard(c66194206.thfilter,tp,LOCATION_DECK,0,nil)
	if tc then
		-- 将获取到的卡片以效果原因加入手卡
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
		-- 给对方玩家确认加入手卡的卡片
		Duel.ConfirmCards(1-tp,tc)
	end
end
