--和魂
-- 效果：
-- 这张卡不能特殊召唤。
-- ①：这张卡召唤·反转的回合，自己在通常召唤外加上只有1次，自己主要阶段可以把1只灵魂怪兽召唤。
-- ②：这张卡召唤·反转的回合的结束阶段发动。这张卡回到持有者手卡。
-- ③：这张卡被送去墓地的场合发动。自己从卡组抽1张。这个效果在自己场上有灵魂怪兽存在的场合进行发动和处理。
function c24701235.initial_effect(c)
	-- 为卡片添加在召唤或反转时回到手卡的效果
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
-- 效果处理函数，用于在召唤或反转时增加一次灵魂怪兽的召唤次数
function c24701235.sumop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查是否已经使用过该效果，避免重复使用
	if Duel.GetFlagEffect(tp,24701235)~=0 then return end
	-- 创建并注册一个效果，使玩家在主要阶段可以额外召唤一次灵魂怪兽
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetDescription(aux.Stringid(24701235,0))  --"使用「和魂」的效果召唤"
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetTargetRange(LOCATION_HAND+LOCATION_MZONE,0)
	e1:SetCode(EFFECT_EXTRA_SUMMON_COUNT)
	-- 设置效果目标为灵魂怪兽
	e1:SetTarget(aux.TargetBoolFunction(Card.IsType,TYPE_SPIRIT))
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将效果注册到玩家环境中
	Duel.RegisterEffect(e1,tp)
	-- 为玩家注册一个标识效果，防止重复使用该效果
	Duel.RegisterFlagEffect(tp,24701235,RESET_PHASE+PHASE_END,0,1)
end
-- 过滤函数，用于检测场上是否存在灵魂怪兽
function c24701235.cfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_SPIRIT)
end
-- 条件函数，判断是否满足发动效果的条件
function c24701235.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检查场上是否存在至少一只灵魂怪兽
	return Duel.IsExistingMatchingCard(c24701235.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
-- 目标函数，设置抽卡效果的目标玩家和数量
function c24701235.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置连锁处理的目标玩家为当前玩家
	Duel.SetTargetPlayer(tp)
	-- 设置连锁处理的目标参数为1（抽卡数量）
	Duel.SetTargetParam(1)
	-- 设置操作信息为抽卡效果
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
-- 效果处理函数，执行抽卡操作
function c24701235.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 再次确认场上是否存在灵魂怪兽，若不存在则不执行抽卡
	if not Duel.IsExistingMatchingCard(c24701235.cfilter,tp,LOCATION_MZONE,0,1,nil) then return end
	-- 获取连锁处理的目标玩家和参数
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 执行抽卡操作，从卡组抽一张卡
	Duel.Draw(p,d,REASON_EFFECT)
end
