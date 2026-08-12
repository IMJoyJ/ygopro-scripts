--No.17 リバイス・ドラゴン
-- 效果：
-- 3星怪兽×2
-- ①：没有超量素材的这张卡不能直接攻击。
-- ②：1回合1次，把这张卡1个超量素材取除才能发动。这张卡的攻击力上升500。
function c69610924.initial_effect(c)
	-- 添加超量召唤手续：需要2只3星怪兽。
	aux.AddXyzProcedure(c,nil,3,2)
	c:EnableReviveLimit()
	-- ②：1回合1次，把这张卡1个超量素材取除才能发动。这张卡的攻击力上升500。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetDescription(aux.Stringid(69610924,0))  --"攻击上升"
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetCountLimit(1)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCost(c69610924.cost)
	e1:SetOperation(c69610924.operation)
	c:RegisterEffect(e1)
	-- ①：没有超量素材的这张卡不能直接攻击。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_CANNOT_DIRECT_ATTACK)
	e2:SetCondition(c69610924.dircon)
	c:RegisterEffect(e2)
end
-- 设定该卡片的“No.”（编号）为17。
aux.xyz_number[69610924]=17
-- 检查这张卡当前是否没有超量素材，作为不能直接攻击效果的适用条件。
function c69610924.dircon(e)
	return e:GetHandler():GetOverlayCount()==0
end
-- 检查并执行把这张卡1个超量素材取除的发动代价。
function c69610924.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- 效果处理：若这张卡在场上表侧表示存在，则使其攻击力上升500。
function c69610924.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and c:IsFaceup() then
		-- 这张卡的攻击力上升500。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(500)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE)
		c:RegisterEffect(e1)
	end
end
