--ゴキポン
-- 效果：
-- 这张卡被战斗破坏送去墓地时，可以从卡组选择1只攻击力1500以下的昆虫族怪兽加入自己手卡。
function c14472500.initial_effect(c)
	-- 这张卡被战斗破坏送去墓地时，可以从卡组选择1只攻击力1500以下的昆虫族怪兽加入自己手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(14472500,0))  --"检索"
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_BATTLE_DESTROYED)
	e1:SetCondition(c14472500.condition)
	e1:SetTarget(c14472500.target)
	e1:SetOperation(c14472500.operation)
	c:RegisterEffect(e1)
end
-- 效果发动的条件：这张卡在墓地且因战斗破坏而离开战场
function c14472500.condition(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsLocation(LOCATION_GRAVE) and e:GetHandler():IsReason(REASON_BATTLE)
end
-- 过滤函数：筛选攻击力不超过1500且为昆虫族的可加入手牌的怪兽
function c14472500.filter(c)
	return c:IsAttackBelow(1500) and c:IsRace(RACE_INSECT) and c:IsAbleToHand()
end
-- 效果的发动目标设定：检查卡组中是否存在满足条件的怪兽
function c14472500.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断是否满足发动条件：确认卡组中存在至少1张符合条件的怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c14472500.filter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置连锁操作信息：准备从卡组检索一张怪兽加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果的发动处理：执行检索并加入手牌的操作
function c14472500.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	-- 从卡组选择满足条件的1张怪兽
	local g=Duel.SelectMatchingCard(tp,c14472500.filter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的怪兽加入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方确认被加入手牌的卡
		Duel.ConfirmCards(1-tp,g)
	end
end
