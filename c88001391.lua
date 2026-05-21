--地縛死霊ゾーマ
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡发动后变成持有以下效果的效果怪兽（不死族·暗·4星·攻1800/守500）在怪兽区域特殊召唤（也当作陷阱卡使用）。
-- ●可以攻击的对方怪兽必须向这张卡作出攻击。
-- ②：这张卡的效果特殊召唤的这张卡被对方怪兽的攻击破坏的场合发动。给与对方让这张卡破坏的怪兽的原本攻击力2倍数值的伤害（最多3000）。
local s,id,o=GetID()
-- 初始化效果：注册①效果（发动并特殊召唤为怪兽）与②效果（被攻击破坏时给与伤害）。
function s.initial_effect(c)
	-- ①：这张卡发动后变成持有以下效果的效果怪兽（不死族·暗·4星·攻1800/守500）在怪兽区域特殊召唤（也当作陷阱卡使用）。●可以攻击的对方怪兽必须向这张卡作出攻击。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCountLimit(1,id)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	-- ②：这张卡的效果特殊召唤的这张卡被对方怪兽的攻击破坏的场合发动。给与对方让这张卡破坏的怪兽的原本攻击力2倍数值的伤害（最多3000）。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_DAMAGE)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e2:SetCountLimit(1,id+o)
	e2:SetCode(EVENT_LEAVE_FIELD)
	e2:SetCondition(s.damcon)
	e2:SetTarget(s.damtg)
	e2:SetOperation(s.damop)
	c:RegisterEffect(e2)
end
-- ①效果的发动准备：检查怪兽区域是否有空位，以及是否可以特殊召唤该陷阱怪兽。
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自身怪兽区域是否有空位。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and
		-- 检查玩家是否能将该卡作为指定属性、种族、攻守、等级的效果怪兽特殊召唤。
		Duel.IsPlayerCanSpecialSummonMonster(tp,id,0,TYPES_EFFECT_TRAP_MONSTER,1800,500,4,RACE_ZOMBIE,ATTRIBUTE_DARK) end
	-- 设置连锁信息：此效果包含特殊召唤自身的操作。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- ①效果的效果处理：将自身作为怪兽特殊召唤，并赋予“对方怪兽必须向这张卡作出攻击”的效果。
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 效果处理时，再次检查是否能特殊召唤该陷阱怪兽，若不能则处理终止。
	if not Duel.IsPlayerCanSpecialSummonMonster(tp,id,0,TYPES_EFFECT_TRAP_MONSTER,1800,500,4,RACE_ZOMBIE,ATTRIBUTE_DARK) then return end
	c:AddMonsterAttribute(TYPE_EFFECT+TYPE_TRAP)
	-- 将自身特殊召唤到怪兽区域。
	Duel.SpecialSummon(c,SUMMON_VALUE_SELF,tp,tp,true,false,POS_FACEUP)
	-- ●可以攻击的对方怪兽必须向这张卡作出攻击。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_MUST_ATTACK)
	e2:SetReset(RESET_EVENT+RESETS_STANDARD)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(0,LOCATION_MZONE)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EFFECT_MUST_ATTACK_MONSTER)
	e3:SetValue(s.atklimit)
	c:RegisterEffect(e3)
end
-- 限制对方怪兽攻击时的攻击对象必须是这张卡。
function s.atklimit(e,c)
	return c==e:GetHandler()
end
-- ②效果的发动条件：此卡是通过自身效果特殊召唤，因战斗破坏，且是被对方怪兽攻击。
function s.damcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:GetSummonType()==SUMMON_TYPE_SPECIAL+SUMMON_VALUE_SELF and c:IsReason(REASON_BATTLE) and c:IsPreviousControler(tp)
		-- 确认此卡是攻击对象，且发动攻击的怪兽由对方控制。
		and c==Duel.GetAttackTarget() and ((Duel.GetAttacker():IsControler(1-tp) and c:IsOnField()) or Duel.GetAttacker():IsPreviousControler(1-tp))
end
-- ②效果的准备：获取破坏此卡的对方怪兽，计算其原本攻击力的2倍（最大3000），并设置伤害效果的对象和数值。
function s.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local bc=e:GetHandler():GetBattleTarget()
	local dam=0
	if bc:IsLocation(LOCATION_MZONE) then
		dam=bc:GetBaseAttack()
	else
		dam=bc:GetTextAttack()
	end
	if dam<0 then dam=0 end
	dam=math.min(3000,dam*2)
	-- 设置伤害效果的对象玩家为对方。
	Duel.SetTargetPlayer(1-tp)
	-- 设置伤害效果的数值。
	Duel.SetTargetParam(dam)
	-- 设置连锁信息：此效果包含给与对方伤害的操作。
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,dam)
end
-- ②效果的效果处理：给与对方计算出的伤害。
function s.damop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中设定的伤害对象玩家和伤害数值。
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 给与对方玩家对应的效果伤害。
	Duel.Damage(p,d,REASON_EFFECT)
end
