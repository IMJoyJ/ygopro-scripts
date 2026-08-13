--名匠 ガミル
-- 效果：
-- ①：自己怪兽进行战斗的从伤害步骤开始时到伤害计算前，把这张卡从手卡送去墓地才能发动。那只怪兽的攻击力直到回合结束时上升300。
function c25727454.initial_effect(c)
	-- ①：自己怪兽进行战斗的从伤害步骤开始时到伤害计算前，把这张卡从手卡送去墓地才能发动。那只怪兽的攻击力直到回合结束时上升300。
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
-- 效果发动条件判定：仅在伤害步骤且尚未计算伤害时，并且我方存在与本次战斗相关的攻击怪兽或攻击对象怪兽的场合，才允许发动。
function c25727454.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前阶段，用于判断是否处于伤害步骤。
	local phase=Duel.GetCurrentPhase()
	-- 若当前不是伤害步骤，或已经进行过伤害计算，则不满足发动条件，直接返回false。
	if phase~=PHASE_DAMAGE or Duel.IsDamageCalculated() then return false end
	-- 取得当前攻击的怪兽。
	local a=Duel.GetAttacker()
	-- 取得当前被攻击的怪兽（可能为nil）。
	local d=Duel.GetAttackTarget()
	return (a:IsControler(tp) and a:IsRelateToBattle()) or (d and d:IsControler(tp) and d:IsRelateToBattle())
end
-- 代价函数：检查此卡是否可以作为代价从手卡送去墓地；可以则执行代价，将自身送入墓地。
function c25727454.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToGraveAsCost() end
	-- 将此卡从手卡送去墓地，作为发动效果的代价（REASON_COST）。
	Duel.SendtoGrave(e:GetHandler(),REASON_COST)
end
-- 效果处理：确定要提升攻击力的我方战斗怪兽（发动者不是回合玩家时取被攻击怪兽），确认其仍与战斗相关且表侧表示后，赋予其攻击力上升300的效果直到回合结束。
function c25727454.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 先默认以攻击怪兽作为提升对象。
	local a=Duel.GetAttacker()
	-- 若发动者为非回合玩家，则我方怪兽是被攻击方，因此将对象改为被攻击怪兽。
	if Duel.GetTurnPlayer()~=tp then a=Duel.GetAttackTarget() end
	if not a:IsRelateToBattle() or a:IsFacedown() then return end
	-- 那只怪兽的攻击力直到回合结束时上升300。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
	e1:SetValue(300)
	a:RegisterEffect(e1)
end
