--強欲で金満な壺
-- 效果：
-- ①：自己主要阶段1开始时，把自己的额外卡组3张或6张里侧的卡随机里侧除外才能发动。除外的卡每有3张，自己抽1张。这张卡的发动后，直到回合结束时自己不能用卡的效果抽卡。
function c49238328.initial_effect(c)
	-- ①：自己主要阶段1开始时，把自己的额外卡组3张或6张里侧的卡随机里侧除外才能发动。除外的卡每有3张，自己抽1张。这张卡的发动后，直到回合结束时自己不能用卡的效果抽卡。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCondition(c49238328.condition)
	e1:SetCost(c49238328.cost)
	e1:SetTarget(c49238328.target)
	e1:SetOperation(c49238328.activate)
	c:RegisterEffect(e1)
end
-- 发动条件函数：限制这张卡只能在自己主要阶段1开始时（且本阶段尚未进行过任何操作的时点）发动。
function c49238328.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 判定当前阶段为主要阶段1，并且本阶段还没有进行过操作（即处于阶段开始时）。
	return Duel.GetCurrentPhase()==PHASE_MAIN1 and not Duel.CheckPhaseActivity()
end
-- 代价处理函数：先设置一个标记值100，在代价检查阶段仅返回true，实际除外代价延迟到target阶段选择和执行。
function c49238328.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	e:SetLabel(100)
	if chk==0 then return true end
end
-- 检索过滤函数：筛选额外卡组中里侧表示且可以作为里侧除外代价的卡片。
function c49238328.cfilter(c)
	return c:IsFacedown() and c:IsAbleToRemoveAsCost(POS_FACEDOWN)
end
-- 发动目标/代价处理函数：在发动时从额外卡组选择符合条件的里侧卡，若满足抽卡条件则让玩家选择除外3张或6张，随机里侧除外，并记录抽卡次数和对象。
function c49238328.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取己方额外卡组中所有里侧表示且可作为里侧除外代价的卡。
	local g=Duel.GetMatchingGroup(c49238328.cfilter,tp,LOCATION_EXTRA,0,nil)
	if chk==0 then
		if e:GetLabel()~=100 then return false end
		e:SetLabel(0)
		-- 合法性检查：自己至少能抽1张，且额外卡组中符合条件的里侧卡至少有3张。
		return Duel.IsPlayerCanDraw(tp,1) and #g>=3
	end
	local op=0
	-- 如果自己至少能抽2张且额外卡组里侧卡数量不少于6张，则允许玩家选择除外6张的路线。
	if Duel.IsPlayerCanDraw(tp,2) and #g>=6 then
		-- 让玩家选择“除外3张卡发动”还是“除外6张卡发动”，返回的选择序号存入op。
		op=Duel.SelectOption(tp,aux.Stringid(49238328,0),aux.Stringid(49238328,1))  --"除外3张卡发动/除外6张卡发动"
	else
		-- 当不满足除外6张的条件时，只让玩家选择“除外3张卡发动”，op固定为0。
		op=Duel.SelectOption(tp,aux.Stringid(49238328,0))  --"除外3张卡发动"
	end
	-- 洗切自己的额外卡组，以确保后续随机选择的随机性。
	Duel.ShuffleExtra(tp)
	local rg=g:RandomSelect(tp,3+op*3)
	-- 将随机选出的卡片以里侧表示除外，作为发动这张卡的代价。
	Duel.Remove(rg,POS_FACEDOWN,REASON_COST)
	-- 将当前连锁的对象玩家设为自己，用于记录之后抽卡的玩家。
	Duel.SetTargetPlayer(tp)
	-- 将当前连锁的对象参数设为op+1，即除外的卡组数（3张为1组，6张为2组），也就是之后抽卡的次数。
	Duel.SetTargetParam(op+1)
	-- 设置本次效果的操作信息：效果包含抽卡，预计由tp抽op+1张卡。
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,op+1)
end
-- 效果处理函数：根据连锁记录的目标玩家和抽卡次数执行抽卡，然后给自己附加直到回合结束不能抽卡的效果。
function c49238328.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 从当前连锁信息中取出目标玩家p（抽卡玩家）和目标参数d（抽卡次数）。
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 让玩家p以效果原因抽d张卡。
	Duel.Draw(p,d,REASON_EFFECT)
	if not e:IsHasType(EFFECT_TYPE_ACTIVATE) then return end
	-- 这张卡的发动后，直到回合结束时自己不能用卡的效果抽卡。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_DRAW)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将“不能抽卡”的永续效果注册到场上，适用于自己（tp），直到回合结束。
	Duel.RegisterEffect(e1,tp)
end
