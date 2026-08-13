--覆面忍者ヱビス
-- 效果：
-- 1回合1次，自己场上有「覆面忍者 惠比寿」以外的名字带有「忍者」的怪兽存在的场合才能发动。自己场上的名字带有「忍者」的怪兽数量的对方魔法·陷阱卡回到持有者手卡。这个效果适用的回合，自己场上的「忍者义贼 五卫五卫」可以直接攻击对方玩家。
function c22512406.initial_effect(c)
	-- 对应效果原文：“1回合1次，自己场上有「覆面忍者 惠比寿」以外的名字带有「忍者」的怪兽存在的场合才能发动。自己场上的名字带有「忍者」的怪兽数量的对方魔法·陷阱卡回到持有者手卡。”注册这个1回合1次的起动效果。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(22512406,0))  --"返回手牌"
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCondition(c22512406.thcon)
	e1:SetTarget(c22512406.thtg)
	e1:SetOperation(c22512406.thop)
	c:RegisterEffect(e1)
end
-- 过滤条件：卡片必须是表侧表示、拥有“忍者”字段，且卡名不是「覆面忍者 惠比寿」自身，用来判断自己场上是否存在其他表侧表示的忍者怪兽。
function c22512406.cfilter1(c)
	return c:IsFaceup() and c:IsSetCard(0x2b) and not c:IsCode(22512406)
end
-- 过滤条件：卡片必须是表侧表示且拥有“忍者”字段，用于统计自己场上的忍者怪兽数量。
function c22512406.cfilter2(c)
	return c:IsFaceup() and c:IsSetCard(0x2b)
end
-- 效果发动条件函数：自己场上存在至少1只满足cfilter1条件（即「覆面忍者 惠比寿」以外的表侧表示忍者怪兽）时才能发动。
function c22512406.thcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否存在至少1张满足cfilter1条件的表侧表示忍者怪兽（即「覆面忍者 惠比寿」以外的名字带有「忍者」的怪兽）。
	return Duel.IsExistingMatchingCard(c22512406.cfilter1,tp,LOCATION_MZONE,0,1,nil)
end
-- 过滤条件：选择对方场上满足条件的卡，即魔法·陷阱卡且能够加入手卡的卡。
function c22512406.filter(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsAbleToHand()
end
-- 效果发动时的目标选择与合法性判定函数：在发动时计算自己场上忍者怪兽的数量作为回手数量，并确认对方场上可回手的魔法·陷阱卡数量足够，同时设置操作信息。
function c22512406.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		-- 统计自己场上表侧表示且名字带有「忍者」的怪兽数量，这个数量就是本次效果要返回手牌的对方魔法·陷阱卡数量。
		local ct=Duel.GetMatchingGroupCount(c22512406.cfilter2,tp,LOCATION_MZONE,0,nil)
		-- 统计对方场上满足filter条件的魔法·陷阱卡数量，用于判断是否足够让效果处理。
		local dt=Duel.GetMatchingGroupCount(c22512406.filter,tp,0,LOCATION_ONFIELD,nil)
		e:SetLabel(ct)
		return dt>=ct
	end
	-- 获取对方场上所有满足filter条件的魔法·陷阱卡，作为可能返回手牌的对象组。
	local g=Duel.GetMatchingGroup(c22512406.filter,tp,0,LOCATION_ONFIELD,nil)
	-- 将操作信息设置为“回手牌”分类，对象为上述满足条件的魔法·陷阱卡组，数量为之前计算出的忍者怪兽数量，供后续效果的检测和连锁处理使用。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,e:GetLabel(),0,0)
end
-- 效果处理函数：按处理时场上忍者怪兽的数量选择对方场上的魔法·陷阱卡返回手牌，并在本回合内给「忍者义贼 五卫五卫」附加直接攻击能力。
function c22512406.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 效果处理时重新统计自己场上表侧表示且名字带有「忍者」的怪兽数量，以处理时的实际数量为准。
	local ct=Duel.GetMatchingGroupCount(c22512406.cfilter2,tp,LOCATION_MZONE,0,nil)
	-- 效果处理时重新获取对方场上所有可返回手牌的魔法·陷阱卡组。
	local g=Duel.GetMatchingGroup(c22512406.filter,tp,0,LOCATION_ONFIELD,nil)
	if ct>g:GetCount() then return end
	-- 向发动玩家显示选择提示，要求其选择要返回手牌的对方卡片。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)  --"请选择要返回手牌的卡"
	local sg=g:Select(tp,ct,ct,nil)
	-- 将选中的对方场上的卡片返回持有者手牌，返回原因是效果。
	Duel.SendtoHand(sg,nil,REASON_EFFECT)
	-- 对应效果原文：“这个效果适用的回合，自己场上的「忍者义贼 五卫五卫」可以直接攻击对方玩家。”创建该回合内生效的直接攻击效果。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_DIRECT_ATTACK)
	e1:SetTargetRange(LOCATION_MZONE,0)
	-- 设置直接攻击效果的目标：只有卡名为「忍者义贼 五卫五卫」的怪兽才能适用此效果。
	e1:SetTarget(aux.TargetBoolFunction(Card.IsCode,10236520))
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将直接攻击效果注册到当前回合的场上，使其持续到结束阶段，让己方场上的「忍者义贼 五卫五卫」本回合获得直接攻击能力。
	Duel.RegisterEffect(e1,tp)
end
