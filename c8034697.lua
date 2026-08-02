--魔法の操り人形
-- 效果：
-- 只要这张卡在场上表侧表示存在，每次自己或者对方把魔法卡发动，给这张卡放置1个魔力指示物。这张卡放置的魔力指示物每有1个，这张卡的攻击力上升200。此外，可以把这张卡放置的2个魔力指示物取除，场上存在的1只怪兽破坏。
function c8034697.initial_effect(c)
	c:EnableCounterPermit(0x1)
	-- 只要这张卡在场上表侧表示存在，每次自己或者对方把魔法卡发动，
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e0:SetCode(EVENT_CHAINING)
	e0:SetRange(LOCATION_MZONE)
	-- 记录连锁发生时这张卡在场上存在，以便后续处理中正确判断
	e0:SetOperation(aux.chainreg)
	c:RegisterEffect(e0)
	-- 只要这张卡在场上表侧表示存在，每次自己或者对方把魔法卡发动，给这张卡放置1个魔力指示物。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e1:SetCode(EVENT_CHAIN_SOLVING)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetRange(LOCATION_MZONE)
	e1:SetOperation(c8034697.acop)
	c:RegisterEffect(e1)
	-- 这张卡放置的魔力指示物每有1个，这张卡的攻击力上升200。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetValue(c8034697.attackup)
	c:RegisterEffect(e2)
	-- 此外，可以把这张卡放置的2个魔力指示物取除，场上存在的1只怪兽破坏。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(8034697,1))  --"破坏一只怪兽"
	e3:SetCategory(CATEGORY_DESTROY)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_MZONE)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetCost(c8034697.descost)
	e3:SetTarget(c8034697.destarg)
	e3:SetOperation(c8034697.desop)
	c:RegisterEffect(e3)
end
c8034697.mentioned_counter={
	[0x1]=true,
}
-- 效果处理：在魔法卡的发动处理完成时，如果这张卡在发动时就在场，则给它放置1个魔力指示物
function c8034697.acop(e,tp,eg,ep,ev,re,r,rp)
	if re:IsHasType(EFFECT_TYPE_ACTIVATE) and re:IsActiveType(TYPE_SPELL) and e:GetHandler():GetFlagEffect(FLAG_ID_CHAINING)>0 then
		e:GetHandler():AddCounter(0x1,1)
	end
end
-- 效果处理：计算上升的攻击力数值，即魔力指示物的数量乘200
function c8034697.attackup(e,c)
	return c:GetCounter(0x1)*200
end
-- 发动代价：把这张卡放置的2个魔力指示物取除
function c8034697.descost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsCanRemoveCounter(tp,0x1,2,REASON_COST) end
	e:GetHandler():RemoveCounter(tp,0x1,2,REASON_COST)
end
-- 效果对象和操作信息设置：以场上存在的1只怪兽为对象，设置破坏操作信息
function c8034697.destarg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) end
	-- 检查场上是否存在可以作为效果对象的怪兽
	if chk==0 then return Duel.IsExistingTarget(aux.TRUE,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 发送提示消息，让玩家选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 玩家选择场上存在的1只怪兽作为效果的对象
	local g=Duel.SelectTarget(tp,aux.TRUE,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 设置操作信息：包含破坏效果，预计破坏所选的怪兽
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 效果处理：将作为对象的那只怪兽破坏
function c8034697.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的作为效果对象的那只怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将那只怪兽效果破坏
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
