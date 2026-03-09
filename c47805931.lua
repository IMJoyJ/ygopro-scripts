--No.20 蟻岩土ブリリアント
-- 效果：
-- 3星怪兽×2
-- ①：1回合1次，把这张卡1个超量素材取除才能发动。自己场上的全部怪兽的攻击力上升300。
function c47805931.initial_effect(c)
	-- 为卡片添加等级为3、需要2只怪兽进行XYZ召唤的手续
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
-- 设置该卡的XYZ编号为20
aux.xyz_number[47805931]=20
-- 费用处理函数：检查并移除1张自己的超量素材
function c47805931.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- 效果发动时的处理函数：将自己场上表侧表示的全部怪兽攻击力上升300
function c47805931.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 检索自己场上所有表侧表示的怪兽组成组
	local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,LOCATION_MZONE,0,nil)
	local tc=g:GetFirst()
	while tc do
		-- 使目标怪兽的攻击力上升300
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
