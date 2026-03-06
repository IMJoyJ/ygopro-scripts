--牙城のガーディアン
-- 效果：
-- 自己场上守备表示存在的怪兽被攻击的场合，那次伤害步骤时可以把这张卡从手卡送去墓地，进行那次战斗的自己怪兽的守备力直到结束阶段时上升1500。
function c23535429.initial_effect(c)
	-- 效果原文内容：自己场上守备表示存在的怪兽被攻击的场合，那次伤害步骤时可以把这张卡从手卡送去墓地，进行那次战斗的自己怪兽的守备力直到结束阶段时上升1500。
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
-- 效果作用：判断是否满足发动条件，即当前为伤害步骤且未计算战斗伤害，且攻击目标为己方守备表示怪兽。
function c23535429.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 效果作用：获取当前游戏阶段
	local phase=Duel.GetCurrentPhase()
	-- 效果作用：若当前阶段不是伤害步骤或伤害已计算，则无法发动
	if phase~=PHASE_DAMAGE or Duel.IsDamageCalculated() then return false end
	-- 效果作用：获取攻击目标怪兽
	local d=Duel.GetAttackTarget()
	return d and d:IsControler(tp) and d:IsDefensePos()
end
-- 效果作用：设置发动时的费用，将自身送去墓地
function c23535429.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToGraveAsCost() end
	-- 效果作用：将自身送去墓地作为费用
	Duel.SendtoGrave(e:GetHandler(),REASON_COST)
end
-- 效果作用：设置效果发动后的处理，为攻击目标怪兽增加1500守备力直到结束阶段
function c23535429.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 效果作用：获取攻击目标怪兽
	local d=Duel.GetAttackTarget()
	if not d:IsRelateToBattle() then return end
	-- 效果原文内容：进行那次战斗的自己怪兽的守备力直到结束阶段时上升1500。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UPDATE_DEFENSE)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
	e1:SetValue(1500)
	d:RegisterEffect(e1)
end
