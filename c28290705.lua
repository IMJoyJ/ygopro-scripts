--妖精王 アルヴェルド
-- 效果：
-- 地属性4星怪兽×2
-- 1回合1次，把这张卡1个超量素材取除才能发动。地属性以外的场上的全部怪兽的攻击力·守备力下降500。
function c28290705.initial_effect(c)
	-- 为“妖精王 阿尔维德”添加超量召唤手续：使用2只地属性4星怪兽作为超量素材叠放召唤。
	aux.AddXyzProcedure(c,aux.FilterBoolFunction(Card.IsAttribute,ATTRIBUTE_EARTH),4,2)
	c:EnableReviveLimit()
	-- 对应效果原文：1回合1次，把这张卡1个超量素材取除才能发动。地属性以外的场上的全部怪兽的攻击力·守备力下降500。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(28290705,0))  --"攻守下降"
	e1:SetCategory(CATEGORY_ATKCHANGE+CATEGORY_DEFCHANGE)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCost(c28290705.adcost)
	e1:SetTarget(c28290705.adtg)
	e1:SetOperation(c28290705.adop)
	c:RegisterEffect(e1)
end
-- 代价处理：发动前检查这张卡能否以代价方式取除1个超量素材；实际发动时从这张卡上取除1个超量素材作为代价。
function c28290705.adcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- 定义效果对象的过滤条件：场上的表侧表示且属性不是地属性的怪兽。
function c28290705.filter(c)
	return c:IsFaceup() and c:IsNonAttribute(ATTRIBUTE_EARTH)
end
-- 效果发动时的目标判定：检查场上是否存在至少1只表侧表示且非地属性的怪兽（本效果不取对象）。
function c28290705.adtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动条件检查：存在满足条件的怪兽才允许发动，且不取对象。
	if chk==0 then return Duel.IsExistingMatchingCard(c28290705.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
end
-- 效果处理：获取场上所有表侧表示且非地属性的怪兽，逐只赋予攻击力下降500和守备力下降500的效果。
function c28290705.adop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取场上所有符合条件（表侧表示且非地属性）的怪兽组。
	local g=Duel.GetMatchingGroup(c28290705.filter,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	local tc=g:GetFirst()
	while tc do
		-- 攻击力下降500（对应效果原文中“攻击力·守备力下降500”的攻击力部分）。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(-500)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_UPDATE_DEFENSE)
		tc:RegisterEffect(e2)
		tc=g:GetNext()
	end
end
