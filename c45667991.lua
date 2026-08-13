--降竜の魔術師
-- 效果：
-- ←2 【灵摆】 2→
-- ①：1回合1次，以场上1只表侧表示怪兽为对象才能发动。那只怪兽的种族直到对方回合结束时变成龙族。
-- 【怪兽效果】
-- ①：1回合1次，自己主要阶段才能发动。这张卡的种族直到回合结束时变成龙族。
-- ②：场上的这张卡为素材作融合·同调·超量召唤的怪兽得到以下效果。
-- ●这张卡和龙族怪兽进行战斗的伤害步骤内，这张卡的攻击力变成原本攻击力的2倍。
function c45667991.initial_effect(c)
	-- 为降龙之魔术师启用灵摆怪兽属性，使其可以作为灵摆卡发动并在灵摆区放置。
	aux.EnablePendulumAttribute(c)
	-- ①：1回合1次，以场上1只表侧表示怪兽为对象才能发动。那只怪兽的种族直到对方回合结束时变成龙族。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(45667991,0))  --"种族变更"
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCountLimit(1)
	e1:SetRange(LOCATION_PZONE)
	e1:SetTarget(c45667991.rctg1)
	e1:SetOperation(c45667991.rcop1)
	c:RegisterEffect(e1)
	-- ①：1回合1次，自己主要阶段才能发动。这张卡的种族直到回合结束时变成龙族。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(45667991,1))  --"这张卡的种族变更"
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetTarget(c45667991.rctg2)
	e2:SetOperation(c45667991.rcop2)
	c:RegisterEffect(e2)
	-- ②：场上的这张卡为素材作融合·同调·超量召唤的怪兽得到以下效果。●这张卡和龙族怪兽进行战斗的伤害步骤内，这张卡的攻击力变成原本攻击力的2倍。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e3:SetCode(EVENT_BE_MATERIAL)
	e3:SetProperty(EFFECT_FLAG_EVENT_PLAYER)
	e3:SetCondition(c45667991.efcon)
	e3:SetOperation(c45667991.efop)
	c:RegisterEffect(e3)
end
-- 过滤函数：选择场上表侧表示且种族不是龙族的怪兽作为可变龙族的对象。
function c45667991.rcfilter(c)
	return c:IsFaceup() and not c:IsRace(RACE_DRAGON)
end
-- 灵摆效果①的取对象处理：检查场上是否存在符合条件的表侧非龙族怪兽，若有则让玩家选择其中1只作为对象。
function c45667991.rctg1(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c45667991.rcfilter(chkc) end
	-- 发动时合法性检查：场上是否存在至少1只表侧表示且非龙族的怪兽可供选择。
	if chk==0 then return Duel.IsExistingTarget(c45667991.rcfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择一张表侧表示的卡（用于选择对象）。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 让玩家从双方怪兽区选择1只表侧表示且非龙族的怪兽，并将其设为这张卡效果的对象。
	Duel.SelectTarget(tp,c45667991.rcfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
end
-- 灵摆效果①处理：若发动卡仍在场上且对象卡仍在场上表侧表示，则为对象卡赋予种族变为龙族的效果，持续到对方回合结束。
function c45667991.rcop1(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 获取本连锁被选择的效果对象卡。
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) then
		-- 那只怪兽的种族直到对方回合结束时变成龙族。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CHANGE_RACE)
		e1:SetValue(RACE_DRAGON)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END+RESET_OPPO_TURN)
		tc:RegisterEffect(e1)
	end
end
-- 怪兽效果①的发动条件：这张卡当前种族不是龙族才能发动（避免无意义发动）。
function c45667991.rctg2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return not e:GetHandler():IsRace(RACE_DRAGON) end
end
-- 怪兽效果①处理：若这张卡表侧表示且与发动效果关联，则将其种族变为龙族，持续到回合结束。
function c45667991.rcop2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsFaceup() and c:IsRelateToEffect(e) then
		-- 这张卡的种族直到回合结束时变成龙族。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CHANGE_RACE)
		e1:SetValue(RACE_DRAGON)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE+RESET_PHASE+PHASE_END)
		c:RegisterEffect(e1)
	end
end
-- 作为素材时的触发条件：这张卡被用于融合·同调·超量召唤的素材，且在场上被作为素材使用。
function c45667991.efcon(e,tp,eg,ep,ev,re,r,rp)
	return bit.band(r,REASON_FUSION+REASON_SYNCHRO+REASON_XYZ)~=0
		and e:GetHandler():IsPreviousLocation(LOCATION_ONFIELD)
end
-- 处理②：为召唤出的怪兽赋予攻击力变化效果；若该怪兽不是效果怪兽，则额外将其变为效果怪兽以适用该效果。
function c45667991.efop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local rc=c:GetReasonCard()
	-- ●这张卡和龙族怪兽进行战斗的伤害步骤内，这张卡的攻击力变成原本攻击力的2倍。
	local e1=Effect.CreateEffect(rc)
	e1:SetDescription(aux.Stringid(45667991,2))  --"「降龙之魔术师」效果适用中"
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE+EFFECT_FLAG_CLIENT_HINT)
	e1:SetCode(EFFECT_SET_ATTACK_FINAL)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(c45667991.atkcon)
	e1:SetValue(c45667991.atkval)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD)
	rc:RegisterEffect(e1,true)
	if not rc:IsType(TYPE_EFFECT) then
		-- ②：场上的这张卡为素材作融合·同调·超量召唤的怪兽得到以下效果。
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_ADD_TYPE)
		e2:SetValue(TYPE_EFFECT)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		rc:RegisterEffect(e2,true)
	end
end
-- 攻击力变化效果的适用条件：当前阶段为伤害步骤或伤害计算时，且这张卡的战斗对象为龙族怪兽。
function c45667991.atkcon(e)
	-- 获取当前游戏阶段，用于判断是否处于伤害步骤。
	local ph=Duel.GetCurrentPhase()
	local bc=e:GetHandler():GetBattleTarget()
	return (ph==PHASE_DAMAGE or ph==PHASE_DAMAGE_CAL) and bc and bc:IsRace(RACE_DRAGON)
end
-- 计算攻击力数值：返回这张卡的原本攻击力×2。
function c45667991.atkval(e,c)
	return e:GetHandler():GetBaseAttack()*2
end
