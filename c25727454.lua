--名匠 ガミル
-- 效果：
-- ①：自己怪兽进行战斗的从伤害步骤开始时到伤害计算前，把这张卡从手卡送去墓地才能发动。那只怪兽的攻击力直到回合结束时上升300。
function c25727454.initial_effect(c)
	-- 创建效果，设置效果描述、类别、类型、时点、适用范围、属性、发动条件、费用和效果操作
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(25727454,0))
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(TIMING_DAMAGE_STEP)
	e1:SetRange(LOCATION_HAND)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
	e1:SetCondition(c25727454.condition)
	e1:SetCost(c25727454.cost)
	e1:SetOperation(c25727454.operation)
	c:RegisterEffect(e1)
end
-- 效果发动的条件：当前阶段为伤害步骤且未计算战斗伤害，且自己怪兽参与战斗
function c25727454.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前游戏阶段
	local phase=Duel.GetCurrentPhase()
	-- 若当前阶段不是伤害步骤或伤害已计算，则效果无法发动
	if phase~=PHASE_DAMAGE or Duel.IsDamageCalculated() then return false end
	-- 获取本次战斗的攻击怪兽
	local a=Duel.GetAttacker()
	-- 获取本次战斗的防守怪兽
	local d=Duel.GetAttackTarget()
	return (a:IsControler(tp) and a:IsRelateToBattle()) or (d and d:IsControler(tp) and d:IsRelateToBattle())
end
-- 效果发动的费用：将此卡从手牌送去墓地
function c25727454.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToGraveAsCost() end
	-- 将此卡从手牌送去墓地作为发动费用
	Duel.SendtoGrave(e:GetHandler(),REASON_COST)
end
-- 效果发动时的操作：使参与战斗的怪兽攻击力上升300
function c25727454.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取本次战斗的攻击怪兽
	local a=Duel.GetAttacker()
	-- 若当前回合玩家不是发动者，则获取防守怪兽作为目标
	if Duel.GetTurnPlayer()~=tp then a=Duel.GetAttackTarget() end
	if not a:IsRelateToBattle() or a:IsFacedown() then return end
	-- 使目标怪兽的攻击力上升300，直到回合结束时
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
	e1:SetValue(300)
	a:RegisterEffect(e1)
end
