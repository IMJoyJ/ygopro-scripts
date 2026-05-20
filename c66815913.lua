--霊魂鳥－巫鶴
-- 效果：
-- 这张卡不能特殊召唤。
-- ①：1回合1次，这张卡在怪兽区域存在，这张卡以外的灵魂怪兽召唤·特殊召唤成功的场合才能发动。自己从卡组抽1张。
-- ②：这张卡召唤·反转的回合的结束阶段发动。这张卡回到持有者手卡。
function c66815913.initial_effect(c)
	-- 为卡片添加在召唤·反转的回合的结束阶段回到持有者手卡的效果。
	aux.EnableSpiritReturn(c,EVENT_SUMMON_SUCCESS,EVENT_FLIP)
	-- 这张卡不能特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	-- 设置特殊召唤的限制条件为不可特殊召唤。
	e1:SetValue(aux.FALSE)
	c:RegisterEffect(e1)
	-- ①：1回合1次，这张卡在怪兽区域存在，这张卡以外的灵魂怪兽召唤·特殊召唤成功的场合才能发动。自己从卡组抽1张。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(66815913,0))  --"抽卡"
	e2:SetCategory(CATEGORY_DRAW)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,EFFECT_COUNT_CODE_SINGLE)
	e2:SetCondition(c66815913.condition)
	e2:SetTarget(c66815913.target)
	e2:SetOperation(c66815913.operation)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EVENT_SUMMON_SUCCESS)
	c:RegisterEffect(e3)
end
-- 定义过滤函数：筛选表侧表示的灵魂怪兽。
function c66815913.cfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_SPIRIT)
end
-- 判断发动条件：召唤·特殊召唤成功的怪兽中不包含自身，且其中存在表侧表示的灵魂怪兽。
function c66815913.condition(e,tp,eg,ep,ev,re,r,rp)
	return not eg:IsContains(e:GetHandler()) and eg:IsExists(c66815913.cfilter,1,nil)
end
-- 定义效果发动时的目标选择函数：检查是否能抽卡，并设置抽卡玩家和数量。
function c66815913.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动阶段，检查玩家当前是否能够从卡组抽1张卡。
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1) end
	-- 将当前连锁的效果处理对象玩家设置为自己。
	Duel.SetTargetPlayer(tp)
	-- 将当前连锁的效果处理参数（抽卡数量）设置为1。
	Duel.SetTargetParam(1)
	-- 设置当前连锁的操作信息为：玩家抽1张卡。
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
-- 定义效果处理函数：获取目标玩家和抽卡数量并执行抽卡。
function c66815913.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中设定的目标玩家和抽卡数量参数。
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 执行抽卡操作，让目标玩家因效果抽指定数量的卡。
	Duel.Draw(p,d,REASON_EFFECT)
end
