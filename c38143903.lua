--ヘッド・ジャッジング
-- 效果：
-- 这个卡名的①的效果1回合只能使用1次。
-- ①：自己或者对方把场上的怪兽的效果发动时才能发动。发动的那个玩家进行1次投掷硬币，对里表作猜测。猜中的场合，这张卡送去墓地。猜错的场合，那个发动无效，那只怪兽的控制权移给从那个玩家来看的对方。
function c38143903.initial_effect(c)
	-- ①：自己或者对方把场上的怪兽的效果发动时才能发动。
	local e0=Effect.CreateEffect(c)
	e0:SetDescription(aux.Stringid(38143903,0))  --"发动但不使用效果"
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetCode(EVENT_FREE_CHAIN)
	e0:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	-- 限制效果只能在伤害计算前的时机发动或适用。
	e0:SetCondition(aux.dscon)
	c:RegisterEffect(e0)
	-- ①：自己或者对方把场上的怪兽的效果发动时才能发动。发动的那个玩家进行1次投掷硬币，对里表作猜测。猜中的场合，这张卡送去墓地。猜错的场合，那个发动无效，那只怪兽的控制权移给从那个玩家来看的对方。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(38143903,1))  --"发动并使用效果"
	e1:SetCategory(CATEGORY_COIN+CATEGORY_NEGATE+CATEGORY_CONTROL+CATEGORY_TOGRAVE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_CHAINING)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e1:SetCountLimit(1,38143903)
	e1:SetCondition(c38143903.negcon)
	e1:SetTarget(c38143903.negtg)
	e1:SetOperation(c38143903.negop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetRange(LOCATION_SZONE)
	c:RegisterEffect(e2)
end
-- 判断连锁是否来自怪兽区域，且发动的是怪兽效果，且该连锁可以被无效。
function c38143903.negcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断连锁是否来自怪兽区域且发动的是怪兽效果。
	return Duel.GetChainInfo(ev,CHAININFO_TRIGGERING_LOCATION)==LOCATION_MZONE and re:IsActiveType(TYPE_MONSTER)
		-- 判断连锁是否可以被无效。
		and Duel.IsChainNegatable(ev)
end
-- 判断效果发动时是否满足条件，即此卡可送去墓地且目标怪兽可能改变控制权。
function c38143903.negtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToGrave()
		and (not re:GetHandler():IsRelateToEffect(re) or re:GetHandler():IsAbleToChangeControler()) end
	-- 设置操作信息：提示发动硬币效果。
	Duel.SetOperationInfo(0,CATEGORY_COIN,nil,0,ep,1)
	-- 设置操作信息：使发动无效。
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	-- 设置操作信息：将此卡送去墓地。
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,e:GetHandler(),1,0,0)
	if re:GetHandler():IsRelateToEffect(re) then
		-- 设置操作信息：改变目标怪兽的控制权。
		Duel.SetOperationInfo(0,CATEGORY_CONTROL,eg,1,0,0)
	end
end
-- 处理效果发动后的操作：投掷硬币并根据结果决定是否无效发动或改变控制权。
function c38143903.negop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取连锁的控制者。
	local p=Duel.GetChainInfo(ev,CHAININFO_TRIGGERING_CONTROLER)
	-- 提示控制者选择硬币正反面。
	Duel.Hint(HINT_SELECTMSG,p,HINTMSG_COIN)  --"请选择硬币的正反面"
	-- 让控制者宣言硬币正反面。
	local coin=Duel.AnnounceCoin(p)
	-- 控制者投掷一次硬币。
	local res=Duel.TossCoin(p,1)
	if coin==res then
		-- 如果成功使连锁无效且目标怪兽仍存在于场上，则改变其控制权。
		if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) then
			-- 将目标怪兽的控制权移给对方。
			Duel.GetControl(re:GetHandler(),1-p)
		end
	else
		-- 将此卡送去墓地。
		Duel.SendtoGrave(e:GetHandler(),REASON_EFFECT)
	end
end
