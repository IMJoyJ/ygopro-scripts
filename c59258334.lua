--洗脳光線
-- 效果：
-- 选择放置有A指示物的对方场上1只怪兽得到控制权。每次自己的结束阶段时，得到控制权的怪兽的A指示物取除1个。得到控制权的怪兽的A指示物全部被取除或者那只怪兽被破坏的场合，这张卡破坏。
function c59258334.initial_effect(c)
	-- 以放置有A指示物的对方场上1只怪兽为对象才能把这张卡发动。选择的怪兽得到控制权。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_CONTROL)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_CONTINUOUS_TARGET)
	e1:SetTarget(c59258334.target)
	e1:SetOperation(c59258334.operation)
	c:RegisterEffect(e1)
	-- 获得控制权的怪兽身上的A指示物全部被取除的场合，这张卡破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCode(EFFECT_SELF_DESTROY)
	e2:SetCondition(c59258334.descon)
	c:RegisterEffect(e2)
	-- 获得控制权的怪兽被破坏的场合，这张卡破坏。
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
	-- 只要这张卡在魔法与陷阱区域存在，得到控制权的目标怪兽控制权转移给己方（持续对象效果）。
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_TARGET)
	e5:SetCode(EFFECT_SET_CONTROL)
	e5:SetRange(LOCATION_SZONE)
	e5:SetTarget(c59258334.cttg)
	e5:SetValue(c59258334.ctval)
	c:RegisterEffect(e5)
end
c59258334.mentioned_counter={
	[0x100e]=true,
}
-- 目标过滤条件：带有A指示物（0x100e）且可以改变控制权的怪兽
function c59258334.filter(c)
	return c:GetCounter(0x100e)>0 and c:IsControlerCanBeChanged()
end
-- 效果发动准备：选择对方场上1只带有A指示物的怪兽为对象，设置控制权转移操作信息
function c59258334.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and c59258334.filter(chkc) end
	-- 发动条件检查：对方场上是否存在带有A指示物且可改变控制权的怪兽
	if chk==0 then return Duel.IsExistingTarget(c59258334.filter,tp,0,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择要改变控制权的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONTROL)  --"请选择要改变控制权的怪兽"
	-- 选择对方场上1只满足条件的怪兽作为对象
	local g=Duel.SelectTarget(tp,c59258334.filter,tp,0,LOCATION_MZONE,1,1,nil)
	-- 设置连锁操作信息：获得目标怪兽的控制权
	Duel.SetOperationInfo(0,CATEGORY_CONTROL,g,1,0,0)
end
-- 效果处理：建立此卡与目标怪兽的持续对象标记（绑定控制权关系）
function c59258334.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取设定的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:GetCounter(0x100e)>0 and tc:IsRelateToEffect(e) then
		c:SetCardTarget(tc)
	end
end
-- 控制权生效条件：目标怪兽身上仍有A指示物
function c59258334.cttg(e,c)
	return c:GetCounter(0x100e)>0
end
-- 控制权指向：将目标怪兽控制权赋予发动此卡的玩家
function c59258334.ctval(e,c)
	return e:GetHandlerPlayer()
end
-- 自毁条件1：已建立对象关系且目标怪兽身上的A指示物数量变为0
function c59258334.descon(e)
	local c=e:GetHandler()
	if c:GetCardTargetCount()==0 then return false end
	return c:GetFirstCardTarget():GetCounter(0x100e)==0
end
-- 自毁条件2：目标怪兽被破坏并离开场地
function c59258334.descon2(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetHandler():GetFirstCardTarget()
	return tc and eg:IsContains(tc) and tc:IsReason(REASON_DESTROY)
end
-- 自毁处理：破坏这张卡
function c59258334.desop2(e,tp,eg,ep,ev,re,r,rp)
	-- 将这张卡送去墓地破坏
	Duel.Destroy(e:GetHandler(),REASON_EFFECT)
end
-- 指示物去除条件：己方结束阶段且持续对象怪兽存在
function c59258334.rccon(e,tp,eg,ep,ev,re,r,rp)
	-- 确认当前为己方回合的结束阶段，且存在所绑定的目标怪兽
	return Duel.GetTurnPlayer()==tp and e:GetHandler():GetFirstCardTarget()
end
-- 指示物去除处理：取除目标怪兽上的1个A指示物，并触发指示物去除事件
function c59258334.rcop(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetHandler():GetFirstCardTarget()
	tc:RemoveCounter(tp,0x100e,1,REASON_EFFECT)
	-- 引发指示物被取除（0x100e）的全局事件
	Duel.RaiseEvent(e:GetHandler(),EVENT_REMOVE_COUNTER+0x100e,e,REASON_EFFECT,tp,tp,1)
end
