--クリスタル・アバター
-- 效果：
-- ①：对方怪兽的直接攻击宣言时，那只怪兽的攻击力是自己基本分以上的场合才能发动。这张卡发动后变成和自己基本分数值相同攻击力的效果怪兽（战士族·光·4星·攻?/守0）在怪兽区域攻击表示特殊召唤。那之后，攻击对象转移为这张卡。这张卡也当作陷阱卡使用。
-- ②：这张卡的效果特殊召唤的这张卡被战斗破坏的伤害计算后发动。给与对方这张卡的攻击力数值的伤害。
function c20960340.initial_effect(c)
	-- ①：对方怪兽的直接攻击宣言时，那只怪兽的攻击力是自己基本分以上的场合才能发动。这张卡发动后变成和自己基本分数值相同攻击力的效果怪兽（战士族·光·4星·攻?/守0）在怪兽区域攻击表示特殊召唤。那之后，攻击对象转移为这张卡。这张卡也当作陷阱卡使用。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_ATTACK_ANNOUNCE)
	e1:SetCondition(c20960340.condition)
	e1:SetTarget(c20960340.target)
	e1:SetOperation(c20960340.activate)
	c:RegisterEffect(e1)
	-- ②：这张卡的效果特殊召唤的这张卡被战斗破坏的伤害计算后发动。给与对方这张卡的攻击力数值的伤害。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(20960340,0))
	e2:SetCategory(CATEGORY_DAMAGE)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_BATTLED)
	e2:SetCondition(c20960340.damcon)
	e2:SetTarget(c20960340.damtg)
	e2:SetOperation(c20960340.damop)
	c:RegisterEffect(e2)
end
-- 判断攻击方是否为对方，且攻击目标为空，且攻击怪兽的攻击力不低于自身基本分。
function c20960340.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 判断攻击方是否为对方，且攻击目标为空。
	return Duel.GetAttacker():IsControler(1-tp) and Duel.GetAttackTarget()==nil
		-- 判断攻击怪兽的攻击力不低于自身基本分。
		and Duel.GetAttacker():IsAttackAbove(Duel.GetLP(tp))
end
-- 设置特殊召唤的条件，包括场地空位和是否可以特殊召唤该怪兽。
function c20960340.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取自身基本分作为攻击力。
	local atk=Duel.GetLP(tp)
	if chk==0 then return e:IsCostChecked()
		-- 判断场上是否有足够的怪兽区域。
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 判断是否可以特殊召唤该怪兽。
		and Duel.IsPlayerCanSpecialSummonMonster(tp,20960340,0,TYPES_EFFECT_TRAP_MONSTER,atk,0,4,RACE_WARRIOR,ATTRIBUTE_LIGHT,POS_FACEUP_ATTACK) end
	-- 设置操作信息为特殊召唤。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 执行效果的发动，将自身特殊召唤为效果怪兽并设置攻击力。
function c20960340.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取自身基本分作为攻击力。
	local atk=Duel.GetLP(tp)
	-- 检查是否可以特殊召唤该怪兽。
	if not Duel.IsPlayerCanSpecialSummonMonster(tp,20960340,0,TYPES_EFFECT_TRAP_MONSTER,atk,0,4,RACE_WARRIOR,ATTRIBUTE_LIGHT,POS_FACEUP_ATTACK) then return end
	c:AddMonsterAttribute(TYPE_TRAP+TYPE_EFFECT)
	-- 开始特殊召唤步骤。
	if Duel.SpecialSummonStep(c,SUMMON_VALUE_SELF,tp,tp,true,false,POS_FACEUP_ATTACK) then
		-- 设置自身攻击力为基本分。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_ATTACK)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetValue(atk)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		c:RegisterEffect(e1)
	end
	-- 完成特殊召唤。
	if Duel.SpecialSummonComplete()==0 then return end
	-- 获取攻击怪兽。
	local at=Duel.GetAttacker()
	if at and at:IsAttackable() and at:IsFaceup() and not at:IsImmuneToEffect(e) and not at:IsStatus(STATUS_ATTACK_CANCELED) then
		-- 中断当前效果。
		Duel.BreakEffect()
		-- 将攻击对象转移为自身。
		Duel.ChangeAttackTarget(c)
	end
end
-- 判断该卡是否被战斗破坏且为特殊召唤。
function c20960340.damcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsStatus(STATUS_BATTLE_DESTROYED) and c:GetSummonType()==SUMMON_TYPE_SPECIAL+SUMMON_VALUE_SELF
end
-- 设置伤害效果的目标和伤害值。
function c20960340.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local dam=e:GetHandler():GetAttack()
	-- 设置伤害对象为对方。
	Duel.SetTargetPlayer(1-tp)
	-- 设置伤害值为自身攻击力。
	Duel.SetTargetParam(dam)
	-- 设置操作信息为造成伤害。
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,dam)
end
-- 执行伤害效果，对对方造成自身攻击力的伤害。
function c20960340.damop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取连锁中的目标玩家。
	local p=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER)
	-- 对目标玩家造成伤害。
	Duel.Damage(p,e:GetHandler():GetAttack(),REASON_EFFECT)
end
