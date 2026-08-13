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
-- 发动条件判定：这张卡被战斗破坏后确实被送去墓地，且因此被战斗破坏。
function c14472500.condition(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsLocation(LOCATION_GRAVE) and e:GetHandler():IsReason(REASON_BATTLE)
end
-- 检索卡组的过滤条件：攻击力1500以下的昆虫族怪兽，并且能够加入手卡。
function c14472500.filter(c)
	return c:IsAttackBelow(1500) and c:IsRace(RACE_INSECT) and c:IsAbleToHand()
end
-- 效果发动时的目标设定：确认卡组中存在符合条件的怪兽，并设置此次操作的效果信息为从卡组将卡片加入手牌。
function c14472500.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动合法性检查（chk==0）：确认自己卡组里是否存在至少1只满足检索条件的昆虫族怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(c14472500.filter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息：此次处理为从卡组将1张卡加入持有者手牌（CATEGORY_TOHAND）。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果处理：从卡组选择符合条件的昆虫族怪兽加入手牌，并向对方展示该卡。
function c14472500.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 给操作者显示选择提示：请选择要加入手牌的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从自己卡组中选出1只满足过滤条件的怪兽（必须正好选1张）。
	local g=Duel.SelectMatchingCard(tp,c14472500.filter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选出的怪兽加入其持有者的手卡（不改变持有者），原因记为效果处理。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 将加入手卡的那张卡展示给对方玩家确认。
		Duel.ConfirmCards(1-tp,g)
	end
end
