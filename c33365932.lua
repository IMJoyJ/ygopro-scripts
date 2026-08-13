--ヴォルカニック・バレット
-- 效果：
-- ①：这张卡在墓地存在的场合，1回合1次，支付500基本分才能发动。这张卡在墓地存在的场合，从卡组把1只「火山弹」加入手卡。
function c33365932.initial_effect(c)
	-- ①：这张卡在墓地存在的场合，1回合1次，支付500基本分才能发动。这张卡在墓地存在的场合，从卡组把1只「火山弹」加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(33365932,0))  --"把1只「火山弹」加入手牌"
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_GRAVE)
	e1:SetCountLimit(1)
	e1:SetCost(c33365932.cost)
	e1:SetTarget(c33365932.tg)
	e1:SetOperation(c33365932.op)
	c:RegisterEffect(e1)
end
-- 作为发动代价，支付500基本分；若无法支付则不能发动。
function c33365932.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 效果发动合法性检查：确认玩家能否支付500基本分。
	if chk==0 then return Duel.CheckLPCost(tp,500) end
	-- 实际支付500基本分作为发动代价。
	Duel.PayLPCost(tp,500)
end
-- 定义检索条件：卡名是「火山弹」（卡号33365932），且可以被加入手卡。
function c33365932.filter(c)
	return c:IsCode(33365932) and c:IsAbleToHand()
end
-- 效果发动时确认从卡组存在1只符合条件的「火山弹」，并设置“加入手卡”的操作信息。
function c33365932.tg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 效果发动条件检查：自己卡组中存在至少1只符合条件的「火山弹」。
	if chk==0 then return Duel.IsExistingMatchingCard(c33365932.filter,tp,LOCATION_DECK,0,1,nil) end
	-- 将本次效果处理信息设置为“从卡组将1张卡加入手卡”，用于后续连锁判定（如星尘龙等）。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果处理：若这张卡仍在墓地，则从卡组选1只「火山弹」加入手卡，并让对方确认。
function c33365932.op(e,tp,eg,ep,ev,re,r,rp)
	if not e:GetHandler():IsLocation(LOCATION_GRAVE) then return end
	-- 从自己卡组中获取第一只符合条件的「火山弹」。
	local tc=Duel.GetFirstMatchingCard(c33365932.filter,tp,LOCATION_DECK,0,nil)
	if tc then
		-- 将那只「火山弹」加入持有者的手卡，原因记为效果。
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
		-- 向对方玩家展示加入手卡的卡片，以确认检索内容。
		Duel.ConfirmCards(1-tp,tc)
	end
end
