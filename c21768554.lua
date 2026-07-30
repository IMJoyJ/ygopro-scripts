--集団催眠
-- 效果：
-- 自己场上有名字带有「外星」的怪兽存在时才能发动。选择对方场上存在的最多3只放置有A指示物的怪兽得到控制权。这张卡在发动回合的结束阶段时破坏。
function c21768554.initial_effect(c)
	-- 自己场上有名字带有「外星」的怪兽存在时才能发动。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_CONTROL)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_CONTINUOUS_TARGET)
	e1:SetCondition(c21768554.condition)
	e1:SetTarget(c21768554.target)
	e1:SetOperation(c21768554.operation)
	c:RegisterEffect(e1)
	-- 这张卡在发动回合的结束阶段时破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(21768554,0))  --"破坏"
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_PHASE+PHASE_END)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1)
	e2:SetCondition(c21768554.descon)
	e2:SetOperation(c21768554.desop)
	c:RegisterEffect(e2)
	-- 选择对方场上存在的最多3只放置有A指示物的怪兽得到控制权。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_TARGET)
	e3:SetCode(EFFECT_SET_CONTROL)
	e3:SetRange(LOCATION_SZONE)
	e3:SetTarget(c21768554.cttg)
	e3:SetValue(c21768554.ctval)
	c:RegisterEffect(e3)
end
c21768554.mentioned_counter={
	[0x100e]=true,
}
-- 过滤函数，检查以玩家tp来看的自己的主要怪兽区是否存在至少1张名字带有「外星」的表侧表示怪兽。
function c21768554.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0xc)
end
-- 判断效果是否可以发动，检查以玩家tp来看的自己的主要怪兽区是否存在至少1张名字带有「外星」的表侧表示怪兽。
function c21768554.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检查以玩家tp来看的自己的主要怪兽区是否存在至少1张名字带有「外星」的表侧表示怪兽。
	return Duel.IsExistingMatchingCard(c21768554.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
-- 过滤函数，检查目标怪兽是否放置有A指示物且可以改变控制权。
function c21768554.filter(c)
	return c:GetCounter(0x100e)>0 and c:IsControlerCanBeChanged()
end
-- 设置效果的目标选择处理，检查对方场上是否存在满足条件的怪兽，并选择最多3只进行控制权变更。
function c21768554.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and c21768554.filter(chkc) end
	-- 检查对方场上是否存在至少1只满足条件的怪兽。
	if chk==0 then return Duel.IsExistingTarget(c21768554.filter,tp,0,LOCATION_MZONE,1,nil) end
	-- 获取玩家tp在对方主要怪兽区可用于放置怪兽的空格数。
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE,1-tp,LOCATION_REASON_CONTROL)
	if ft>3 then ft=3 end
	-- 向玩家tp发送提示信息“请选择要改变控制权的怪兽”。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONTROL)  --"请选择要改变控制权的怪兽"
	-- 选择满足条件的最多3只对方场上的怪兽作为效果对象。
	local g=Duel.SelectTarget(tp,c21768554.filter,tp,0,LOCATION_MZONE,1,ft,nil)
	-- 设置当前处理的连锁的操作信息，指定将要进行控制权变更的怪兽数量。
	Duel.SetOperationInfo(0,CATEGORY_CONTROL,g,g:GetCount(),0,0)
end
-- 执行效果处理，设置目标怪兽与本卡之间的关联，并记录flag以触发结束阶段破坏效果。
function c21768554.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前连锁中已选定的目标卡片组。
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	-- 判断目标怪兽数量是否超过玩家tp在对方主要怪兽区的可用空格数。
	if g:GetCount()>Duel.GetLocationCount(tp,LOCATION_MZONE) then return end
	local tc=g:GetFirst()
	while tc do
		if tc:IsFaceup() and tc:GetCounter(0x100e)>0 and tc:IsRelateToEffect(e) then
			c:SetCardTarget(tc)
		end
		tc=g:GetNext()
	end
	c:RegisterFlagEffect(21768554,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1)
end
-- 设置控制权变更效果的目标过滤条件，仅对放置有A指示物的怪兽生效。
function c21768554.cttg(e,c)
	return c:GetCounter(0x100e)>0
end
-- 设置控制权变更效果的控制权归属值，即由本卡的持有者获得控制权。
function c21768554.ctval(e,c)
	return e:GetHandlerPlayer()
end
-- 判断是否满足破坏条件，检查本卡是否已记录flag。
function c21768554.descon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetFlagEffect(21768554)~=0
end
-- 执行破坏处理，将本卡因效果原因破坏。
function c21768554.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 以效果原因将本卡破坏。
	Duel.Destroy(e:GetHandler(),REASON_EFFECT)
end
