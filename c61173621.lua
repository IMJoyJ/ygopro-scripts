--エッジインプ・チェーン
-- 效果：
-- 这个卡名的①②的效果1回合只能有1次使用其中任意1个。
-- ①：这张卡的攻击宣言时才能发动。从卡组把1只「锋利小鬼·链子」加入手卡。
-- ②：这张卡从手卡·场上送去墓地的场合才能发动。从卡组把1张「魔玩具」卡加入手卡。
function c61173621.initial_effect(c)
	-- ①：这张卡的攻击宣言时才能发动。从卡组把1只「锋利小鬼·链子」加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(61173621,0))  --"从卡组把1只「锋利小鬼·链子」加入手卡"
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetCode(EVENT_ATTACK_ANNOUNCE)
	e1:SetCountLimit(1,61173621)
	e1:SetTarget(c61173621.target)
	e1:SetOperation(c61173621.operation)
	c:RegisterEffect(e1)
	-- ②：这张卡从手卡·场上送去墓地的场合才能发动。从卡组把1张「魔玩具」卡加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(61173621,1))  --"从卡组把1张「魔玩具」卡加入手卡"
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetCountLimit(1,61173621)
	e2:SetCondition(c61173621.thcon)
	e2:SetTarget(c61173621.thtg)
	e2:SetOperation(c61173621.thop)
	c:RegisterEffect(e2)
end
-- 过滤卡组中卡名为「锋利小鬼·链子」且可以加入手牌的卡片
function c61173621.filter(c)
	return c:IsCode(61173621) and c:IsAbleToHand()
end
-- 效果①的发动准备与检测（检查卡组中是否存在「锋利小鬼·链子」并设置检索的操作信息）
function c61173621.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在至少1张满足过滤条件的「锋利小鬼·链子」
	if chk==0 then return Duel.IsExistingMatchingCard(c61173621.filter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置连锁处理的操作信息，表示该效果会将卡组中的1张卡加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果①的效果处理（从卡组将1只「锋利小鬼·链子」加入手牌）
function c61173621.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 给玩家发送提示信息，提示选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 获取卡组中第一张满足过滤条件的「锋利小鬼·链子」
	local tc=Duel.GetFirstMatchingCard(c61173621.filter,tp,LOCATION_DECK,0,nil)
	if tc then
		-- 将获取到的卡片因效果加入玩家手牌
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
		-- 给对方玩家确认加入手牌的卡片
		Duel.ConfirmCards(1-tp,tc)
	end
end
-- 效果②的发动条件（此卡此前的位置必须是手牌或场上）
function c61173621.thcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousLocation(LOCATION_HAND+LOCATION_ONFIELD)
end
-- 过滤卡组中属于「魔玩具」系列且可以加入手牌的卡片
function c61173621.thfilter(c)
	return c:IsSetCard(0xad) and c:IsAbleToHand()
end
-- 效果②的发动准备与检测（检查卡组中是否存在「魔玩具」卡片并设置检索的操作信息）
function c61173621.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在至少1张满足过滤条件的「魔玩具」卡片
	if chk==0 then return Duel.IsExistingMatchingCard(c61173621.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置连锁处理的操作信息，表示该效果会将卡组中的1张卡加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果②的效果处理（从卡组将1张「魔玩具」卡片加入手牌）
function c61173621.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 给玩家发送提示信息，提示选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从卡组中选择1张满足过滤条件的「魔玩具」卡片
	local g=Duel.SelectMatchingCard(tp,c61173621.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选择的卡片因效果加入玩家手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 给对方玩家确认加入手牌的卡片
		Duel.ConfirmCards(1-tp,g)
	end
end
