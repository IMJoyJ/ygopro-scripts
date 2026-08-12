--妖精王 アルヴェルド
-- 效果：
-- 地属性4星怪兽×2
-- 1回合1次，把这张卡1个超量素材取除才能发动。地属性以外的场上的全部怪兽的攻击力·守备力下降500。
function c28290705.initial_effect(c)
	-- 添加XYZ召唤手续，使用满足地属性条件的4星怪兽作为素材进行召唤，需要2只怪兽叠放
	aux.AddXyzProcedure(c,aux.FilterBoolFunction(Card.IsAttribute,ATTRIBUTE_EARTH),4,2)
	c:EnableReviveLimit()
	-- 1回合1次，把这张卡1个超量素材取除才能发动。地属性以外的场上的全部怪兽的攻击力·守备力下降500。
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
-- 设置效果发动的代价，检查是否能移除1张自己的超量素材作为代价并执行移除操作
function c28290705.adcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- 定义过滤函数，筛选出场上的表侧表示且非地属性的怪兽
function c28290705.filter(c)
	return c:IsFaceup() and c:IsNonAttribute(ATTRIBUTE_EARTH)
end
-- 设置效果的发动目标，检查场上是否存在至少1只满足过滤条件的怪兽
function c28290705.adtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否满足发动条件，即场上存在至少1只非地属性的表侧表示怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c28290705.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
end
-- 效果发动时执行的操作，获取所有非地属性的表侧表示怪兽并为它们分别添加攻击力和守备力下降500的效果
function c28290705.adop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取满足过滤条件的场上怪兽组
	local g=Duel.GetMatchingGroup(c28290705.filter,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	local tc=g:GetFirst()
	while tc do
		-- 为目标怪兽添加攻击力下降500的效果
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
