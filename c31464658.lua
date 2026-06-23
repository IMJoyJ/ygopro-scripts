--三眼の死霊
-- 效果：
-- 这个卡名的效果1回合只能使用1次。
-- ①：把场上的这张卡送去墓地才能发动。从卡组把1只暗属性·10星怪兽加入手卡。
function c31464658.initial_effect(c)
	-- ①：把场上的这张卡送去墓地才能发动。从卡组把1只暗属性·10星怪兽加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(31464658,0))
	e1:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,31464658)
	e1:SetCost(c31464658.cost)
	e1:SetTarget(c31464658.target)
	e1:SetOperation(c31464658.operation)
	c:RegisterEffect(e1)
end
-- 检查是否可以将此卡送入墓地作为费用
function c31464658.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsAbleToGraveAsCost() end
	-- 将此卡送入墓地作为费用
	Duel.SendtoGrave(c,REASON_COST)
end
-- 检索过滤器：暗属性且10星且可以加入手牌的怪兽
function c31464658.thfilter(c)
	return c:IsAttribute(ATTRIBUTE_DARK) and c:IsLevel(10) and c:IsAbleToHand()
end
-- 检查是否满足发动条件：卡组存在符合条件的怪兽
function c31464658.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组是否存在满足条件的怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c31464658.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置连锁操作信息：将1张符合条件的卡加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 处理效果的发动：选择并加入手牌
function c31464658.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从卡组选择1只满足条件的怪兽
	local g=Duel.SelectMatchingCard(tp,c31464658.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的怪兽加入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 确认对方查看加入手牌的卡
		Duel.ConfirmCards(1-tp,g)
	end
end
