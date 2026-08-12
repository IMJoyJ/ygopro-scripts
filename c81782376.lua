--運命の発掘
-- 效果：
-- ①：自己受到战斗伤害时才能发动。自己从卡组抽1张。
-- ②：场上的这张卡被对方的效果破坏的场合才能发动。自己从卡组抽出自己墓地的「命运之发掘」的数量。
function c81782376.initial_effect(c)
	-- ①：自己受到战斗伤害时才能发动。自己从卡组抽1张。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_BATTLE_DAMAGE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCondition(c81782376.condition)
	e1:SetTarget(c81782376.target)
	e1:SetOperation(c81782376.activate)
	c:RegisterEffect(e1)
	-- ②：场上的这张卡被对方的效果破坏的场合才能发动。自己从卡组抽出自己墓地的「命运之发掘」的数量。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_DRAW)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_DESTROYED)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_DELAY)
	e2:SetCondition(c81782376.drcon)
	e2:SetTarget(c81782376.drtg)
	e2:SetOperation(c81782376.drop)
	c:RegisterEffect(e2)
end
-- 检查受到战斗伤害的玩家是否为自己
function c81782376.condition(e,tp,eg,ep,ev,re,r,rp)
	return ep==tp
end
-- 效果①的发动准备，确认自己是否可以抽卡，并设置抽卡玩家、抽卡数量以及抽卡操作信息
function c81782376.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己当前是否可以从卡组抽1张卡
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1) end
	-- 将当前连锁的对象玩家设置为自己
	Duel.SetTargetPlayer(tp)
	-- 将当前连锁的对象参数（抽卡数量）设置为1
	Duel.SetTargetParam(1)
	-- 设置当前连锁的操作信息为：自己从卡组抽1张卡
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
-- 效果①的效果处理，获取目标玩家和抽卡数量，并执行抽卡
function c81782376.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中设定的目标玩家和目标参数（抽卡数量）
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 让目标玩家因效果抽指定数量的卡
	Duel.Draw(p,d,REASON_EFFECT)
end
-- 检查这张卡是否在自己场上被对方的效果破坏
function c81782376.drcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return rp==1-tp and c:IsReason(REASON_EFFECT)
		and c:IsPreviousControler(tp) and c:IsPreviousLocation(LOCATION_ONFIELD)
end
-- 效果②的发动准备，计算自己墓地「命运之发掘」的数量，确认是否可以抽对应数量的卡，并设置目标玩家、抽卡数量及操作信息
function c81782376.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 计算自己墓地中卡名为「命运之发掘」的卡片数量
	local ct=Duel.GetMatchingGroupCount(Card.IsCode,tp,LOCATION_GRAVE,0,nil,81782376)
	-- 检查自己墓地中是否存在「命运之发掘」，且自己当前是否可以抽对应数量的卡
	if chk==0 then return ct>0 and Duel.IsPlayerCanDraw(tp,ct) end
	-- 将当前连锁的对象玩家设置为自己
	Duel.SetTargetPlayer(tp)
	-- 将当前连锁的对象参数（抽卡数量）设置为自己墓地中「命运之发掘」的数量
	Duel.SetTargetParam(ct)
	-- 设置当前连锁的操作信息为：自己从卡组抽对应数量的卡
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,ct)
end
-- 效果②的效果处理，获取目标玩家，重新计算其墓地中「命运之发掘」的数量，并执行抽卡
function c81782376.drop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中设定的目标玩家
	local p=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER)
	-- 重新计算目标玩家墓地中卡名为「命运之发掘」的卡片数量
	local ct=Duel.GetMatchingGroupCount(Card.IsCode,p,LOCATION_GRAVE,0,nil,81782376)
	-- 让目标玩家因效果抽对应数量的卡
	Duel.Draw(p,ct,REASON_EFFECT)
end
