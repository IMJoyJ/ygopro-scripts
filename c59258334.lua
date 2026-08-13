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
	-- 得到控制权的怪兽的A指示物全部被取除的场合，这张卡破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCode(EFFECT_SELF_DESTROY)
	e2:SetCondition(c59258334.descon)
	c:RegisterEffect(e2)
	-- 那只怪兽被破坏的场合，这张卡破坏。
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
c59258334.mentioned_counter={
	[0x100e]=true,
}
-- 筛选条件函数：放置有A指示物且控制权可以变更的怪兽
function c59258334.filter(c)
	return c:GetCounter(0x100e)>0 and c:IsControlerCanBeChanged()
end
-- 目标选择函数：确认对方场上存在可作为对象的符合条件怪兽后，让玩家选择1只并设置控制权变更的操作信息
function c59258334.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and c59258334.filter(chkc) end
	-- 检查对方怪兽区域是否存在1只以上放置有A指示物且可以变更控制权、并能成为效果对象的怪兽
	if chk==0 then return Duel.IsExistingTarget(c59258334.filter,tp,0,LOCATION_MZONE,1,nil) end
	-- 向玩家提示「请选择要改变控制权的怪兽」
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONTROL)  --"请选择要改变控制权的怪兽"
	-- 让玩家从对方怪兽区域选择1只放置有A指示物且可以变更控制权的怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c59258334.filter,tp,0,LOCATION_MZONE,1,1,nil)
	-- 设置本次连锁的操作信息为控制权变更（CATEGORY_CONTROL），对象为选择的1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_CONTROL,g,1,0,0)
end
-- 效果处理：取得对象怪兽，若其表侧表示、仍放置有A指示物且与本效果保持关联，则将其设为本卡的持续取对象
function c59258334.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 取得当前连锁的效果对象怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:GetCounter(0x100e)>0 and tc:IsRelateToEffect(e) then
		c:SetCardTarget(tc)
	end
end
-- 持续取对象的目标限定函数：仅对放置有A指示物的怪兽有效
function c59258334.cttg(e,c)
	return c:GetCounter(0x100e)>0
end
-- 控制权设定值函数：将控制权设定为本卡控制者一方
function c59258334.ctval(e,c)
	return e:GetHandlerPlayer()
end
-- 自我破坏条件：本卡持续取对象的怪兽的A指示物全部被取除（为0个）时成立
function c59258334.descon(e)
	local c=e:GetHandler()
	if c:GetCardTargetCount()==0 then return false end
	return c:GetFirstCardTarget():GetCounter(0x100e)==0
end
-- 触发条件：本卡持续取对象的怪兽因破坏而离场时成立
function c59258334.descon2(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetHandler():GetFirstCardTarget()
	return tc and eg:IsContains(tc) and tc:IsReason(REASON_DESTROY)
end
-- 条件满足时将本卡以效果破坏
function c59258334.desop2(e,tp,eg,ep,ev,re,r,rp)
	-- 以效果原因破坏本卡（洗脑光线自身）
	Duel.Destroy(e:GetHandler(),REASON_EFFECT)
end
-- 触发条件：当前是自己的回合（结束阶段）且本卡存在持续取对象的怪兽
function c59258334.rccon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前回合玩家是否为自己，且本卡是否仍有持续取对象的怪兽
	return Duel.GetTurnPlayer()==tp and e:GetHandler():GetFirstCardTarget()
end
-- 效果处理：将本卡持续取对象的怪兽的A指示物取除1个，并手动触发去除A指示物的时点事件
function c59258334.rcop(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetHandler():GetFirstCardTarget()
	tc:RemoveCounter(tp,0x100e,1,REASON_EFFECT)
	-- 手动触发「去除A指示物时」的时点事件（RemoveCounter不会自动触发，需用RaiseEvent补发）
	Duel.RaiseEvent(e:GetHandler(),EVENT_REMOVE_COUNTER+0x100e,e,REASON_EFFECT,tp,tp,1)
end
