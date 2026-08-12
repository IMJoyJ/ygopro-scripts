--凡骨の意地
-- 效果：
-- 当抽卡阶段抽到的卡是通常怪兽的场合，向对方展示抽到的卡，就可以再抽1张卡。
function c35762283.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- 创建诱发选发效果，用于在抽卡阶段触发
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(35762283,0))  --"抽卡"
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetRange(LOCATION_SZONE)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_DRAW)
	e2:SetCondition(c35762283.drcon)
	e2:SetCost(c35762283.drcost)
	e2:SetTarget(c35762283.drtg)
	e2:SetOperation(c35762283.drop)
	c:RegisterEffect(e2)
end
-- 效果条件判断函数，检查是否为抽卡阶段且为当前玩家抽卡
function c35762283.drcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前回合玩家是否为效果发动者且当前阶段为抽卡阶段
	return Duel.GetTurnPlayer()==tp and Duel.GetCurrentPhase()==PHASE_DRAW
end
-- 过滤函数，用于筛选未公开的通常怪兽
function c35762283.filter(c)
	return c:IsType(TYPE_NORMAL) and not c:IsPublic()
end
-- 效果发动时的费用处理函数，确认对方看到抽到的通常怪兽
function c35762283.drcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return ep==tp and eg:IsExists(c35762283.filter,1,nil) end
	local g=eg:Filter(c35762283.filter,nil)
	if g:GetCount()==1 then
		-- 向对方玩家展示指定手牌
		Duel.ConfirmCards(1-tp,g)
		-- 将当前玩家手牌洗切
		Duel.ShuffleHand(tp)
	else
		-- 提示玩家选择要确认的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)  --"请选择给对方确认的卡"
		local sg=g:Select(tp,1,1,nil)
		-- 向对方玩家展示指定手牌
		Duel.ConfirmCards(1-tp,sg)
		-- 将当前玩家手牌洗切
		Duel.ShuffleHand(tp)
	end
end
-- 效果的目标设定函数，设置抽卡目标
function c35762283.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查当前玩家是否可以再抽一张卡
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1) end
	-- 设置效果的目标玩家为当前玩家
	Duel.SetTargetPlayer(tp)
	-- 设置效果的目标参数为1（抽卡数量）
	Duel.SetTargetParam(1)
	-- 设置效果操作信息为抽卡效果
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
-- 效果的处理函数，执行抽卡操作
function c35762283.drop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取连锁中设定的目标玩家和抽卡数量
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 执行抽卡操作，抽卡原因设为效果
	Duel.Draw(p,d,REASON_EFFECT)
end
