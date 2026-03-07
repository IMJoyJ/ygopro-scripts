--ヴォルカニック・バレット
-- 效果：
-- ①：这张卡在墓地存在的场合，1回合1次，支付500基本分才能发动。这张卡在墓地存在的场合，从卡组把1只「火山弹」加入手卡。
function c33365932.initial_effect(c)
	-- 效果原文内容：①：这张卡在墓地存在的场合，1回合1次，支付500基本分才能发动。这张卡在墓地存在的场合，从卡组把1只「火山弹」加入手卡。
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
-- 规则层面操作：检查玩家是否能支付500基本分并支付
function c33365932.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 规则层面操作：检查玩家是否能支付500基本分
	if chk==0 then return Duel.CheckLPCost(tp,500) end
	-- 规则层面操作：让玩家支付500基本分
	Duel.PayLPCost(tp,500)
end
-- 规则层面操作：定义过滤函数，用于筛选卡号为火山弹且可以送去手卡的卡片
function c33365932.filter(c)
	return c:IsCode(33365932) and c:IsAbleToHand()
end
-- 规则层面操作：检查卡组中是否存在满足条件的火山弹并设置连锁操作信息
function c33365932.tg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 规则层面操作：检查以玩家视角在卡组中是否存在至少1张满足条件的火山弹
	if chk==0 then return Duel.IsExistingMatchingCard(c33365932.filter,tp,LOCATION_DECK,0,1,nil) end
	-- 规则层面操作：设置连锁操作信息，表示将从卡组检索1张火山弹加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 规则层面操作：确认效果发动时卡片位置是否在墓地，若在则检索并加入手牌
function c33365932.op(e,tp,eg,ep,ev,re,r,rp)
	if not e:GetHandler():IsLocation(LOCATION_GRAVE) then return end
	-- 规则层面操作：从卡组中检索满足条件的第一张火山弹
	local tc=Duel.GetFirstMatchingCard(c33365932.filter,tp,LOCATION_DECK,0,nil)
	if tc then
		-- 规则层面操作：将检索到的火山弹以效果原因送去手牌
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
		-- 规则层面操作：给对手确认被送去手牌的火山弹
		Duel.ConfirmCards(1-tp,tc)
	end
end
