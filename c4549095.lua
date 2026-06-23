--BK カウンターブロー
-- 效果：
-- 自己场上的名字带有「燃烧拳击手」的怪兽进行战斗的伤害步骤时把手卡或者墓地的这张卡从游戏中除外才能发动。那只怪兽的攻击力直到结束阶段时上升1000。「燃烧拳击手 反击拳手」的效果1回合只能使用1次。
function c4549095.initial_effect(c)
	-- 创建一个诱发即时效果，可以在伤害步骤时发动，发动时需要将手卡或墓地的这张卡除外，效果是让参与战斗的「燃烧拳击手」怪兽攻击力上升1000，且此效果每回合只能发动一次。
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
-- 效果发动的条件：当前阶段为伤害步骤且尚未计算战斗伤害，且自己场上的「燃烧拳击手」怪兽正在参与战斗。
function c4549095.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前游戏阶段
	local phase=Duel.GetCurrentPhase()
	-- 如果当前阶段不是伤害步骤或者战斗伤害已经计算，则效果不能发动
	if phase~=PHASE_DAMAGE or Duel.IsDamageCalculated() then return false end
	-- 获取此次战斗的攻击怪兽
	local a=Duel.GetAttacker()
	-- 获取此次战斗的防守怪兽
	local d=Duel.GetAttackTarget()
	return (a:IsControler(tp) and a:IsSetCard(0x1084) and a:IsRelateToBattle())
		or (d and d:IsControler(tp) and d:IsSetCard(0x1084) and d:IsRelateToBattle())
end
-- 效果发动的代价：将此卡从手卡或墓地除外作为发动代价
function c4549095.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToRemoveAsCost() end
	-- 将此卡从游戏中除外作为发动代价
	Duel.Remove(e:GetHandler(),POS_FACEUP,REASON_COST)
end
-- 效果发动时的操作：使参与战斗的「燃烧拳击手」怪兽攻击力上升1000，持续到结束阶段
function c4549095.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取此次战斗的攻击怪兽
	local a=Duel.GetAttacker()
	-- 如果当前回合玩家不是自己，则将防守怪兽设为攻击怪兽
	if Duel.GetTurnPlayer()~=tp then a=Duel.GetAttackTarget() end
	if not a:IsRelateToBattle() then return end
	-- 使目标怪兽的攻击力上升1000，持续到结束阶段
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
	e1:SetValue(1000)
	a:RegisterEffect(e1)
end
