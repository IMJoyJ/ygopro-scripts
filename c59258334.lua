--洗脳光線
-- 效果：
-- 选择放置有A指示物的对方场上1只怪兽得到控制权。每次自己的结束阶段时，得到控制权的怪兽的A指示物取除1个。得到控制权的怪兽的A指示物全部被取除或者那只怪兽被破坏的场合，这张卡破坏。
function c59258334.initial_effect(c)
	-- 选择放置有A指示物的对方场上1只怪兽得到控制权。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_CONTROL)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_CONTINUOUS_TARGET)
	e1:SetTarget(c59258334.target)
	e1:SetOperation(c59258334.operation)
	c:RegisterEffect(e1)
	-- 得到控制权的怪兽的A指示物全部被取除……的场合，这张卡破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCode(EFFECT_SELF_DESTROY)
	e2:SetCondition(c59258334.descon)
	c:RegisterEffect(e2)
	-- 或者那只怪兽被破坏的场合，这张卡破坏。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCode(EVENT_LEAVE_FIELD)
	e3:SetCondition(c59258334.descon2)
	e3:SetOperation(c59258334.desop2)
	c:RegisterEffect(e3)
	-- 每次自己的结束阶段时，得到控制权的怪兽的A指示物取除1个。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e4:SetRange(LOCATION_SZONE)
	e4:SetCode(EVENT_PHASE+PHASE_END)
	e4:SetCountLimit(1)
	e4:SetCondition(c59258334.rccon)
	e4:SetOperation(c59258334.rcop)
	c:RegisterEffect(e4)
	-- 选择放置有A指示物的对方场上1只怪兽得到控制权。
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_TARGET)
	e5:SetCode(EFFECT_SET_CONTROL)
	e5:SetRange(LOCATION_SZONE)
	e5:SetTarget(c59258334.cttg)
	e5:SetValue(c59258334.ctval)
	c:RegisterEffect(e5)
end
-- 过滤放置有A指示物且可以改变控制权的怪兽
function c59258334.filter(c)
	return c:GetCounter(0x100e)>0 and c:IsControlerCanBeChanged()
end
-- 效果发动时的对象选择与操作信息设置
function c59258334.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and c59258334.filter(chkc) end
	-- 判断对方场上是否存在符合条件的、放置有A指示物且可以改变控制权的怪兽
	if chk==0 then return Duel.IsExistingTarget(c59258334.filter,tp,0,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择要改变控制权的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONTROL)  --"请选择要改变控制权的怪兽"
	-- 选择对方场上1只符合条件的怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c59258334.filter,tp,0,LOCATION_MZONE,1,1,nil)
	-- 设置当前连锁的操作信息为改变控制权
	Duel.SetOperationInfo(0,CATEGORY_CONTROL,g,1,0,0)
end
-- 效果处理时，若对象怪兽符合条件则与这张卡建立持续对象关系
function c59258334.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前连锁中被选择的效果对象怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:GetCounter(0x100e)>0 and tc:IsRelateToEffect(e) then
		c:SetCardTarget(tc)
	end
end
-- 判断作为持续对象的怪兽是否仍放置有A指示物
function c59258334.cttg(e,c)
	return c:GetCounter(0x100e)>0
end
-- 将持续对象的控制权转移给这张卡的控制者
function c59258334.ctval(e,c)
	return e:GetHandlerPlayer()
end
-- 判断持续对象的A指示物是否全部被取除，若是则满足自我破坏条件
function c59258334.descon(e)
	local c=e:GetHandler()
	if c:GetCardTargetCount()==0 then return false end
	return c:GetFirstCardTarget():GetCounter(0x100e)==0
end
-- 判断被破坏而离场的卡是否是这张卡的持续对象
function c59258334.descon2(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetHandler():GetFirstCardTarget()
	return tc and eg:IsContains(tc) and tc:IsReason(REASON_DESTROY)
end
-- 因持续对象被破坏而将这张卡自身破坏
function c59258334.desop2(e,tp,eg,ep,ev,re,r,rp)
	-- 以效果破坏这张卡自身
	Duel.Destroy(e:GetHandler(),REASON_EFFECT)
end
-- 判断当前是否为自己的结束阶段，且这张卡是否存在持续对象
function c59258334.rccon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前回合玩家是否为自己，且这张卡当前存在持续对象
	return Duel.GetTurnPlayer()==tp and e:GetHandler():GetFirstCardTarget()
end
-- 在结束阶段从持续对象怪兽上取除1个A指示物并触发相关事件
function c59258334.rcop(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetHandler():GetFirstCardTarget()
	tc:RemoveCounter(tp,0x100e,1,REASON_EFFECT)
	-- 手动触发去除A指示物的事件以供其他卡片确认时点
	Duel.RaiseEvent(e:GetHandler(),EVENT_REMOVE_COUNTER+0x100e,e,REASON_EFFECT,tp,tp,1)
end
