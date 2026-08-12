--大捕り物
-- 效果：
-- ①：以对方场上1只表侧表示怪兽为对象才能把这张卡发动。得到那只怪兽的控制权。那只怪兽在自己场上存在的场合，不能攻击，不能把效果发动。那只怪兽从场上离开时这张卡破坏。
function c36975314.initial_effect(c)
	-- ①：以对方场上1只表侧表示怪兽为对象才能把这张卡发动。得到那只怪兽的控制权。
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
	-- 那只怪兽在自己场上存在的场合，不能攻击，不能把效果发动。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_TARGET)
	e3:SetCode(EFFECT_SET_CONTROL)
	e3:SetRange(LOCATION_SZONE)
	e3:SetValue(c36975314.ctval)
	c:RegisterEffect(e3)
	-- 以对方场上1只表侧表示怪兽为对象才能把这张卡发动。
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
-- 检索满足条件的对方场上表侧表示怪兽
function c36975314.filter(c)
	return c:IsFaceup() and c:IsControlerCanBeChanged()
end
-- 设置选择对象的处理函数
function c36975314.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return c36975314.filter(chkc) and chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) end
	-- 判断是否满足选择对象的条件
	if chk==0 then return Duel.IsExistingTarget(c36975314.filter,tp,0,LOCATION_MZONE,1,nil) end
	-- 向玩家提示选择要改变控制权的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONTROL)  --"请选择要改变控制权的怪兽"
	-- 选择一只对方场上的表侧表示怪兽作为对象
	local g=Duel.SelectTarget(tp,c36975314.filter,tp,0,LOCATION_MZONE,1,1,nil)
	-- 设置效果处理信息，指定将要改变控制权的怪兽
	Duel.SetOperationInfo(0,CATEGORY_CONTROL,g,1,0,0)
end
-- 设置效果处理函数，将目标怪兽与大逮捕卡绑定
function c36975314.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前连锁效果的对象怪兽
	local tc=Duel.GetFirstTarget()
	if c:IsRelateToEffect(e) and tc:IsRelateToEffect(e) then
		c:SetCardTarget(tc)
	end
end
-- 判断目标怪兽是否在自己场上
function c36975314.effcon(e)
	return e:GetHandler():GetFirstCardTarget():GetControler()==e:GetHandlerPlayer()
end
-- 设置控制权为效果持有者
function c36975314.ctval(e,c)
	return e:GetHandlerPlayer()
end
-- 判断目标怪兽是否离开场上
function c36975314.descon(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetHandler():GetFirstCardTarget()
	return tc and eg:IsContains(tc)
end
-- 设置破坏效果的处理函数
function c36975314.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 将大逮捕卡因目标怪兽离场而破坏
	Duel.Destroy(e:GetHandler(),REASON_EFFECT)
end
