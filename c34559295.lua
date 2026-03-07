--アイアンドロー
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：自己场上的怪兽只有机械族效果怪兽2只的场合才能发动。自己从卡组抽2张。这张卡的发动后，直到回合结束时自己只能有1次把怪兽特殊召唤。
function c34559295.initial_effect(c)
	-- 启用全局标记，用于记录特殊召唤次数限制
	Duel.EnableGlobalFlag(GLOBALFLAG_SPSUMMON_COUNT)
	-- ①：自己场上的怪兽只有机械族效果怪兽2只的场合才能发动。自己从卡组抽2张。这张卡的发动后，直到回合结束时自己只能有1次把怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,34559295)
	e1:SetCondition(c34559295.condition)
	e1:SetTarget(c34559295.target)
	e1:SetOperation(c34559295.activate)
	c:RegisterEffect(e1)
end
-- 过滤函数，用于判断是否为正面表示的机械族效果怪兽
function c34559295.filter(c)
	return c:IsFaceup() and c:IsType(TYPE_EFFECT) and c:IsRace(RACE_MACHINE)
end
-- 条件函数，判断场上是否只有2只机械族效果怪兽
function c34559295.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 获取玩家场上所有怪兽的卡片组
	local g=Duel.GetMatchingGroup(nil,tp,LOCATION_MZONE,0,nil)
	return g:GetCount()==2 and g:FilterCount(c34559295.filter,nil)==2
end
-- 目标函数，检查玩家是否可以抽2张卡并设置抽卡效果信息
function c34559295.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否可以抽2张卡
	if chk==0 then return Duel.IsPlayerCanDraw(tp,2) end
	-- 设置连锁效果的目标玩家为当前玩家
	Duel.SetTargetPlayer(tp)
	-- 设置连锁效果的目标参数为2（抽卡数量）
	Duel.SetTargetParam(2)
	-- 设置连锁效果的操作信息为抽卡效果，目标玩家为当前玩家，抽卡数量为2
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,2)
end
-- 发动函数，执行抽卡并设置后续只能特殊召唤1次的限制
function c34559295.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取连锁效果的目标玩家和目标参数（抽卡数量）
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 执行抽卡效果，从卡组抽指定数量的卡
	Duel.Draw(p,d,REASON_EFFECT)
	if not e:IsHasType(EFFECT_TYPE_ACTIVATE) then return end
	-- 发动后，直到回合结束时自己只能有1次把怪兽特殊召唤。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_COUNT_LIMIT)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetValue(1)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将效果注册到全局环境，使该效果生效
	Duel.RegisterEffect(e1,tp)
end
