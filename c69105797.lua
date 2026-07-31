--捕食植物スキッド・ドロセーラ
-- 效果：
-- ①：把这张卡从手卡送去墓地，以自己场上1只表侧表示怪兽为对象才能发动。这个回合，那只怪兽可以向有捕食指示物放置的对方怪兽全部各作1次攻击。
-- ②：表侧表示的这张卡从场上离开的场合发动。给对方场上的特殊召唤的怪兽全部各放置1个捕食指示物。有捕食指示物放置的2星以上的怪兽的等级变成1星。
function c69105797.initial_effect(c)
	-- 创建效果e1，描述为卡片效果提示69105797的第0个，类型为起动效果，发动范围为手牌，具有对象选择属性，条件为c69105797.condition函数，费用为c69105797.cost函数，目标为c69105797.target函数，操作为c69105797.operation函数，并将效果注册到卡片c。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(69105797,0))
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCondition(c69105797.condition)
	e1:SetCost(c69105797.cost)
	e1:SetTarget(c69105797.target)
	e1:SetOperation(c69105797.operation)
	c:RegisterEffect(e1)
	-- 创建效果e2，类别为指示物效果，类型为单次触发效果，触发条件为离开场上事件，条件为c69105797.ccon函数，操作为c69105797.cop函数，并将效果注册到卡片c。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_COUNTER)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_LEAVE_FIELD)
	e2:SetCondition(c69105797.ccon)
	e2:SetOperation(c69105797.cop)
	c:RegisterEffect(e2)
end
c69105797.mentioned_counter={
	[0x1041]=true,
}
-- 检查当前回合玩家是否能够进入战斗阶段。
function c69105797.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 返回Duel.IsAbleToEnterBP()的执行结果
	return Duel.IsAbleToEnterBP()
end
-- 定义了效果e的费用处理函数。如果chk为0，则判断效果发动者能否作为送墓地的对象；否则，将效果发动者以REASON_COST原因送去墓地。
function c69105797.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToGraveAsCost() end
	-- 将效果发动者以REASON_COST原因送去墓地
	Duel.SendtoGrave(e:GetHandler(),REASON_COST)
end
-- 定义了效果e的目标选择函数。如果chkc为真，则判断目标卡片是否在怪兽区、由当前玩家控制且表侧表示；如果chk为0，则判断是否存在满足Card.IsFaceup的卡片；否则，显示提示信息并选择目标卡。
function c69105797.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and chkc:IsFaceup() end
	-- 检查是否有表侧表示的卡片存在于怪兽区域
	if chk==0 then return Duel.IsExistingTarget(Card.IsFaceup,tp,LOCATION_MZONE,0,1,nil) end
	-- 向玩家发送提示信息“请选择表侧表示的卡”。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择一张表侧表示的怪兽作为效果的目标。
	Duel.SelectTarget(tp,Card.IsFaceup,tp,LOCATION_MZONE,0,1,1,nil)
end
-- 定义了效果e的操作函数。获取第一个目标卡tc，如果tc与效果相关，则创建效果e1，类型为单次效果，代码为允许攻击所有怪兽，属性为不可无效化，重置条件为事件、标准重置、阶段结束，值为c69105797.atkfilter函数，并将效果注册到tc。
function c69105797.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的第一个目标卡片
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 创建单次效果e1，允许攻击所有怪兽，不可被无效化，在指定条件下重置，并使用c69105797.atkfilter函数判断是否可以发动。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_ATTACK_ALL)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		e1:SetValue(c69105797.atkfilter)
		tc:RegisterEffect(e1)
	end
end
-- 定义了用于过滤卡片的函数c69105797.atkfilter。如果卡片c的捕食指示物数量大于0，则返回真。
function c69105797.atkfilter(e,c)
	return c:GetCounter(0x1041)>0
end
-- 定义了效果e的条件函数ccon。获取效果发动者c，并判断其是否为正面表示。
function c69105797.ccon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsPreviousPosition(POS_FACEUP)
end
-- 定义了用于过滤卡片的函数cfilter。如果卡片c是表侧表示、特殊召唤且可以添加一个0x1041计数器，则返回真。
function c69105797.cfilter(c)
	return c:IsFaceup() and c:IsSummonType(SUMMON_TYPE_SPECIAL) and c:IsCanAddCounter(0x1041,1)
end
-- 定义了效果e的操作函数cop。获取效果发动者c，从怪兽区筛选满足cfilter的卡片组g，获取g中的第一张卡tc，循环遍历g中的每张卡，为tc添加一个0x1041计数器，如果tc等级大于2，则创建单次效果e1，类型为单次效果，属性为不可无效化，代码为改变等级，重置条件为事件和标准重置，条件为c69105797.lvcon函数，值为1，并将效果注册到tc。
function c69105797.cop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 从怪兽区获取满足条件的卡片组
	local g=Duel.GetMatchingGroup(c69105797.cfilter,tp,0,LOCATION_MZONE,nil)
	local tc=g:GetFirst()
	while tc do
		tc:AddCounter(0x1041,1)
		if tc:IsLevelAbove(2) then
			-- 创建单次效果e1，改变等级，不可被无效化，在指定条件下重置，并使用c69105797.lvcon函数判断是否可以发动。
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			e1:SetCode(EFFECT_CHANGE_LEVEL)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			e1:SetCondition(c69105797.lvcon)
			e1:SetValue(1)
			tc:RegisterEffect(e1)
		end
		tc=g:GetNext()
	end
end
-- 定义了用于判断的函数lvcon。如果卡片e的持有者捕食指示物数量大于0，则返回真。
function c69105797.lvcon(e)
	return e:GetHandler():GetCounter(0x1041)>0
end
