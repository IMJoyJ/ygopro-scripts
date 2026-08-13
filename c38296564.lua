--安全地帯
-- 效果：
-- 以场上1只表侧攻击表示怪兽为对象才能把这张卡发动。
-- ①：只要这张卡在魔法与陷阱区域存在，那只表侧表示怪兽不会成为对方的效果的对象，不会被战斗以及对方的效果破坏，不能向对方直接攻击。这张卡从场上离开时那只怪兽破坏。那只怪兽从场上离开时这张卡破坏。
function c38296564.initial_effect(c)
	-- 以场上1只表侧攻击表示怪兽为对象才能把这张卡发动。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetTarget(c38296564.target)
	e1:SetOperation(c38296564.operation)
	c:RegisterEffect(e1)
	-- 这张卡从场上离开时那只怪兽破坏。（离场前记录是否无效，用于判断是否执行破坏）
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e2:SetCode(EVENT_LEAVE_FIELD_P)
	e2:SetOperation(c38296564.checkop)
	c:RegisterEffect(e2)
	-- 这张卡从场上离开时那只怪兽破坏。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_SINGLE)
	e3:SetCode(EVENT_LEAVE_FIELD)
	e3:SetOperation(c38296564.desop)
	e3:SetLabelObject(e2)
	c:RegisterEffect(e3)
	-- 那只怪兽从场上离开时这张卡破坏。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e4:SetRange(LOCATION_SZONE)
	e4:SetCode(EVENT_LEAVE_FIELD)
	e4:SetProperty(EFFECT_FLAG_DELAY)
	e4:SetCondition(c38296564.descon2)
	e4:SetOperation(c38296564.desop2)
	c:RegisterEffect(e4)
	-- “不会被战斗以及对方的效果破坏”中的“不会被战斗破坏”。
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_TARGET)
	e5:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e5:SetRange(LOCATION_SZONE)
	e5:SetValue(1)
	c:RegisterEffect(e5)
	local e6=e5:Clone()
	e6:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e6:SetValue(c38296564.efilter)
	c:RegisterEffect(e6)
	local e7=e6:Clone()
	e7:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e7:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e7:SetValue(c38296564.tgval)
	c:RegisterEffect(e7)
	local e8=e5:Clone()
	e8:SetCode(EFFECT_CANNOT_DIRECT_ATTACK)
	e8:SetCondition(c38296564.acon)
	c:RegisterEffect(e8)
end
-- 过滤条件：怪兽必须表侧表示且攻击表示。
function c38296564.filter(c)
	return c:IsFaceup() and c:IsAttackPos()
end
-- 发动时的目标选择函数：检查是否存在可对象怪兽，提示并选择场上1只表侧攻击表示怪兽作为对象。
function c38296564.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c38296564.filter(chkc) end
	-- 发动合法性检查：场上是否存在至少1只表侧攻击表示怪兽可以作为效果对象。
	if chk==0 then return Duel.IsExistingTarget(c38296564.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 向玩家显示“请选择表侧攻击表示的怪兽”的选择提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUPATTACK)  --"请选择表侧攻击表示的怪兽"
	-- 从双方怪兽区域选择1只表侧攻击表示怪兽，并将其登记为这张卡发动时的对象。
	Duel.SelectTarget(tp,c38296564.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
end
-- 效果处理时，若这张卡和对象怪兽均仍有效且对象怪兽仍为表侧攻击表示，则将对象怪兽设为这张卡的永续对象，使后续保护与限制效果持续指向该对象。
function c38296564.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 取得发动时选择的对象怪兽。
	local tc=Duel.GetFirstTarget()
	if c:IsRelateToEffect(e) and tc:IsFaceup() and tc:IsRelateToEffect(e) then
		c:SetCardTarget(tc)
	end
end
-- 判定“不能向对方直接攻击”的适用条件：仅当对象怪兽的控制者与这张卡的控制者相同（即对象是自己场上的怪兽）时，才对其适用不能直接攻击的限制。
function c38296564.acon(e)
	return e:GetHandlerPlayer()==e:GetHandler():GetFirstCardTarget():GetControler()
end
-- 判定效果破坏抗性的适用条件：造成破坏的效果的持有者不是这张卡的控制者（即对方的效果），此时才不会被破坏。
function c38296564.efilter(e,re)
	return e:GetHandlerPlayer()~=re:GetOwnerPlayer()
end
-- 判定“不能成为对方效果对象”的适用条件：效果发动者（rp）是这张卡控制者的对手。
function c38296564.tgval(e,re,rp)
	return rp==1-e:GetHandlerPlayer()
end
-- 离场前检查这张卡是否处于效果无效状态；若无效则标记label为1，以阻止离场时错误诱发对象怪兽的破坏。
function c38296564.checkop(e,tp,eg,ep,ev,re,r,rp)
	if e:GetHandler():IsDisabled() then
		e:SetLabel(1)
	else e:SetLabel(0) end
end
-- 这张卡从场上离开且未被无效时，将其对象怪兽破坏。
function c38296564.desop(e,tp,eg,ep,ev,re,r,rp)
	if e:GetLabelObject():GetLabel()~=0 then return end
	local tc=e:GetHandler():GetFirstCardTarget()
	if tc and tc:IsLocation(LOCATION_MZONE) then
		-- 以‘效果’为破坏原因将对象怪兽破坏。
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
-- 检测离场事件组中是否包含这张卡的对象怪兽（即对象怪兽离场）。
function c38296564.descon2(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetHandler():GetFirstCardTarget()
	return tc and eg:IsContains(tc)
end
-- 对象怪兽离场时，将这张卡破坏。
function c38296564.desop2(e,tp,eg,ep,ev,re,r,rp)
	-- 以‘效果’为破坏原因将安全地带自身破坏。
	Duel.Destroy(e:GetHandler(),REASON_EFFECT)
end
