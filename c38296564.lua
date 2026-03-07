--安全地帯
-- 效果：
-- 以场上1只表侧攻击表示怪兽为对象才能把这张卡发动。
-- ①：只要这张卡在魔法与陷阱区域存在，那只表侧表示怪兽不会成为对方的效果的对象，不会被战斗以及对方的效果破坏，不能向对方直接攻击。这张卡从场上离开时那只怪兽破坏。那只怪兽从场上离开时这张卡破坏。
function c38296564.initial_effect(c)
	-- ①：只要这张卡在魔法与陷阱区域存在，那只表侧表示怪兽不会成为对方的效果的对象，不会被战斗以及对方的效果破坏，不能向对方直接攻击。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetTarget(c38296564.target)
	e1:SetOperation(c38296564.operation)
	c:RegisterEffect(e1)
	-- 这张卡从场上离开时那只怪兽破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e2:SetCode(EVENT_LEAVE_FIELD_P)
	e2:SetOperation(c38296564.checkop)
	c:RegisterEffect(e2)
	-- 那只怪兽从场上离开时这张卡破坏。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_SINGLE)
	e3:SetCode(EVENT_LEAVE_FIELD)
	e3:SetOperation(c38296564.desop)
	e3:SetLabelObject(e2)
	c:RegisterEffect(e3)
	-- 以场上1只表侧攻击表示怪兽为对象才能把这张卡发动。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e4:SetRange(LOCATION_SZONE)
	e4:SetCode(EVENT_LEAVE_FIELD)
	e4:SetProperty(EFFECT_FLAG_DELAY)
	e4:SetCondition(c38296564.descon2)
	e4:SetOperation(c38296564.desop2)
	c:RegisterEffect(e4)
	-- 只要这张卡在魔法与陷阱区域存在，那只表侧表示怪兽不会成为对方的效果的对象
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
-- 检索满足条件的表侧攻击表示怪兽
function c38296564.filter(c)
	return c:IsFaceup() and c:IsAttackPos()
end
-- 选择表侧攻击表示的怪兽作为对象
function c38296564.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c38296564.filter(chkc) end
	-- 判断是否满足选择对象的条件
	if chk==0 then return Duel.IsExistingTarget(c38296564.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 向玩家提示选择表侧攻击表示的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUPATTACK)  --"请选择表侧攻击表示的怪兽"
	-- 选择表侧攻击表示的怪兽作为对象
	Duel.SelectTarget(tp,c38296564.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
end
-- 将选中的怪兽设置为该卡的效果对象
function c38296564.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前连锁中被选择的目标怪兽
	local tc=Duel.GetFirstTarget()
	if c:IsRelateToEffect(e) and tc:IsFaceup() and tc:IsRelateToEffect(e) then
		c:SetCardTarget(tc)
	end
end
-- 判断目标怪兽是否为己方控制
function c38296564.acon(e)
	return e:GetHandlerPlayer()==e:GetHandler():GetFirstCardTarget():GetControler()
end
-- 判断效果来源是否为对方
function c38296564.efilter(e,re)
	return e:GetHandlerPlayer()~=re:GetOwnerPlayer()
end
-- 判断效果处理者是否为对方
function c38296564.tgval(e,re,rp)
	return rp==1-e:GetHandlerPlayer()
end
-- 检查该卡是否被无效
function c38296564.checkop(e,tp,eg,ep,ev,re,r,rp)
	if e:GetHandler():IsDisabled() then
		e:SetLabel(1)
	else e:SetLabel(0) end
end
-- 当该卡离开场时，若未被无效则破坏目标怪兽
function c38296564.desop(e,tp,eg,ep,ev,re,r,rp)
	if e:GetLabelObject():GetLabel()~=0 then return end
	local tc=e:GetHandler():GetFirstCardTarget()
	if tc and tc:IsLocation(LOCATION_MZONE) then
		-- 破坏目标怪兽
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
-- 判断是否为目标怪兽离场
function c38296564.descon2(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetHandler():GetFirstCardTarget()
	return tc and eg:IsContains(tc)
end
-- 当目标怪兽离场时，破坏该卡
function c38296564.desop2(e,tp,eg,ep,ev,re,r,rp)
	-- 破坏该卡
	Duel.Destroy(e:GetHandler(),REASON_EFFECT)
end
