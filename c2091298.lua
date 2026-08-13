--セイクリッド・ビーハイブ
-- 效果：
-- 4星「星圣」怪兽×2
-- ①：1回合1次，自己的「星圣」怪兽进行战斗的从伤害步骤开始时到伤害计算前，把这张卡1个超量素材取除才能发动。那只怪兽的攻击力直到回合结束时上升1000。这个效果在对方回合也能发动。
function c2091298.initial_effect(c)
	-- 为这张卡添加XYZ召唤手续：素材为4星「星圣」怪兽2只。
	aux.AddXyzProcedure(c,aux.FilterBoolFunction(Card.IsSetCard,0x53),4,2)
	c:EnableReviveLimit()
	-- ①：1回合1次，自己的「星圣」怪兽进行战斗的从伤害步骤开始时到伤害计算前，把这张卡1个超量素材取除才能发动。那只怪兽的攻击力直到回合结束时上升1000。这个效果在对方回合也能发动。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(2091298,0))  --"攻击上升"
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(TIMING_DAMAGE_STEP)
	e1:SetCountLimit(1)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(c2091298.condition)
	e1:SetCost(c2091298.cost)
	e1:SetOperation(c2091298.operation)
	c:RegisterEffect(e1)
end
-- 效果发动条件：仅在伤害步骤且尚未计算伤害时，我方有表侧表示、与本次战斗相关、且持有「星圣」字段的怪兽进行战斗的场合才可发动。
function c2091298.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前阶段，用于判断是否处于伤害步骤。
	local phase=Duel.GetCurrentPhase()
	-- 只有处于伤害步骤且尚未进行伤害计算时，才满足“从伤害步骤开始时到伤害计算前”的发动时机。
	if phase~=PHASE_DAMAGE or Duel.IsDamageCalculated() then return false end
	-- 获取当前进行攻击的怪兽。
	local tc=Duel.GetAttacker()
	-- 若攻击怪兽是对方控制的，则将判定对象改为被攻击的怪兽，从而锁定我方进行战斗的「星圣」怪兽。
	if tc:IsControler(1-tp) then tc=Duel.GetAttackTarget() end
	e:SetLabelObject(tc)
	return tc and tc:IsFaceup() and tc:IsSetCard(0x53) and tc:IsRelateToBattle()
end
-- 发动代价：从这张卡上取除1个超量素材；chk==0时仅检查是否满足取除条件，否则实际执行取除。
function c2091298.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- 效果处理：为之前记录的那只进行战斗的我方「星圣」怪兽赋予攻击力上升1000的效果，持续到回合结束。
function c2091298.operation(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	if not tc:IsRelateToBattle() or tc:IsFacedown() then return end
	-- 那只怪兽的攻击力直到回合结束时上升1000。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
	e1:SetValue(1000)
	tc:RegisterEffect(e1)
end
