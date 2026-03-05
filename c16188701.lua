--レディ・デバッガー
-- 效果：
-- 这个卡名的效果1回合只能使用1次。
-- ①：这张卡召唤·特殊召唤的场合才能发动。从卡组把1只3星以下的电子界族怪兽加入手卡。
function c16188701.initial_effect(c)
	-- 效果原文内容：①：这张卡召唤·特殊召唤的场合才能发动。从卡组把1只3星以下的电子界族怪兽加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(16188701,0))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_TRIGGER_O+EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetCountLimit(1,16188701)
	e1:SetTarget(c16188701.tg)
	e1:SetOperation(c16188701.op)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
end
-- 检索满足条件的卡片组：3星以下的电子界族怪兽
function c16188701.filter(c)
	return c:IsLevelBelow(3) and c:IsRace(RACE_CYBERSE) and c:IsAbleToHand()
end
-- 效果作用：检查是否满足条件的卡片存在并设置操作信息
function c16188701.tg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 效果作用：检查场上是否存在满足条件的卡片
	if chk==0 then return Duel.IsExistingMatchingCard(c16188701.filter,tp,LOCATION_DECK,0,1,nil) end
	-- 效果作用：设置连锁操作信息为将卡加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果作用：选择满足条件的卡并将其加入手牌
function c16188701.op(e,tp,eg,ep,ev,re,r,rp)
	-- 效果作用：提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 效果作用：选择满足条件的卡组中的卡片
	local g=Duel.SelectMatchingCard(tp,c16188701.filter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 效果作用：将选中的卡片加入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 效果作用：确认对方查看加入手牌的卡片
		Duel.ConfirmCards(1-tp,g)
	end
end
