--魂のペンデュラム
-- 效果：
-- 这个卡名的①的效果1回合只能使用1次。
-- ①：以自己的灵摆区域2张卡为对象才能发动。作为对象的卡的灵摆刻度各自上升或下降1（最少到1）。
-- ②：每次自己的灵摆怪兽灵摆召唤给这张卡放置1个指示物。
-- ③：场上的灵摆怪兽的攻击力上升这张卡的指示物数量×300。
-- ④：把这张卡3个指示物取除才能发动。这个回合，自己在通常的灵摆召唤外加上只有1次，自己主要阶段可以把怪兽灵摆召唤。
function c34884015.initial_effect(c)
	c:EnableCounterPermit(0x4e)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- ①：以自己的灵摆区域2张卡为对象才能发动。作为对象的卡的灵摆刻度各自上升或下降1（最少到1）。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(34884015,0))  --"改变刻度"
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCountLimit(1,34884015)
	e2:SetRange(LOCATION_SZONE)
	e2:SetTarget(c34884015.target)
	e2:SetOperation(c34884015.operation)
	c:RegisterEffect(e2)
	-- ②：每次自己的灵摆怪兽灵摆召唤给这张卡放置1个指示物。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	e3:SetRange(LOCATION_SZONE)
	e3:SetOperation(c34884015.counterop)
	c:RegisterEffect(e3)
	-- ③：场上的灵摆怪兽的攻击力上升这张卡的指示物数量×300。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD)
	e4:SetCode(EFFECT_UPDATE_ATTACK)
	e4:SetRange(LOCATION_SZONE)
	e4:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	-- 筛选满足条件的卡片组，用于判断是否能发动效果
	e4:SetTarget(aux.TargetBoolFunction(Card.IsType,TYPE_PENDULUM))
	e4:SetValue(c34884015.atkval)
	c:RegisterEffect(e4)
	-- ④：把这张卡3个指示物取除才能发动。这个回合，自己在通常的灵摆召唤外加上只有1次，自己主要阶段可以把怪兽灵摆召唤。
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(34884015,3))  --"额外灵摆召唤"
	e5:SetType(EFFECT_TYPE_IGNITION)
	e5:SetRange(LOCATION_SZONE)
	e5:SetCost(c34884015.expcost)
	e5:SetTarget(c34884015.exptg)
	e5:SetOperation(c34884015.expop)
	c:RegisterEffect(e5)
end
-- 设置效果的目标为己方灵摆区的2张卡
function c34884015.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	-- 判断是否己方灵摆区存在2张卡
	if chk==0 then return Duel.IsExistingTarget(nil,tp,LOCATION_PZONE,0,2,nil) end
	-- 获取己方灵摆区的卡组
	local g=Duel.GetFieldGroup(tp,LOCATION_PZONE,0)
	-- 将获取到的卡组设置为效果对象
	Duel.SetTargetCard(g)
end
-- 处理效果的发动和执行逻辑，包括提示选择、刻度调整等
function c34884015.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前连锁中效果的对象卡片组
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	local tg=g:Filter(Card.IsRelateToEffect,nil,e)
	local tc=tg:GetFirst()
	while tc do
		-- 显示对象卡被选中的动画效果
		Duel.HintSelection(Group.FromCards(tc))
		local sel=0
		if tc:GetLeftScale()<=1 then
			-- 当左刻度小于等于1时，选择刻度上升选项
			sel=Duel.SelectOption(tp,aux.Stringid(34884015,1))  --"刻度上升"
		else
			-- 当左刻度大于1时，选择刻度上升或下降选项
			sel=Duel.SelectOption(tp,aux.Stringid(34884015,1),aux.Stringid(34884015,2))  --"刻度上升/刻度下降"
		end
		local ct=1
		if sel==1 then
			ct=-1
		end
		-- 创建一个改变左刻度的效果并注册到目标卡上
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_LSCALE)
		e1:SetValue(ct)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_UPDATE_RSCALE)
		tc:RegisterEffect(e2)
		tc=tg:GetNext()
	end
end
-- 定义用于筛选灵摆怪兽的过滤函数
function c34884015.cfilter(c,tp)
	return c:IsFaceup() and c:IsType(TYPE_PENDULUM) and c:IsControler(tp) and c:IsSummonType(SUMMON_TYPE_PENDULUM)
end
-- 当有灵摆怪兽被特殊召唤成功时，为该卡添加一个指示物
function c34884015.counterop(e,tp,eg,ep,ev,re,r,rp)
	if eg:IsExists(c34884015.cfilter,1,nil,tp) then
		e:GetHandler():AddCounter(0x4e,1)
	end
end
-- 计算场上灵摆怪兽的攻击力提升值
function c34884015.atkval(e,c)
	return e:GetHandler():GetCounter(0x4e)*300
end
-- 检查是否可以移除3个指示物作为发动cost
function c34884015.expcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsCanRemoveCounter(tp,0x4e,3,REASON_COST) end
	e:GetHandler():RemoveCounter(tp,0x4e,3,REASON_COST)
end
-- 检查是否已经发动过此效果
function c34884015.exptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断是否已经发动过此效果
	if chk==0 then return Duel.GetFlagEffect(tp,34884015)==0 end
end
-- 注册额外灵摆召唤效果，使玩家在本回合可以额外进行一次灵摆召唤
function c34884015.expop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 注册额外灵摆召唤效果，使玩家在本回合可以额外进行一次灵摆召唤
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(34884015,4))  --"使用「魂之灵摆」的效果灵摆召唤"
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_EXTRA_PENDULUM_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetCountLimit(1,29432356)
	-- 设置效果值为始终成立，表示可以进行灵摆召唤
	e1:SetValue(aux.TRUE)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将效果注册到对应玩家的全局环境中
	Duel.RegisterEffect(e1,tp)
	-- 为玩家注册一个标识效果，防止此效果重复发动
	Duel.RegisterFlagEffect(tp,34884015,RESET_PHASE+PHASE_END,0,1)
end
