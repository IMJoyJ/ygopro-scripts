--チューニングガム
-- 效果：
-- 「调和口香糖」的①的效果1回合只能使用1次。
-- ①：以自己场上1只表侧表示怪兽为对象才能发动。这个回合，那只表侧表示怪兽当作调整使用。这个效果发动的回合，自己不用同调怪兽不能攻击。
-- ②：只以自己场上的同调怪兽1只为对象的魔法·陷阱·怪兽的效果发动时，把墓地的这张卡除外才能发动。那个发动无效。
function c82744076.initial_effect(c)
	-- 「调和口香糖」的①的效果1回合只能使用1次。①：以自己场上1只表侧表示怪兽为对象才能发动。这个回合，那只表侧表示怪兽当作调整使用。这个效果发动的回合，自己不用同调怪兽不能攻击。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(82744076,0))  --"当作调整使用"
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCountLimit(1,82744076)
	e1:SetCost(c82744076.cost)
	e1:SetTarget(c82744076.target)
	e1:SetOperation(c82744076.operation)
	c:RegisterEffect(e1)
	-- ②：只以自己场上的同调怪兽1只为对象的魔法·陷阱·怪兽的效果发动时，把墓地的这张卡除外才能发动。那个发动无效。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(82744076,1))  --"效果发动无效"
	e2:SetCategory(CATEGORY_NEGATE)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_CHAINING)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e2:SetCondition(c82744076.negcon)
	-- 把墓地的这张卡除外作为发动成本
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(c82744076.negtg)
	e2:SetOperation(c82744076.negop)
	c:RegisterEffect(e2)
	-- 注册一个自定义活动计数器，用于监测非同调怪兽的攻击宣言
	Duel.AddCustomActivityCounter(82744076,ACTIVITY_ATTACK,c82744076.counterfilter)
end
-- 过滤函数：判定卡片是否为同调怪兽（用于攻击计数器，非同调怪兽攻击时计数器增加）
function c82744076.counterfilter(c)
	return c:IsType(TYPE_SYNCHRO)
end
-- 效果①的Cost：检查本回合是否进行过非同调怪兽的攻击，并注册本回合自己不用同调怪兽不能攻击的限制
function c82744076.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查在发动效果前，本回合自己是否没有用非同调怪兽进行过攻击
	if chk==0 then return Duel.GetCustomActivityCount(82744076,tp,ACTIVITY_ATTACK)==0 end
	-- ①：以自己场上1只表侧表示怪兽为对象才能发动。这个回合，那只表侧表示怪兽当作调整使用。这个效果发动的回合，自己不用同调怪兽不能攻击。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_ATTACK)
	e1:SetProperty(EFFECT_FLAG_OATH+EFFECT_FLAG_IGNORE_IMMUNE)
	e1:SetTarget(c82744076.atklimit)
	e1:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 给玩家注册“不用同调怪兽不能攻击”的全局限制效果
	Duel.RegisterEffect(e1,tp)
end
-- 攻击限制过滤：非同调怪兽不能进行攻击
function c82744076.atklimit(e,c)
	return not c:IsType(TYPE_SYNCHRO)
end
-- 过滤条件：自己场上表侧表示且非调整的怪兽
function c82744076.filter(c)
	return c:IsFaceup() and not c:IsType(TYPE_TUNER)
end
-- 效果①的Target：选择自己场上1只表侧表示怪兽作为对象
function c82744076.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c82744076.filter(chkc) end
	-- 检查自己场上是否存在可以作为对象的表侧表示非调整怪兽
	if chk==0 then return Duel.IsExistingTarget(c82744076.filter,tp,LOCATION_MZONE,0,1,nil) end
	-- 提示玩家选择表侧表示的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择自己场上1只表侧表示非调整怪兽作为效果对象
	Duel.SelectTarget(tp,c82744076.filter,tp,LOCATION_MZONE,0,1,1,nil)
end
-- 效果①的Operation：使作为对象的怪兽在本回合当作调整怪兽使用
function c82744076.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取效果①选择的对象怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 这个回合，那只表侧表示怪兽当作调整使用。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetCode(EFFECT_ADD_TYPE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		e1:SetValue(TYPE_TUNER)
		tc:RegisterEffect(e1)
	end
end
-- 过滤条件：自己场上表侧表示的同调怪兽
function c82744076.cfilter(c,tp)
	return c:IsControler(tp) and c:IsLocation(LOCATION_MZONE) and c:IsFaceup() and c:IsType(TYPE_SYNCHRO)
end
-- 效果②的Condition：只以自己场上1只同调怪兽为对象的效果发动时
function c82744076.negcon(e,tp,eg,ep,ev,re,r,rp)
	if not re:IsHasProperty(EFFECT_FLAG_CARD_TARGET) then return false end
	-- 获取当前连锁中被作为效果对象的卡片组
	local g=Duel.GetChainInfo(ev,CHAININFO_TARGET_CARDS)
	if not g or g:GetCount()~=1 then return false end
	local tc=g:GetFirst()
	-- 确认该对象是自己场上的同调怪兽，且该效果的发动可以被无效
	return c82744076.cfilter(tc,tp) and Duel.IsChainNegatable(ev)
end
-- 效果②的Target：设置无效发动的操作信息
function c82744076.negtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置效果处理分类为“使发动无效”，目标为该连锁的发动
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
end
-- 效果②的Operation：使该效果的发动无效
function c82744076.negop(e,tp,eg,ep,ev,re,r,rp)
	-- 使当前连锁的发动无效
	Duel.NegateActivation(ev)
end
