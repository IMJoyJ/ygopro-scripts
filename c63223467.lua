--RAI－MEI
-- 效果：
-- 这张卡被战斗破坏送去墓地时，可以从自己卡组把1只2星以下的光属性怪兽加入手卡。
function c63223467.initial_effect(c)
	-- 这张卡被战斗破坏送去墓地时，可以从自己卡组把1只2星以下的光属性怪兽加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(63223467,0))  --"检索"
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_BATTLE_DESTROYED)
	e1:SetCondition(c63223467.condition)
	e1:SetTarget(c63223467.target)
	e1:SetOperation(c63223467.operation)
	c:RegisterEffect(e1)
end
-- 检查自身是否因战斗破坏被送去墓地
function c63223467.condition(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsLocation(LOCATION_GRAVE) and e:GetHandler():IsReason(REASON_BATTLE)
end
-- 过滤卡组中等级2以下、光属性且可以加入手牌的怪兽
function c63223467.filter(c)
	return c:IsLevelBelow(2) and c:IsAttribute(ATTRIBUTE_LIGHT) and c:IsAbleToHand()
end
-- 效果发动的目标检查与操作信息设置
function c63223467.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己卡组中是否存在至少1只符合条件的怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c63223467.filter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息，表示该效果会将卡组中的1张卡加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果处理：从卡组选择1只符合条件的怪兽加入手牌并给对方确认
function c63223467.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从自己卡组中选择1只符合条件的怪兽
	local g=Duel.SelectMatchingCard(tp,c63223467.filter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的怪兽因效果加入玩家手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 给对方玩家确认加入手牌的卡片
		Duel.ConfirmCards(1-tp,g)
	end
end
