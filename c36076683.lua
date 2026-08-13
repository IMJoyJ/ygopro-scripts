--No.73 激瀧神アビス・スプラッシュ
-- 效果：
-- 水属性5星怪兽×2
-- ①：1回合1次，把这张卡1个超量素材取除才能发动。这张卡的攻击力直到对方回合结束时变成2倍。这个效果的发动后，直到回合结束时这张卡给与对方的战斗伤害变成一半。这个效果在对方回合也能发动。
function c36076683.initial_effect(c)
	-- 为这张卡添加XYZ召唤手续：可用2只水属性5星怪兽作为超量素材进行XYZ召唤。
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
	-- 设置效果的发动条件为伤害步骤且尚未进行伤害计算（aux.dscon），保证该二速效果能在对方回合的伤害计算前发动。
	e1:SetCondition(aux.dscon)
	e1:SetCost(c36076683.atkcost)
	e1:SetOperation(c36076683.atkop)
	c:RegisterEffect(e1)
end
-- 将这张卡登记为No.73的XYZ怪兽，用于编号相关判定与显示。
aux.xyz_number[36076683]=73
-- 代价处理：chk为0时仅检查能否以取除超量素材为代价移除1个素材；实际发动时移除这张卡的1个超量素材作为代价，取除理由为代价（REASON_COST）。
function c36076683.atkcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- 效果处理：若这张卡仍在场上且表侧表示，则赋予其攻击力变为当前攻击力2倍的效果（持续到对方回合结束），同时赋予其给与对方战斗伤害减半的效果（持续到当前回合结束）。
function c36076683.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and c:IsFaceup() then
		-- 这张卡的攻击力直到对方回合结束时变成2倍。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_ATTACK_FINAL)
		e1:SetValue(c:GetAttack()*2)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE+RESET_PHASE+PHASE_END+RESET_OPPO_TURN)
		c:RegisterEffect(e1)
		-- 这个效果的发动后，直到回合结束时这张卡给与对方的战斗伤害变成一半。
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_CHANGE_BATTLE_DAMAGE)
		-- 设置战斗伤害变更效果的值：使对方玩家受到的来自这张卡的战斗伤害变为一半。
		e2:SetValue(aux.ChangeBattleDamage(1,HALF_DAMAGE))
		e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE+RESET_PHASE+PHASE_END)
		c:RegisterEffect(e2)
	end
end
