--おジャマ・ブルー
-- 效果：
-- ①：这张卡被战斗破坏送去墓地时才能发动。从卡组把2张「扰乱」卡加入手卡。
function c64627453.initial_effect(c)
	-- ①：这张卡被战斗破坏送去墓地时才能发动。从卡组把2张「扰乱」卡加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(64627453,0))  --"检索"
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_BATTLE_DESTROYED)
	e1:SetCondition(c64627453.condition)
	e1:SetTarget(c64627453.target)
	e1:SetOperation(c64627453.operation)
	c:RegisterEffect(e1)
end
-- 检查此卡是否被战斗破坏并送去墓地，作为效果发动的条件
function c64627453.condition(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsLocation(LOCATION_GRAVE)
		and e:GetHandler():IsReason(REASON_BATTLE)
end
-- 过滤卡组中卡名含有「扰乱」且可以加入手牌的卡片
function c64627453.filter(c)
	return c:IsSetCard(0xf) and c:IsAbleToHand()
end
-- 效果发动时的目标选择与操作信息设置，确认卡组中存在至少2张满足条件的卡，并设置将2张卡加入手牌的操作信息
function c64627453.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在至少2张可以加入手牌的「扰乱」卡
	if chk==0 then return Duel.IsExistingMatchingCard(c64627453.filter,tp,LOCATION_DECK,0,2,nil) end
	-- 设置当前连锁的操作信息为从卡组将2张卡加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,2,tp,LOCATION_DECK)
end
-- 效果处理，从卡组选择2张「扰乱」卡加入手牌并给对方确认
function c64627453.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取卡组中所有满足条件的「扰乱」卡
	local g=Duel.GetMatchingGroup(c64627453.filter,tp,LOCATION_DECK,0,nil)
	if g:GetCount()>1 then
		-- 提示玩家选择要加入手牌的卡片
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
		local sg=g:Select(tp,2,2,nil)
		-- 将选中的卡片因效果加入玩家手牌
		Duel.SendtoHand(sg,nil,REASON_EFFECT)
		-- 向对方玩家展示并确认加入手牌的卡片
		Duel.ConfirmCards(1-tp,sg)
	end
end
