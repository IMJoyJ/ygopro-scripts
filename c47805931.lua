--No.20 蟻岩土ブリリアント
-- 效果：
-- 3星怪兽×2
-- ①：1回合1次，把这张卡1个超量素材取除才能发动。自己场上的全部怪兽的攻击力上升300。
function c47805931.initial_effect(c)
	-- 为这张卡添加XYZ召唤手续：可用任意2只3星怪兽叠放来XYZ召唤。
	aux.AddXyzProcedure(c,nil,3,2)
	c:EnableReviveLimit()
	-- ①：1回合1次，把这张卡1个超量素材取除才能发动。自己场上的全部怪兽的攻击力上升300。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetDescription(aux.Stringid(47805931,0))  --"攻击上升"
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetCountLimit(1)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCost(c47805931.cost)
	e1:SetOperation(c47805931.operation)
	c:RegisterEffect(e1)
end
-- 将这张卡登记为No.20，用于No.卡相关的规则判定。
aux.xyz_number[47805931]=20
-- 发动代价：先检查这张卡是否有1个超量素材可去除作为代价；实际支付时从这张卡取除1个超量素材。
function c47805931.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- 效果处理：获取我方场上全部表侧表示怪兽，为每只怪兽赋予攻击力上升300的效果，直到其离场等重置条件发生。
function c47805931.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 筛选出我方怪兽区域所有表侧表示怪兽（不包含对方怪兽区域的卡），作为攻击力上升的适用对象。
	local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,LOCATION_MZONE,0,nil)
	local tc=g:GetFirst()
	while tc do
		-- 自己场上的全部怪兽的攻击力上升300。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetValue(300)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
		tc=g:GetNext()
	end
end
