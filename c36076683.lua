--No.73 激瀧神アビス・スプラッシュ
-- 效果：
-- 水属性5星怪兽×2
-- ①：1回合1次，把这张卡1个超量素材取除才能发动。这张卡的攻击力直到对方回合结束时变成2倍。这个效果的发动后，直到回合结束时这张卡给与对方的战斗伤害变成一半。这个效果在对方回合也能发动。
function c36076683.initial_effect(c)
	-- 为卡片添加水属性5星怪兽×2的超量召唤手续
	aux.AddXyzProcedure(c,aux.FilterBoolFunction(Card.IsAttribute,ATTRIBUTE_WATER),5,2)
	c:EnableReviveLimit()
	-- ①：1回合1次，把这张卡1个超量素材取除才能发动。这张卡的攻击力直到对方回合结束时变成2倍。这个效果的发动后，直到回合结束时这张卡给与对方的战斗伤害变成一半。这个效果在对方回合也能发动。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(36076683,0))  --"攻击变成2倍"
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(TIMING_DAMAGE_STEP)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	-- 设置效果发动条件为伤害步骤前
	e1:SetCondition(aux.dscon)
	e1:SetCost(c36076683.atkcost)
	e1:SetOperation(c36076683.atkop)
	c:RegisterEffect(e1)
end
-- 设置该卡的编号为73
aux.xyz_number[36076683]=73
-- 支付效果代价，从场上取除1个超量素材
function c36076683.atkcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- 效果发动时，将自身攻击力变为2倍，并将给予对方的战斗伤害变为一半
function c36076683.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and c:IsFaceup() then
		-- 这张卡的攻击力直到对方回合结束时变成2倍
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_ATTACK_FINAL)
		e1:SetValue(c:GetAttack()*2)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE+RESET_PHASE+PHASE_END+RESET_OPPO_TURN)
		c:RegisterEffect(e1)
		-- 这个效果的发动后，直到回合结束时这张卡给与对方的战斗伤害变成一半
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_CHANGE_BATTLE_DAMAGE)
		-- 设置战斗伤害为一半
		e2:SetValue(aux.ChangeBattleDamage(1,HALF_DAMAGE))
		e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE+RESET_PHASE+PHASE_END)
		c:RegisterEffect(e2)
	end
end
