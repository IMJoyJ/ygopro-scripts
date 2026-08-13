--アイアンドロー
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：自己场上的怪兽只有机械族效果怪兽2只的场合才能发动。自己从卡组抽2张。这张卡的发动后，直到回合结束时自己只能有1次把怪兽特殊召唤。
function c34559295.initial_effect(c)
	-- 启用特殊召唤次数限制的全局标记（GLOBALFLAG_SPSUMMON_COUNT），使后续本卡设置的“只能有1次把怪兽特殊召唤”限制效果能够正常处理。
	Duel.EnableGlobalFlag(GLOBALFLAG_SPSUMMON_COUNT)
	-- 这个卡名的卡在1回合只能发动1张。①：自己场上的怪兽只有机械族效果怪兽2只的场合才能发动。自己从卡组抽2张。这张卡的发动后，直到回合结束时自己只能有1次把怪兽特殊召唤。
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
-- 定义过滤函数filter：筛选满足表侧表示、效果怪兽、机械族这三个条件的怪兽，用于检查自己场上是否有且只有2只符合条件的怪兽。
function c34559295.filter(c)
	return c:IsFaceup() and c:IsType(TYPE_EFFECT) and c:IsRace(RACE_MACHINE)
end
-- 判定发动条件：自己场上的怪兽（所有怪兽区）必须恰好为2只，且这2只都满足c34559295.filter（即都是表侧表示的机械族效果怪兽）。
function c34559295.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 获取自己场上所有怪兽区中的怪兽集合g（无过滤条件），用于统计自己场上的怪兽数量。
	local g=Duel.GetMatchingGroup(nil,tp,LOCATION_MZONE,0,nil)
	return g:GetCount()==2 and g:FilterCount(c34559295.filter,nil)==2
end
-- 效果发动时的目标处理函数target：检查自己能否抽2张卡，并将抽卡对象玩家设为自己、抽卡参数设为2，同时声明操作信息为抽卡（CATEGORY_DRAW）。
function c34559295.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动时（chk==0）检查自己是否能够抽2张卡（例如不受不能抽卡等限制），若不能则无法发动。
	if chk==0 then return Duel.IsPlayerCanDraw(tp,2) end
	-- 将当前连锁的效果对象玩家设置为自己（tp），表示抽卡操作的执行者是自己。
	Duel.SetTargetPlayer(tp)
	-- 将当前连锁的效果参数设置为2，表示需要抽2张卡。
	Duel.SetTargetParam(2)
	-- 设置操作信息：声明这是一个抽卡效果，目标玩家为tp，抽卡数量为2（因为不取对象，targets传nil）。
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,2)
end
-- 效果处理函数activate：先获取并执行抽2张卡；若本效果以魔法发动形式成功发动，再给自己附加一个直到回合结束的“特殊召唤次数限制为1次”的效果。
function c34559295.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 从当前连锁信息中取出之前设定的对象玩家p和参数d（即抽卡玩家和抽卡张数）。
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 以效果原因让玩家p抽d张卡，实际执行“自己从卡组抽2张”。
	Duel.Draw(p,d,REASON_EFFECT)
	if not e:IsHasType(EFFECT_TYPE_ACTIVATE) then return end
	-- 这张卡的发动后，直到回合结束时自己只能有1次把怪兽特殊召唤。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_COUNT_LIMIT)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetValue(1)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将新创建的特殊召唤次数限制效果注册到玩家tp（自己）身上，使“直到回合结束时只能有1次把怪兽特殊召唤”正式生效。
	Duel.RegisterEffect(e1,tp)
end
