--セイクリッド・ビーハイブ
-- 效果：
-- 4星「星圣」怪兽×2
-- ①：1回合1次，自己的「星圣」怪兽进行战斗的从伤害步骤开始时到伤害计算前，把这张卡1个超量素材取除才能发动。那只怪兽的攻击力直到回合结束时上升1000。这个效果在对方回合也能发动。
function c2091298.initial_effect(c)
	-- 为卡片添加XYZ召唤手续，要求使用2只等级为4的「星圣」怪兽作为素材
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
-- 判断是否满足发动条件：当前阶段为伤害步骤且尚未计算战斗伤害，攻击怪兽为「星圣」怪兽且参与了战斗
function c2091298.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前游戏阶段
	local phase=Duel.GetCurrentPhase()
	-- 若当前阶段不是伤害步骤或战斗伤害已计算，则效果不满足发动条件
	if phase~=PHASE_DAMAGE or Duel.IsDamageCalculated() then return false end
	-- 获取本次战斗的攻击怪兽
	local tc=Duel.GetAttacker()
	-- 若攻击怪兽不是自己控制，则获取防守怪兽作为目标
	if tc:IsControler(1-tp) then tc=Duel.GetAttackTarget() end
	e:SetLabelObject(tc)
	return tc and tc:IsFaceup() and tc:IsSetCard(0x53) and tc:IsRelateToBattle()
end
-- 定义效果的费用支付函数：检查并移除1个超量素材作为代价
function c2091298.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- 定义效果的发动处理函数：为符合条件的怪兽增加1000点攻击力
function c2091298.operation(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	if not tc:IsRelateToBattle() or tc:IsFacedown() then return end
	-- 那只怪兽的攻击力直到回合结束时上升1000
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
	e1:SetValue(1000)
	tc:RegisterEffect(e1)
end
