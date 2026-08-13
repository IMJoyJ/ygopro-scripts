--牙城のガーディアン
-- 效果：
-- 自己场上守备表示存在的怪兽被攻击的场合，那次伤害步骤时可以把这张卡从手卡送去墓地，进行那次战斗的自己怪兽的守备力直到结束阶段时上升1500。
function c23535429.initial_effect(c)
	-- 自己场上守备表示存在的怪兽被攻击的场合，那次伤害步骤时可以把这张卡从手卡送去墓地，进行那次战斗的自己怪兽的守备力直到结束阶段时上升1500。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(23535429,0))  --"守备上升"
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(TIMING_DAMAGE_STEP)
	e1:SetRange(LOCATION_HAND)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
	e1:SetCondition(c23535429.condition)
	e1:SetCost(c23535429.cost)
	e1:SetOperation(c23535429.operation)
	c:RegisterEffect(e1)
end
-- 定义发动条件：当前必须处于伤害步骤且尚未进行伤害计算，并且被攻击的怪兽是我方场上守备表示的怪兽。
function c23535429.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前游戏阶段。
	local phase=Duel.GetCurrentPhase()
	-- 若当前不是伤害阶段或已经计算过战斗伤害，则条件不满足，不能发动。
	if phase~=PHASE_DAMAGE or Duel.IsDamageCalculated() then return false end
	-- 获取当前被攻击的怪兽（攻击目标）。
	local d=Duel.GetAttackTarget()
	return d and d:IsControler(tp) and d:IsDefensePos()
end
-- 定义代价函数：确认此卡可以从手卡作为代价送去墓地；若可以，则实际将其送去墓地。
function c23535429.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToGraveAsCost() end
	-- 将此卡从手卡作为代价送去墓地。
	Duel.SendtoGrave(e:GetHandler(),REASON_COST)
end
-- 定义效果处理：确认被攻击怪兽仍与本次战斗关联，然后使其守备力直到结束阶段上升1500。
function c23535429.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前被攻击的怪兽（攻击目标）。
	local d=Duel.GetAttackTarget()
	if not d:IsRelateToBattle() then return end
	-- 进行那次战斗的自己怪兽的守备力直到结束阶段时上升1500。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UPDATE_DEFENSE)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
	e1:SetValue(1500)
	d:RegisterEffect(e1)
end
