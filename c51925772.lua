--ドレッド・ドラゴン
-- 效果：
-- ①：这张卡被战斗破坏送去墓地时才能发动。从卡组把1只3星以下的龙族怪兽加入手卡。
function c51925772.initial_effect(c)
	-- ①：这张卡被战斗破坏送去墓地时才能发动。从卡组把1只3星以下的龙族怪兽加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(51925772,0))  --"加入手卡"
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_BATTLE_DESTROYED)
	e1:SetCondition(c51925772.condition)
	e1:SetTarget(c51925772.target)
	e1:SetOperation(c51925772.operation)
	c:RegisterEffect(e1)
end
-- 效果发动条件：这张卡在战斗破坏后送入墓地
function c51925772.condition(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsLocation(LOCATION_GRAVE) and e:GetHandler():IsReason(REASON_BATTLE)
end
-- 过滤函数：选择等级为3或以下、种族为龙族且能够加入手牌的怪兽
function c51925772.filter(c)
	return c:IsLevelBelow(3) and c:IsRace(RACE_DRAGON) and c:IsAbleToHand()
end
-- 效果处理目标设定：检查卡组是否存在满足条件的怪兽并设置操作信息
function c51925772.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断是否满足发动条件：确认卡组中存在至少1张符合条件的怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c51925772.filter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置连锁操作信息：指定将要处理的卡为1张从卡组加入手牌的怪兽
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果处理执行：提示选择并检索满足条件的怪兽加入手牌
function c51925772.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从卡组中选择1只满足条件的怪兽
	local g=Duel.SelectMatchingCard(tp,c51925772.filter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的怪兽送入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方确认翻开的卡牌
		Duel.ConfirmCards(1-tp,g)
	end
end
