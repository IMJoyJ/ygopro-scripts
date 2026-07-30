--集団催眠
-- 效果：
-- 自己场上有名字带有「外星」的怪兽存在时才能发动。选择对方场上存在的最多3只放置有A指示物的怪兽得到控制权。这张卡在发动回合的结束阶段时破坏。
function c21768554.initial_effect(c)
	-- 发动时的效果，用于设置效果的分类、类型、触发条件、目标选择和处理函数
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_CONTROL)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_CONTINUOUS_TARGET)
	e1:SetCondition(c21768554.condition)
	e1:SetTarget(c21768554.target)
	e1:SetOperation(c21768554.operation)
	c:RegisterEffect(e1)
	-- 结束阶段时破坏效果，用于在发动回合的结束阶段时将此卡破坏
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(21768554,0))  --"破坏"
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_PHASE+PHASE_END)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1)
	e2:SetCondition(c21768554.descon)
	e2:SetOperation(c21768554.desop)
	c:RegisterEffect(e2)
	-- 控制权变更效果，用于将目标怪兽的控制权转移给使用者
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
-- 检查场上是否存在名字带有「外星」的怪兽
function c21768554.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0xc)
end
-- 判断是否满足发动条件，即自己场上有名字带有「外星」的怪兽存在
function c21768554.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检查以自己为玩家，在自己的主要怪兽区是否存在至少1张满足cfilter条件的卡
	return Duel.IsExistingMatchingCard(c21768554.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
-- 过滤函数，用于筛选放置有A指示物且可以改变控制权的怪兽
function c21768554.filter(c)
	return c:GetCounter(0x100e)>0 and c:IsControlerCanBeChanged()
end
-- 设置效果的目标选择逻辑，包括目标位置、控制权和数量限制，并提示选择怪兽
function c21768554.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and c21768554.filter(chkc) end
	-- 检查是否满足目标选择条件，即对方场上存在至少1只满足filter条件的怪兽
	if chk==0 then return Duel.IsExistingTarget(c21768554.filter,tp,0,LOCATION_MZONE,1,nil) end
	-- 获取自己在对方区域可用的怪兽区格子数，用于限制最多可选择的怪兽数量
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE,1-tp,LOCATION_REASON_CONTROL)
	if ft>3 then ft=3 end
	-- 提示玩家选择要改变控制权的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONTROL)  --"请选择要改变控制权的怪兽"
	-- 根据过滤条件从对方场上选择满足条件的怪兽作为目标
	local g=Duel.SelectTarget(tp,c21768554.filter,tp,0,LOCATION_MZONE,1,ft,nil)
	-- 设置操作信息，记录本次效果将要改变控制权的怪兽数量
	Duel.SetOperationInfo(0,CATEGORY_CONTROL,g,g:GetCount(),0,0)
end
-- 处理效果的执行逻辑，包括检查目标是否满足条件并注册控制权变更对象
function c21768554.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前连锁中设定的目标卡片组
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	-- 判断选择的目标数量是否超过自己场上可用的怪兽数量
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
-- 设置控制权变更效果的目标筛选条件，只有放置有A指示物的怪兽才能被选中
function c21768554.cttg(e,c)
	return c:GetCounter(0x100e)>0
end
-- 设置控制权变更效果的值，将目标怪兽的控制权转移给效果使用者
function c21768554.ctval(e,c)
	return e:GetHandlerPlayer()
end
-- 判断是否满足破坏条件，即此卡在发动回合的结束阶段时被触发
function c21768554.descon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetFlagEffect(21768554)~=0
end
-- 执行破坏操作，将此卡从场上破坏
function c21768554.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 以效果原因将此卡破坏
	Duel.Destroy(e:GetHandler(),REASON_EFFECT)
end
