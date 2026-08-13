--ヘッド・ジャッジング
-- 效果：
-- 这个卡名的①的效果1回合只能使用1次。
-- ①：自己或者对方把场上的怪兽的效果发动时才能发动。发动的那个玩家进行1次投掷硬币，对里表作猜测。猜中的场合，这张卡送去墓地。猜错的场合，那个发动无效，那只怪兽的控制权移给从那个玩家来看的对方。
function c38143903.initial_effect(c)
	-- 对应效果原文中的‘这个卡名的①的效果1回合只能使用1次。’；本段e0实现这张卡作为陷阱卡本身的发动/放置动作，不发动①效果，因此不占用该次数限制。
	local e0=Effect.CreateEffect(c)
	e0:SetDescription(aux.Stringid(38143903,0))  --"发动但不使用效果"
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetCode(EVENT_FREE_CHAIN)
	e0:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	-- 设置e0的发动条件为aux.dscon：只允许在非伤害步骤，或伤害计算前发动，避免在伤害步骤后发动。
	e0:SetCondition(aux.dscon)
	c:RegisterEffect(e0)
	-- 对应效果原文‘这个卡名的①的效果1回合只能使用1次。①：自己或者对方把场上的怪兽的效果发动时才能发动。发动的那个玩家进行1次投掷硬币，对里表作猜测。猜中的场合，这张卡送去墓地。猜错的场合，那个发动无效，那只怪兽的控制权移给从那个玩家来看的对方。’
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
-- 定义①效果的发动条件函数：确认当前连锁是被无效对象的场合，且满足后可发动本卡。
function c38143903.negcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查被连锁的效果是在怪兽区域发动的怪兽效果，即满足‘场上的怪兽的效果发动’这一发动条件。
	return Duel.GetChainInfo(ev,CHAININFO_TRIGGERING_LOCATION)==LOCATION_MZONE and re:IsActiveType(TYPE_MONSTER)
		-- 进一步确认该被连锁的效果的发动能够被无效，保证后续‘那个发动无效’的操作可以执行。
		and Duel.IsChainNegatable(ev)
end
-- 定义①效果的发动手续：自身可被送去墓地，且被连锁的怪兽效果（或其怪兽）能够进行控制权转移时，该效果才满足发动条件。
function c38143903.negtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToGrave()
		and (not re:GetHandler():IsRelateToEffect(re) or re:GetHandler():IsAbleToChangeControler()) end
	-- 设置操作信息：本次处理将进行1次硬币投掷，投掷玩家为发动被连锁效果的玩家（ep），分类为硬币效果。
	Duel.SetOperationInfo(0,CATEGORY_COIN,nil,0,ep,1)
	-- 设置操作信息：本次处理将无效eg中那1个效果发动，分类为无效发动。
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	-- 设置操作信息：猜中时这张卡将送去墓地，分类为送墓效果。
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,e:GetHandler(),1,0,0)
	if re:GetHandler():IsRelateToEffect(re) then
		-- 设置操作信息：猜错时被连锁的怪兽效果持有者将失去控制权，分类为控制权变更效果。
		Duel.SetOperationInfo(0,CATEGORY_CONTROL,eg,1,0,0)
	end
end
-- 定义①效果的实际处理流程：由发动被连锁效果的玩家猜硬币正反面并投掷硬币，按猜测结果决定是无效并夺控，还是使这张卡自身送墓。
function c38143903.negop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取被连锁效果的发动玩家（即‘发动的那个玩家’），作为后续猜硬币的玩家p。
	local p=Duel.GetChainInfo(ev,CHAININFO_TRIGGERING_CONTROLER)
	-- 向玩家p显示‘请选择硬币的正反面’的提示消息，准备进行猜测。
	Duel.Hint(HINT_SELECTMSG,p,HINTMSG_COIN)  --"请选择硬币的正反面"
	-- 让玩家p宣言1次硬币的正反面（0或1），保存为猜测结果coin。
	local coin=Duel.AnnounceCoin(p)
	-- 让玩家p实际投掷1次硬币，得到投掷结果res。
	local res=Duel.TossCoin(p,1)
	if coin==res then
		-- 如果成功无效了被连锁的效果，且该怪兽效果仍在原连锁中相关，则进入控制权转移的处理分支。
		if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) then
			-- 将被无效了效果的怪兽的控制权转移给玩家p的对方（即1-p），对应效果原文‘那只怪兽的控制权移给从那个玩家来看的对方’。
			Duel.GetControl(re:GetHandler(),1-p)
		end
	else
		-- 猜中时，将这张卡（头位审判）因效果送去墓地，对应效果原文‘猜中的场合，这张卡送去墓地’。
		Duel.SendtoGrave(e:GetHandler(),REASON_EFFECT)
	end
end
