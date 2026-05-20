--水精鱗－アビスパイク
-- 效果：
-- 这张卡召唤·特殊召唤成功时，把手卡1只水属性怪兽丢弃去墓地才能发动。从卡组把1只3星的水属性怪兽加入手卡。「水精鳞-深渊雀鳝兵」的效果1回合只能使用1次。
function c58471134.initial_effect(c)
	-- 这张卡召唤·特殊召唤成功时，把手卡1只水属性怪兽丢弃去墓地才能发动。从卡组把1只3星的水属性怪兽加入手卡。「水精鳞-深渊雀鳝兵」的效果1回合只能使用1次。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(58471134,0))  --"检索"
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetCountLimit(1,58471134)
	e1:SetCost(c58471134.thcost)
	e1:SetTarget(c58471134.thtg)
	e1:SetOperation(c58471134.thop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
end
-- 过滤手牌中可作为代价丢弃的水属性怪兽
function c58471134.cfilter(c)
	return c:IsAttribute(ATTRIBUTE_WATER) and c:IsDiscardable() and c:IsAbleToGraveAsCost()
end
-- 效果发动代价：丢弃手牌1只水属性怪兽
function c58471134.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查手牌中是否存在除自身外可作为代价丢弃的水属性怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c58471134.cfilter,tp,LOCATION_HAND,0,1,e:GetHandler()) end
	-- 玩家选择手牌中1只满足条件的水属性怪兽丢弃去墓地作为发动代价
	Duel.DiscardHand(tp,c58471134.cfilter,1,1,REASON_COST+REASON_DISCARD)
end
-- 过滤卡组中可以加入手牌的3星水属性怪兽
function c58471134.filter(c)
	return c:IsLevel(3) and c:IsAttribute(ATTRIBUTE_WATER) and c:IsAbleToHand()
end
-- 效果发动准备：检查卡组中是否存在可检索的怪兽并设置操作信息
function c58471134.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在满足条件的3星水属性怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c58471134.filter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置当前连锁的操作信息为从卡组将1张卡加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果处理：从卡组选择1只3星水属性怪兽加入手牌并给对方确认
function c58471134.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从卡组选择1张满足条件的3星水属性怪兽
	local g=Duel.SelectMatchingCard(tp,c58471134.filter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选择的卡加入玩家手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方玩家确认加入手牌的卡
		Duel.ConfirmCards(1-tp,g)
	end
end
