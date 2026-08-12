--降竜の魔術師
-- 效果：
-- ←2 【灵摆】 2→
-- ①：1回合1次，以场上1只表侧表示怪兽为对象才能发动。那只怪兽的种族直到对方回合结束时变成龙族。
-- 【怪兽效果】
-- ①：1回合1次，自己主要阶段才能发动。这张卡的种族直到回合结束时变成龙族。
-- ②：场上的这张卡为素材作融合·同调·超量召唤的怪兽得到以下效果。
-- ●这张卡和龙族怪兽进行战斗的伤害步骤内，这张卡的攻击力变成原本攻击力的2倍。
function c45667991.initial_effect(c)
	-- 为灵摆怪兽添加灵摆怪兽属性
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
	-- ②：场上的这张卡为素材作融合·同调·超量召唤的怪兽得到以下效果。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e3:SetCode(EVENT_BE_MATERIAL)
	e3:SetProperty(EFFECT_FLAG_EVENT_PLAYER)
	e3:SetCondition(c45667991.efcon)
	e3:SetOperation(c45667991.efop)
	c:RegisterEffect(e3)
end
-- 筛选符合条件的表侧表示怪兽（非龙族）
function c45667991.rcfilter(c)
	return c:IsFaceup() and not c:IsRace(RACE_DRAGON)
end
-- 设置效果目标为符合条件的表侧表示怪兽
function c45667991.rctg1(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c45667991.rcfilter(chkc) end
	-- 判断是否满足发动条件（存在符合条件的怪兽）
	if chk==0 then return Duel.IsExistingTarget(c45667991.rcfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择表侧表示的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择符合条件的表侧表示怪兽作为效果对象
	Duel.SelectTarget(tp,c45667991.rcfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
end
-- 处理效果发动后的操作，将目标怪兽种族变为龙族
function c45667991.rcop1(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 获取当前效果的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) then
		-- 将目标怪兽的种族变更效果注册到目标怪兽上，持续到对方回合结束
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CHANGE_RACE)
		e1:SetValue(RACE_DRAGON)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END+RESET_OPPO_TURN)
		tc:RegisterEffect(e1)
	end
end
-- 判断是否满足发动条件（自身不是龙族）
function c45667991.rctg2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return not e:GetHandler():IsRace(RACE_DRAGON) end
end
-- 处理效果发动后的操作，将自身种族变为龙族
function c45667991.rcop2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsFaceup() and c:IsRelateToEffect(e) then
		-- 将自身种族变更效果注册到自身上，持续到回合结束
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CHANGE_RACE)
		e1:SetValue(RACE_DRAGON)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE+RESET_PHASE+PHASE_END)
		c:RegisterEffect(e1)
	end
end
-- 判断是否满足效果发动条件（作为融合/同调/超量召唤素材）
function c45667991.efcon(e,tp,eg,ep,ev,re,r,rp)
	return bit.band(r,REASON_FUSION+REASON_SYNCHRO+REASON_XYZ)~=0
		and e:GetHandler():IsPreviousLocation(LOCATION_ONFIELD)
end
-- 处理效果发动后的操作，为作为素材的怪兽添加攻击力翻倍效果
function c45667991.efop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local rc=c:GetReasonCard()
	-- 为作为素材的怪兽添加攻击力翻倍效果，仅在与龙族怪兽战斗时生效
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
		-- 若作为素材的怪兽没有效果类型，则为其添加效果类型
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_ADD_TYPE)
		e2:SetValue(TYPE_EFFECT)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		rc:RegisterEffect(e2,true)
	end
end
-- 判断是否满足攻击力翻倍效果的发动条件（在伤害步骤内且对方为龙族）
function c45667991.atkcon(e)
	-- 获取当前游戏阶段
	local ph=Duel.GetCurrentPhase()
	local bc=e:GetHandler():GetBattleTarget()
	return (ph==PHASE_DAMAGE or ph==PHASE_DAMAGE_CAL) and bc and bc:IsRace(RACE_DRAGON)
end
-- 设置攻击力翻倍效果的值为原本攻击力的2倍
function c45667991.atkval(e,c)
	return e:GetHandler():GetBaseAttack()*2
end
