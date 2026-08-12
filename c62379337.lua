--バイオレット・ウィッチ
-- 效果：
-- 这张卡被战斗破坏送去墓地时，从自己卡组把1只守备力1500以下的植物族怪兽加入手卡。
function c62379337.initial_effect(c)
	-- 这张卡被战斗破坏送去墓地时，从自己卡组把1只守备力1500以下的植物族怪兽加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(62379337,0))  --"卡组检索"
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_BATTLE_DESTROYED)
	e1:SetCondition(c62379337.condition)
	e1:SetTarget(c62379337.target)
	e1:SetOperation(c62379337.operation)
	c:RegisterEffect(e1)
end
-- 判断此卡是否因战斗破坏并送去墓地
function c62379337.condition(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsLocation(LOCATION_GRAVE) and e:GetHandler():IsReason(REASON_BATTLE)
end
-- 效果发动的目标确认，必发效果直接返回true，并设置操作信息
function c62379337.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置当前连锁的操作信息为：从卡组将1张卡加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 过滤守备力1500以下、植物族且能加入手牌的怪兽
function c62379337.filter(c)
	return c:IsDefenseBelow(1500) and c:IsRace(RACE_PLANT) and c:IsAbleToHand()
end
-- 效果处理：从卡组将1只符合条件的植物族怪兽加入手牌并给对方确认
function c62379337.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从自己卡组中选择1张符合过滤条件的卡
	local g=Duel.SelectMatchingCard(tp,c62379337.filter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡加入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 给对方玩家确认加入手牌的卡
		Duel.ConfirmCards(1-tp,g)
	end
end
