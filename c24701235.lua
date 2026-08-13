--和魂
-- 效果：
-- 这张卡不能特殊召唤。
-- ①：这张卡召唤·反转的回合，自己在通常召唤外加上只有1次，自己主要阶段可以把1只灵魂怪兽召唤。
-- ②：这张卡召唤·反转的回合的结束阶段发动。这张卡回到持有者手卡。
-- ③：这张卡被送去墓地的场合发动。自己从卡组抽1张。这个效果在自己场上有灵魂怪兽存在的场合进行发动和处理。
function c24701235.initial_effect(c)
	-- 为该卡注册灵魂怪兽的结束阶段回手效果：在召唤或反转成功的回合的结束阶段，这张卡回到持有者手卡。
	aux.EnableSpiritReturn(c,EVENT_SUMMON_SUCCESS,EVENT_FLIP)
	-- 这张卡不能特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	c:RegisterEffect(e1)
	-- ①：这张卡召唤·反转的回合，自己在通常召唤外加上只有1次，自己主要阶段可以把1只灵魂怪兽召唤。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e4:SetCode(EVENT_SUMMON_SUCCESS)
	e4:SetOperation(c24701235.sumop)
	c:RegisterEffect(e4)
	local e5=e4:Clone()
	e5:SetCode(EVENT_FLIP)
	c:RegisterEffect(e5)
	-- ③：这张卡被送去墓地的场合发动。自己从卡组抽1张。这个效果在自己场上有灵魂怪兽存在的场合进行发动和处理。
	local e6=Effect.CreateEffect(c)
	e6:SetDescription(aux.Stringid(24701235,1))  --"抽卡"
	e6:SetCategory(CATEGORY_DRAW)
	e6:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e6:SetCode(EVENT_TO_GRAVE)
	e6:SetProperty(EFFECT_FLAG_ACTIVATE_CONDITION)
	e6:SetCondition(c24701235.condition)
	e6:SetTarget(c24701235.target)
	e6:SetOperation(c24701235.operation)
	c:RegisterEffect(e6)
end
-- 处理①的额外召唤效果：这张卡召唤·反转成功时，若本回合尚未使用过和魂的额外召唤效果，则为控制者赋予一次额外的通常召唤权，且只能用于召唤灵魂怪兽，并在结束阶段重置。
function c24701235.sumop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查控制者是否已经使用过和魂的额外召唤效果；若已使用则跳过，保证一回合最多额外召唤一次灵魂怪兽。
	if Duel.GetFlagEffect(tp,24701235)~=0 then return end
	-- ①：这张卡召唤·反转的回合，自己在通常召唤外加上只有1次，自己主要阶段可以把1只灵魂怪兽召唤。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetDescription(aux.Stringid(24701235,0))  --"使用「和魂」的效果召唤"
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetTargetRange(LOCATION_HAND+LOCATION_MZONE,0)
	e1:SetCode(EFFECT_EXTRA_SUMMON_COUNT)
	-- 将额外通常召唤的使用对象限制为灵魂怪兽，即只能通过此效果召唤灵魂怪兽。
	e1:SetTarget(aux.TargetBoolFunction(Card.IsType,TYPE_SPIRIT))
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将上述额外召唤效果注册给控制者tp，使其本回合获得额外的通常召唤次数。
	Duel.RegisterEffect(e1,tp)
	-- 给控制者tp打上已使用和魂效果的标记，该标记在结束阶段重置，用于限制一回合一次。
	Duel.RegisterFlagEffect(tp,24701235,RESET_PHASE+PHASE_END,0,1)
end
-- 定义过滤函数：筛选表侧表示的灵魂怪兽，供③的发动条件和处理时检查。
function c24701235.cfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_SPIRIT)
end
-- ③的发动条件：自己场上有表侧表示的灵魂怪兽存在时，该诱发效果才满足发动条件。
function c24701235.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 判断自己场上是否存在至少1只表侧表示的灵魂怪兽。
	return Duel.IsExistingMatchingCard(c24701235.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
-- ③发动时的目标登记：确认可发动后，将抽卡玩家设为自身，抽卡数设为1，并向系统登记抽卡操作。
function c24701235.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 将本次连锁的对象玩家设为tp，表示由tp进行抽卡。
	Duel.SetTargetPlayer(tp)
	-- 将本次连锁的对象参数设为1，表示抽卡张数为1。
	Duel.SetTargetParam(1)
	-- 向系统登记本次效果将执行抽卡操作：抽卡玩家为tp，预定抽1张，供其他卡效果检测。
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
-- ③的效果处理：若自己场上仍有表侧表示灵魂怪兽，则让tp从卡组抽1张。
function c24701235.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 处理时再次确认自己场上存在表侧表示的灵魂怪兽；若不存在则中止抽卡处理。
	if not Duel.IsExistingMatchingCard(c24701235.cfilter,tp,LOCATION_MZONE,0,1,nil) then return end
	-- 获取当前连锁信息中登记的对象玩家和参数，即抽卡玩家和抽卡数量。
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 执行抽卡：让玩家p以效果原因抽d张卡（即抽1张）。
	Duel.Draw(p,d,REASON_EFFECT)
end
