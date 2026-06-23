--ダニポン
-- 效果：
-- 这张卡被战斗破坏送去墓地时，可以从自己卡组把1只守备力1000以下的昆虫族怪兽加入手卡。
function c48588176.initial_effect(c)
	-- 诱发选发效果，对应一速的【……才能发动】
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(48588176,0))  --"检索"
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_BATTLE_DESTROYED)
	e1:SetCondition(c48588176.condition)
	e1:SetTarget(c48588176.target)
	e1:SetOperation(c48588176.operation)
	c:RegisterEffect(e1)
end
-- 这张卡被战斗破坏送去墓地时
function c48588176.condition(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsLocation(LOCATION_GRAVE) and e:GetHandler():IsReason(REASON_BATTLE)
end
-- 守备力1000以下的昆虫族怪兽
function c48588176.filter(c)
	return c:IsDefenseBelow(1000) and c:IsRace(RACE_INSECT) and c:IsAbleToHand()
end
-- 检索满足条件的卡片组
function c48588176.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组是否存在满足条件的卡片
	if chk==0 then return Duel.IsExistingMatchingCard(c48588176.filter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置连锁操作信息为回手牌效果
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 将目标怪兽特殊召唤
function c48588176.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从卡组选择满足条件的1张卡
	local g=Duel.SelectMatchingCard(tp,c48588176.filter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡加入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 确认对方查看加入手牌的卡
		Duel.ConfirmCards(1-tp,g)
	end
end
