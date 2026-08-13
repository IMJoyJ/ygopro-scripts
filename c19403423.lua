--時を裂く魔瞳
-- 效果：
-- ①：这次决斗中，以下效果各适用。
-- ●自己不能把手卡的怪兽的效果发动。
-- ●自己抽卡阶段的通常抽卡变成2张。
-- ●自己1回合可以进行通常召唤最多2次。
-- ②：把墓地的这张卡除外，从手卡丢弃1张「撕裂时间的魔瞳」才能发动。这个回合，在自己怪兽的召唤成功时对方不能把怪兽的效果发动。
function c19403423.initial_effect(c)
	-- ①：这次决斗中，以下效果各适用。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(19403423,0))  --"适用效果"
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c19403423.target)
	e1:SetOperation(c19403423.activate)
	e1:SetLabel(19403423)
	c:RegisterEffect(e1)
	-- ②：把墓地的这张卡除外，从手卡丢弃1张「撕裂时间的魔瞳」才能发动。这个回合，在自己怪兽的召唤成功时对方不能把怪兽的效果发动。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(19403423,1))  --"把墓地的这张卡除外"
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCost(c19403423.cost)
	e2:SetTarget(c19403423.target)
	e2:SetOperation(c19403423.operation)
	e2:SetLabel(19403424)
	c:RegisterEffect(e2)
end
-- 发动合法性检查：确认当前玩家没有已适用的①效果标识（flag 19403423），若已适用则不能发动，防止重复发动①效果。
function c19403423.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local ct=e:GetLabel()
	-- 检查当前玩家的19403423号flag数量为0，即①效果尚未适用过，作为本次发动的条件。
	if chk==0 then return Duel.GetFlagEffect(tp,ct)==0 end
end
-- ①效果处理：依次给当前玩家注册三个永续效果——禁止手卡怪兽效果发动、抽卡阶段抽卡数变为2、通常召唤次数上限变为2，并设置flag标记，使这些效果在本次决斗中持续适用。
function c19403423.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- ●自己不能把手卡的怪兽的效果发动。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(19403423,2))  --"「撕裂时间的魔瞳」效果适用中"
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CLIENT_HINT)
	e1:SetCode(EFFECT_CANNOT_ACTIVATE)
	e1:SetTargetRange(1,0)
	e1:SetValue(c19403423.aclimit)
	-- 将“不能把手卡的怪兽效果发动”的永续效果注册给当前玩家，使其适用。
	Duel.RegisterEffect(e1,tp)
	-- ●自己抽卡阶段的通常抽卡变成2张。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetCode(EFFECT_DRAW_COUNT)
	e2:SetTargetRange(1,0)
	e2:SetValue(2)
	-- 将“抽卡阶段抽卡数变为2”的永续效果注册给当前玩家，使其适用。
	Duel.RegisterEffect(e2,tp)
	-- ●自己1回合可以进行通常召唤最多2次。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_SET_SUMMON_COUNT_LIMIT)
	e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e3:SetTargetRange(1,0)
	e3:SetValue(2)
	-- 将“通常召唤次数上限变为2”的永续效果注册给当前玩家，使其适用。
	Duel.RegisterEffect(e3,tp)
	-- 给当前玩家注册标识为19403423的flag，标记①效果已适用，之后不能再发动①。
	Duel.RegisterFlagEffect(tp,19403423,0,0,1)
end
-- 判断一个效果是否为“手卡的怪兽效果”：效果发动区域为手牌，且效果类型属于怪兽效果。
function c19403423.aclimit(e,re,tp)
	return re:GetActivateLocation()==LOCATION_HAND and re:IsActiveType(TYPE_MONSTER)
end
-- 筛选手卡中的卡：卡名是19403423（「撕裂时间的魔瞳」）且可以被丢弃，用于②的cost。
function c19403423.filter(c)
	return c:IsCode(19403423) and c:IsDiscardable()
end
-- ②cost合法性检测：墓地中的这张卡可以作为cost除外，并且手卡中存在满足filter的「撕裂时间的魔瞳」可丢弃。
function c19403423.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsAbleToRemoveAsCost()
		-- 检查手卡中是否存在至少1张卡名是「撕裂时间的魔瞳」且能丢弃的卡。
		and Duel.IsExistingMatchingCard(c19403423.filter,tp,LOCATION_HAND,0,1,nil) end
	-- 将墓地中的这张卡以表侧表示除外，作为发动②的cost。
	Duel.Remove(c,POS_FACEUP,REASON_COST)
	-- 从手卡丢弃1张满足filter的「撕裂时间的魔瞳」作为cost，丢弃原因同时包含cost和丢弃。
	Duel.DiscardHand(tp,c19403423.filter,1,1,REASON_COST+REASON_DISCARD,nil)
end
-- ②效果处理：注册一个监听自己怪兽召唤成功的持续效果，在召唤成功时设置连锁限制，使对方本回合不能发动怪兽效果；同时注册flag标记。
function c19403423.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 这个回合，在自己怪兽的召唤成功时对方不能把怪兽的效果发动。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetCondition(c19403423.nsumcon)
	e1:SetOperation(c19403423.nsumsuc)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将“自己怪兽召唤成功时”的持续效果注册到当前玩家场上，使其监听后续的召唤成功事件。
	Duel.RegisterEffect(e1,tp)
	-- 给当前玩家注册一个到结束阶段重置的flag（19403424），标记本回合②效果已适用。
	Duel.RegisterFlagEffect(tp,19403424,RESET_PHASE+PHASE_END,0,1)
end
-- 触发条件判断：本次召唤成功的怪兽存在且控制者是当前玩家，即“自己怪兽召唤成功”。
function c19403423.nsumcon(e,tp,eg,ep,ev,re,r,rp)
	local ec=eg:GetFirst()
	return ec and ec:IsControler(tp)
end
-- 触发处理：调用Duel.SetChainLimitTillChainEnd，传入efun作为连锁限制函数，从此刻起限制对方怪兽效果的发动。
function c19403423.nsumsuc(e,tp,eg,ep,ev,re,r,rp)
	-- 设置连锁限制直到连锁结束：所有后续效果发动时都要经过efun函数判定，失败则不能发动。
	Duel.SetChainLimitTillChainEnd(c19403423.efun)
end
-- 连锁限制判定：如果效果的发动者是对方且该效果是怪兽效果，则禁止发动；自己发动的效果或非怪兽效果不受限制。
function c19403423.efun(e,ep,tp)
	return ep==tp or not e:IsActiveType(TYPE_MONSTER)
end
