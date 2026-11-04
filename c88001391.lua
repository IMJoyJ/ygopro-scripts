--地縛死霊ゾーマ
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡发动后变成持有以下效果的效果怪兽（不死族·暗·4星·攻1800/守500）在怪兽区域特殊召唤（也当作陷阱卡使用）。
-- ●可以攻击的对方怪兽必须向这张卡作出攻击。
-- ②：这张卡的效果特殊召唤的这张卡被对方怪兽的攻击破坏的场合发动。给与对方让这张卡破坏的怪兽的原本攻击力2倍数值的伤害（最多3000）。
local s,id,o=GetID()
-- 初始化效果
function s.initial_effect(c)
	-- ①：这张卡发动后变成持有以下效果的效果怪兽（不死族·暗·4星·攻1800/守500）在怪兽区域特殊召唤（也当作陷阱卡使用）。
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
-- 特殊召唤自身的效果目标确认
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查怪兽区是否有空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and
		-- 检查是否可以作为陷阱怪兽特殊召唤
		Duel.IsPlayerCanSpecialSummonMonster(tp,id,0,TYPES_EFFECT_TRAP_MONSTER,1800,500,4,RACE_ZOMBIE,ATTRIBUTE_DARK) end
	-- 设置操作信息：特殊召唤自身
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 特殊召唤自身并赋予必须攻击自身的效果
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 再次检查是否可以作为陷阱怪兽特殊召唤
	if not Duel.IsPlayerCanSpecialSummonMonster(tp,id,0,TYPES_EFFECT_TRAP_MONSTER,1800,500,4,RACE_ZOMBIE,ATTRIBUTE_DARK) then return end
	c:AddMonsterAttribute(TYPE_EFFECT+TYPE_TRAP)
	-- 将自身特殊召唤到怪兽区
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
-- 攻击对象限制为自身
function s.atklimit(e,c)
	return c==e:GetHandler()
end
-- 判断是否自身效果特招且被对方怪兽战斗破坏
function s.damcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取攻击怪兽
	local a=Duel.GetAttacker()
	return c:GetSummonType()==SUMMON_TYPE_SPECIAL+SUMMON_VALUE_SELF and c:IsReason(REASON_BATTLE) and c:IsPreviousControler(tp)
		-- 确认自身是被攻击对象且攻击怪兽为对方控制
		and c==Duel.GetAttackTarget() and a and ((a:IsControler(1-tp) and a:IsOnField()) or a:IsPreviousControler(1-tp))
end
-- 计算并设置战斗破坏自身的怪兽原本攻击力2倍的伤害
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
	-- 设置伤害目标为对方玩家
	Duel.SetTargetPlayer(1-tp)
	-- 设置伤害数值
	Duel.SetTargetParam(dam)
	-- 设置操作信息：给与对方伤害
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,dam)
end
-- 给与对方伤害的效果处理
function s.damop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取伤害目标玩家与伤害数值
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 给与对方效果伤害
	Duel.Damage(p,d,REASON_EFFECT)
end
