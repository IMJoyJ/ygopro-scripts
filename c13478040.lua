--ドングリス
-- 效果：
-- 每次对方把怪兽特殊召唤，给这张卡放置1个橡子指示物。可以把这张卡放置的1个橡子指示物取除，选择对方场上存在的1只怪兽破坏。
function c13478040.initial_effect(c)
	c:EnableCounterPermit(0x17)
	-- 每次对方把怪兽特殊召唤，给这张卡放置1个橡子指示物。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetOperation(c13478040.ctop)
	c:RegisterEffect(e1)
	-- 可以把这张卡放置的1个橡子指示物取除，选择对方场上存在的1只怪兽破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(13478040,0))  --"破坏"
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCost(c13478040.descost)
	e2:SetTarget(c13478040.destg)
	e2:SetOperation(c13478040.desop)
	c:RegisterEffect(e2)
end
-- 过滤器函数，用于判断怪兽是否为指定玩家召唤的
function c13478040.cfilter(c,tp)
	return c:IsSummonPlayer(tp)
end
-- 当怪兽特殊召唤成功时触发，用于给自身添加橡子指示物
function c13478040.ctop(e,tp,eg,ep,ev,re,r,rp)
	if eg:IsExists(c13478040.cfilter,1,nil,1-tp) then
		e:GetHandler():AddCounter(0x17,1)
	end
end
-- 破坏效果的费用支付函数，移除自身1个橡子指示物
function c13478040.descost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsCanRemoveCounter(tp,0x17,1,REASON_COST) end
	e:GetHandler():RemoveCounter(tp,0x17,1,REASON_COST)
end
-- 破坏效果的目标选择函数，选择对方场上的1只怪兽作为目标
function c13478040.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(1-tp) and chkc:IsLocation(LOCATION_MZONE) end
	-- 判断是否满足选择目标的条件，确保对方场上存在怪兽
	if chk==0 then return Duel.IsExistingTarget(aux.TRUE,tp,0,LOCATION_MZONE,1,nil) end
	-- 向玩家发送提示信息，提示选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	-- 选择对方场上的1只怪兽作为破坏目标
	local g=Duel.SelectTarget(tp,aux.TRUE,tp,0,LOCATION_MZONE,1,1,nil)
	-- 设置当前连锁的操作信息，指定将要破坏的卡
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 破坏效果的处理函数，对目标怪兽进行破坏
function c13478040.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的目标卡
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标怪兽破坏
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
