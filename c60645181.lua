--H－C エクスカリバー
-- 效果：
-- 战士族4星怪兽×2
-- ①：1回合1次，把这张卡2个超量素材取除才能发动。这张卡的攻击力直到对方回合结束时变成原本攻击力的2倍。
function c60645181.initial_effect(c)
	-- 添加超量召唤手续：以2只4星的战士族怪兽作为超量素材
	aux.AddXyzProcedure(c,aux.FilterBoolFunction(Card.IsRace,RACE_WARRIOR),4,2)
	c:EnableReviveLimit()
	-- ①：1回合1次，把这张卡2个超量素材取除才能发动。这张卡的攻击力直到对方回合结束时变成原本攻击力的2倍。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetDescription(aux.Stringid(60645181,0))  --"攻击变化"
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetCountLimit(1)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCost(c60645181.cost)
	e1:SetOperation(c60645181.operation)
	c:RegisterEffect(e1)
end
-- 检查并取除这张卡的2个超量素材作为效果发动的代价
function c60645181.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,2,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,2,2,REASON_COST)
end
-- 效果处理：若这张卡在场上表侧表示存在，则使其攻击力直到对方回合结束时变成原本攻击力的2倍
function c60645181.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and c:IsFaceup() then
		-- 这张卡的攻击力直到对方回合结束时变成原本攻击力的2倍。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_ATTACK_FINAL)
		e1:SetValue(c:GetBaseAttack()*2)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE+RESET_PHASE+PHASE_END,2)
		c:RegisterEffect(e1)
	end
end
