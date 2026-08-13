--BK カウンターブロー
-- 效果：
-- 自己场上的名字带有「燃烧拳击手」的怪兽进行战斗的伤害步骤时把手卡或者墓地的这张卡从游戏中除外才能发动。那只怪兽的攻击力直到结束阶段时上升1000。「燃烧拳击手 反击拳手」的效果1回合只能使用1次。
function c4549095.initial_effect(c)
	-- 自己场上的名字带有「燃烧拳击手」的怪兽进行战斗的伤害步骤时把手卡或者墓地的这张卡从游戏中除外才能发动。那只怪兽的攻击力直到结束阶段时上升1000。「燃烧拳击手 反击拳手」的效果1回合只能使用1次。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetDescription(aux.Stringid(4549095,0))  --"攻击上升"
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(TIMING_DAMAGE_STEP)
	e1:SetRange(LOCATION_HAND+LOCATION_GRAVE)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
	e1:SetCountLimit(1,4549095)
	e1:SetCondition(c4549095.condition)
	e1:SetCost(c4549095.cost)
	e1:SetOperation(c4549095.operation)
	c:RegisterEffect(e1)
end
-- 发动条件判断：仅在伤害阶段且尚未进行伤害计算时，且我方场上进行战斗的怪兽（攻击怪兽或攻击对象）为名字带有「燃烧拳击手」的怪兽并与本次战斗相关，效果才可发动。
function c4549095.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前游戏阶段。
	local phase=Duel.GetCurrentPhase()
	-- 如果当前不是伤害阶段，或已经进行过伤害计算，则不满足发动条件（只能在伤害步骤且伤害计算前发动）。
	if phase~=PHASE_DAMAGE or Duel.IsDamageCalculated() then return false end
	-- 获取本次战斗的攻击怪兽。
	local a=Duel.GetAttacker()
	-- 获取本次战斗的攻击对象怪兽（可能不存在）。
	local d=Duel.GetAttackTarget()
	return (a:IsControler(tp) and a:IsSetCard(0x1084) and a:IsRelateToBattle())
		or (d and d:IsControler(tp) and d:IsSetCard(0x1084) and d:IsRelateToBattle())
end
-- 代价判定与支付：检测这张卡是否可以作为代价从手卡/墓地除外，若可以则返回 true；在支付阶段将其表侧除外，完成发动代价的支付，对应“把手卡或者墓地的这张卡从游戏中除外才能发动”。
function c4549095.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToRemoveAsCost() end
	-- 将这张卡以表侧表示从手卡/墓地除外，作为发动代价。
	Duel.Remove(e:GetHandler(),POS_FACEUP,REASON_COST)
end
-- 效果处理：确定要上升攻击力的怪兽（自己回合为攻击怪兽，对方回合为我方被攻击的怪兽），若该怪兽仍与战斗相关，则使其攻击力上升1000直到结束阶段。
function c4549095.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 先把攻击怪兽作为潜在的攻击力上升对象。
	local a=Duel.GetAttacker()
	-- 如果当前回合玩家不是这张卡的控制者，说明是对方回合，应改为选择攻击对象（我方怪兽）作为攻击力上升对象。
	if Duel.GetTurnPlayer()~=tp then a=Duel.GetAttackTarget() end
	if not a:IsRelateToBattle() then return end
	-- 那只怪兽的攻击力直到结束阶段时上升1000。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
	e1:SetValue(1000)
	a:RegisterEffect(e1)
end
