--X－セイバー ガラハド
-- 效果：
-- 这张卡向对方怪兽攻击的场合，伤害步骤内攻击力上升300。这张卡被对方怪兽攻击的场合，伤害步骤内攻击力下降500。这张卡被选择作为攻击对象时，可以把自己场上存在的这张卡以外的1只名字带有「剑士」的怪兽解放，那次攻击无效。
function c50604950.initial_effect(c)
	-- 这张卡向对方怪兽攻击的场合，伤害步骤内攻击力上升300。这张卡被对方怪兽攻击的场合，伤害步骤内攻击力下降500。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetValue(c50604950.atkval)
	c:RegisterEffect(e1)
	-- 这张卡被选择作为攻击对象时，可以把自己场上存在的这张卡以外的1只名字带有「剑士」的怪兽解放，那次攻击无效。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(50604950,0))  --"攻击无效"
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_BE_BATTLE_TARGET)
	e2:SetCost(c50604950.cost)
	e2:SetOperation(c50604950.operation)
	c:RegisterEffect(e2)
end
-- 攻击力变化数值的判定函数：根据当前阶段和该卡在战斗中的身份（攻击方或被攻击方）返回攻击力的增减值，不在伤害步骤内则返回0。
function c50604950.atkval(e,c)
	-- 获取当前游戏阶段，用于判断是否处于伤害步骤（含伤害计算时）。
	local ph=Duel.GetCurrentPhase()
	if ph~=PHASE_DAMAGE and ph~=PHASE_DAMAGE_CAL then return 0 end
	-- 若这张卡是攻击怪兽且场上存在攻击目标，即这张卡正向对方怪兽攻击的场合，则攻击力上升300。
	if c==Duel.GetAttacker() and Duel.GetAttackTarget() then return 300 end
	-- 若这张卡是攻击目标，即这张卡正被对方怪兽攻击的场合，则攻击力下降500。
	if c==Duel.GetAttackTarget() then return -500 end
	return 0
end
-- 发动代价函数：判断并执行解放自己场上这张卡以外的1只名字带有「剑士」的怪兽作为发动代价。
function c50604950.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动代价确认：检查自己场上是否存在1只满足条件（名字带有「剑士」且不是这张卡）的可解放怪兽。
	if chk==0 then return Duel.CheckReleaseGroup(tp,Card.IsSetCard,1,e:GetHandler(),0xd) end
	-- 从自己场上选择1只满足条件的名字带有「剑士」的怪兽（这张卡以外）作为解放对象。
	local g=Duel.SelectReleaseGroup(tp,Card.IsSetCard,1,1,e:GetHandler(),0xd)
	-- 将选择的怪兽解放，作为发动代价（REASON_COST）。
	Duel.Release(g,REASON_COST)
end
-- 效果处理函数：本次攻击无效化。
function c50604950.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 无效此次攻击。
	Duel.NegateAttack()
end
