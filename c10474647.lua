--五月豹
-- 效果：
-- ①：手卡只有这1张卡的场合才能发动。这张卡特殊召唤。
-- ②：这张卡的①的效果特殊召唤的场合发动。这张卡的攻击力直到对方回合结束时变成2500。
-- ③：这张卡和对方怪兽进行战斗的场合，那次战斗发生的对对方的战斗伤害由自己代受。
-- ④：这张卡的战斗让自己受到伤害的场合发动。这张卡的攻击力变成0。那之后，自己基本分是2000以下的场合，这张卡的攻击力变成5000。
local s,id,o=GetID()
-- 注册五月豹的全部效果：①手牌仅有自身时可特殊召唤；②以此方式特殊召唤后攻击力变为2500；③自身与对方怪兽战斗时对对方的战斗伤害由自己代受；④自身战斗使自己受到伤害后攻击力变0，若之后LP在2000以下则再变为5000。
function s.initial_effect(c)
	-- ①：手卡只有这1张卡的场合才能发动。这张卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(s.spcon)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	-- ②：这张卡的①的效果特殊召唤的场合发动。这张卡的攻击力直到对方回合结束时变成2500。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"改变攻击力"
	e2:SetCategory(CATEGORY_ATKCHANGE)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCondition(s.atkcon)
	e2:SetOperation(s.atkop)
	c:RegisterEffect(e2)
	-- ③：这张卡和对方怪兽进行战斗的场合，那次战斗发生的对对方的战斗伤害由自己代受。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_REFLECT_BATTLE_DAMAGE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e3:SetTargetRange(0,1)
	e3:SetCondition(s.rfcon)
	c:RegisterEffect(e3)
	-- ④：这张卡的战斗让自己受到伤害的场合发动。这张卡的攻击力变成0。那之后，自己基本分是2000以下的场合，这张卡的攻击力变成5000。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,2))  --"攻击力变成5000"
	e4:SetCategory(CATEGORY_ATKCHANGE)
	e4:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCode(EVENT_BATTLE_DAMAGE)
	e4:SetCondition(s.atkcon2)
	e4:SetOperation(s.atkop2)
	c:RegisterEffect(e4)
end
-- ①效果的发动条件：自己手牌只有这张卡，且自己主要怪兽区有空位可进行特殊召唤。
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己手牌的数量是否为1，即满足“手卡只有这1张卡”的条件。
	return Duel.GetFieldGroupCount(tp,LOCATION_HAND,0)==1
		-- 检查自己主要怪兽区是否有空位，确保可以特殊召唤这张卡。
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
end
-- 发动时合法性检查：自己主要怪兽区有空位，且这张卡能够被特殊召唤（不检查召唤条件、不限制苏生限制）。
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 效果发动时确认自己主要怪兽区存在可用的空格。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 将本次操作信息登记为特殊召唤这张卡，并写入连锁，供其他效果检测（例如星尘龙等）。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 特殊召唤处理：若这张卡仍与效果关联，则将其以表侧表示特殊召唤到自己的主要怪兽区。
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 通过自身效果把这张卡以表侧攻击表示特殊召唤到自己场上，召唤类型定义为自身效果。
		Duel.SpecialSummon(c,SUMMON_VALUE_SELF,tp,tp,false,false,POS_FACEUP)
	end
end
-- ②效果的触发条件：这张卡的召唤类型是“通过自身①效果进行的特殊召唤”。
function s.atkcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetSummonType()==SUMMON_TYPE_SPECIAL+SUMMON_VALUE_SELF
end
-- ②效果处理：若这张卡仍在场上且表侧表示，攻击力还不是2500，则将其攻击力设为2500，持续到对方回合结束。
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and c:IsFaceup() and not c:IsAttack(2500) then
		-- 这张卡的攻击力直到对方回合结束时变成2500。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_ATTACK_FINAL)
		e1:SetValue(2500)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE+RESET_PHASE+PHASE_END+RESET_OPPO_TURN)
		c:RegisterEffect(e1)
	end
end
-- ③效果适用条件：这张卡正在与对方怪兽进行战斗（作为攻击方或作为被攻击目标）。
function s.rfcon(e)
	-- 判断战斗指向：这张卡是攻击者且存在攻击目标，或者这张卡是被攻击目标。
	return Duel.GetAttacker()==e:GetHandler() and Duel.GetAttackTarget()~=nil or Duel.GetAttackTarget()==e:GetHandler()
end
-- ④效果的触发条件：自己因这张卡的战斗受到了战斗伤害（伤害承受者为这张卡的控制者自身）。
function s.atkcon2(e,tp,eg,ep,ev,re,r,rp)
	return ep==tp
end
-- ④效果处理：若这张卡未被战斗破坏、与效果关联且表侧表示、攻击力不为0，则先将攻击力设为0；之后若自己LP在2000以下，则再通过错时点处理把攻击力设为5000。
function s.atkop2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsStatus(STATUS_BATTLE_DESTROYED) and c:IsRelateToEffect(e) and c:IsFaceup() and not c:IsAttack(0) then
		-- 这张卡的攻击力变成0。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_ATTACK_FINAL)
		e1:SetValue(0)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE)
		c:RegisterEffect(e1)
		-- 检查这张卡攻击力是否为0，且自己基本分是否在2000以下，若是则继续执行把攻击力变为5000。
		if c:IsAttack(0) and Duel.GetLP(tp)<=2000 then
			-- 中断当前效果处理，使后续攻击力变成5000的处理成为独立效果，避免时点被错过。
			Duel.BreakEffect()
			-- 那之后，自己基本分是2000以下的场合，这张卡的攻击力变成5000。
			local e2=Effect.CreateEffect(c)
			e2:SetType(EFFECT_TYPE_SINGLE)
			e2:SetCode(EFFECT_SET_ATTACK_FINAL)
			e2:SetValue(5000)
			e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE)
			c:RegisterEffect(e2)
		end
	end
end
