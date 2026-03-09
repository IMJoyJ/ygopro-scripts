--強欲で金満な壺
-- 效果：
-- ①：自己主要阶段1开始时，把自己的额外卡组3张或6张里侧的卡随机里侧除外才能发动。除外的卡每有3张，自己抽1张。这张卡的发动后，直到回合结束时自己不能用卡的效果抽卡。
function c49238328.initial_effect(c)
	-- 效果原文内容：①：自己主要阶段1开始时，把自己的额外卡组3张或6张里侧的卡随机里侧除外才能发动。
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
-- 效果作用：判断是否处于主要阶段1开始时
function c49238328.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 效果作用：当前阶段为主要阶段1且未进行过阶段动作
	return Duel.GetCurrentPhase()==PHASE_MAIN1 and not Duel.CheckPhaseActivity()
end
-- 效果作用：设置标签用于后续判断
function c49238328.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	e:SetLabel(100)
	if chk==0 then return true end
end
-- 效果作用：过滤满足条件的额外卡组卡片（里侧表示且可作为费用除外）
function c49238328.cfilter(c)
	return c:IsFacedown() and c:IsAbleToRemoveAsCost(POS_FACEDOWN)
end
-- 效果作用：检索满足条件的额外卡组卡片，判断是否可以发动效果并选择除外3张或6张
function c49238328.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 效果作用：获取满足条件的额外卡组卡片组
	local g=Duel.GetMatchingGroup(c49238328.cfilter,tp,LOCATION_EXTRA,0,nil)
	if chk==0 then
		if e:GetLabel()~=100 then return false end
		e:SetLabel(0)
		-- 效果作用：判断玩家是否可以抽1张卡且额外卡组有至少3张符合条件的卡
		return Duel.IsPlayerCanDraw(tp,1) and #g>=3
	end
	local op=0
	-- 效果作用：判断玩家是否可以抽2张卡且额外卡组有至少6张符合条件的卡
	if Duel.IsPlayerCanDraw(tp,2) and #g>=6 then
		-- 效果作用：让玩家选择除外3张或6张卡发动
		op=Duel.SelectOption(tp,aux.Stringid(49238328,0),aux.Stringid(49238328,1))  --"除外3张卡发动/除外6张卡发动"
	else
		-- 效果作用：让玩家选择除外3张卡发动
		op=Duel.SelectOption(tp,aux.Stringid(49238328,0))  --"除外3张卡发动"
	end
	-- 效果作用：洗切玩家的额外卡组
	Duel.ShuffleExtra(tp)
	local rg=g:RandomSelect(tp,3+op*3)
	-- 效果作用：将选定的卡片以里侧形式除外作为发动代价
	Duel.Remove(rg,POS_FACEDOWN,REASON_COST)
	-- 效果作用：设置连锁的目标玩家为当前玩家
	Duel.SetTargetPlayer(tp)
	-- 效果作用：设置连锁的目标参数为抽卡数量
	Duel.SetTargetParam(op+1)
	-- 效果作用：设置操作信息为抽卡效果
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,op+1)
end
-- 效果作用：处理效果发动后的抽卡和不能抽卡限制
function c49238328.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 效果作用：获取连锁的目标玩家和目标参数
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 效果作用：让目标玩家以效果原因抽指定数量的卡
	Duel.Draw(p,d,REASON_EFFECT)
	if not e:IsHasType(EFFECT_TYPE_ACTIVATE) then return end
	-- 效果原文内容：这张卡的发动后，直到回合结束时自己不能用卡的效果抽卡。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_DRAW)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 效果作用：将不能抽卡效果注册给当前玩家
	Duel.RegisterEffect(e1,tp)
end
