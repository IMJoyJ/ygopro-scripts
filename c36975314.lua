--大捕り物
-- 效果：
-- ①：以对方场上1只表侧表示怪兽为对象才能把这张卡发动。得到那只怪兽的控制权。那只怪兽在自己场上存在的场合，不能攻击，不能把效果发动。那只怪兽从场上离开时这张卡破坏。
function c36975314.initial_effect(c)
	-- ①：以对方场上1只表侧表示怪兽为对象才能把这张卡发动。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_CONTROL)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_CONTINUOUS_TARGET)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e1:SetTarget(c36975314.target)
	e1:SetOperation(c36975314.operation)
	c:RegisterEffect(e1)
	-- 那只怪兽从场上离开时这张卡破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCode(EVENT_LEAVE_FIELD)
	e2:SetCondition(c36975314.descon)
	e2:SetOperation(c36975314.desop)
	c:RegisterEffect(e2)
	-- 得到那只怪兽的控制权。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_TARGET)
	e3:SetCode(EFFECT_SET_CONTROL)
	e3:SetRange(LOCATION_SZONE)
	e3:SetValue(c36975314.ctval)
	c:RegisterEffect(e3)
	-- 那只怪兽在自己场上存在的场合，不能攻击。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_TARGET)
	e4:SetCode(EFFECT_CANNOT_ATTACK)
	e4:SetRange(LOCATION_SZONE)
	e4:SetCondition(c36975314.effcon)
	c:RegisterEffect(e4)
	local e5=e4:Clone()
	e5:SetCode(EFFECT_CANNOT_TRIGGER)
	c:RegisterEffect(e5)
end
-- 筛选可作为对象的怪兽：必须表侧表示且控制权可以改变。
function c36975314.filter(c)
	return c:IsFaceup() and c:IsControlerCanBeChanged()
end
-- 发动时的目标选择处理：确认存在可选择的对方表侧表示怪兽，选择1只作为对象，并登记为改变控制权效果。
function c36975314.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return c36975314.filter(chkc) and chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) end
	-- 发动合法性检查：确认对方场上有至少1只满足条件的表侧表示怪兽可以被选择。
	if chk==0 then return Duel.IsExistingTarget(c36975314.filter,tp,0,LOCATION_MZONE,1,nil) end
	-- 向操作玩家显示选择提示，要求选择要改变控制权的怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONTROL)  --"请选择要改变控制权的怪兽"
	-- 从对方场上选择1只符合条件的表侧表示怪兽，并将其登记为这次连锁的对象。
	local g=Duel.SelectTarget(tp,c36975314.filter,tp,0,LOCATION_MZONE,1,1,nil)
	-- 登记操作信息：该效果属于改变控制权（CATEGORY_CONTROL），对象为g，数量为1。
	Duel.SetOperationInfo(0,CATEGORY_CONTROL,g,1,0,0)
end
-- 效果处理：若这张卡和选择的目标怪兽仍与效果关联，则将目标怪兽设为这张卡的永续对象，用于持续获得控制权及后续判定。
function c36975314.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取这张卡发动时选择的目标怪兽。
	local tc=Duel.GetFirstTarget()
	if c:IsRelateToEffect(e) and tc:IsRelateToEffect(e) then
		c:SetCardTarget(tc)
	end
end
-- 效果适用条件：这张卡的永续对象（获得控制权的怪兽）的控制者等于这张卡的控制者（即该怪兽在自己场上）。
function c36975314.effcon(e)
	return e:GetHandler():GetFirstCardTarget():GetControler()==e:GetHandlerPlayer()
end
-- 控制权变更值：将目标怪兽的控制权变更给这张卡的控制者。
function c36975314.ctval(e,c)
	return e:GetHandlerPlayer()
end
-- 破坏条件：这张卡的永续对象怪兽从场上离开时满足条件。
function c36975314.descon(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetHandler():GetFirstCardTarget()
	return tc and eg:IsContains(tc)
end
-- 破坏处理：将这张卡破坏。
function c36975314.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 以效果原因将这张卡破坏。
	Duel.Destroy(e:GetHandler(),REASON_EFFECT)
end
