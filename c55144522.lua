--強欲な壺
-- 效果：
-- ①：自己从卡组抽2张。
function c55144522.initial_effect(c)
	-- ①：自己从卡组抽2张。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c55144522.target)
	e1:SetOperation(c55144522.activate)
	c:RegisterEffect(e1)
end
-- 效果发动的目标检查与准备函数，用于确认是否满足发动条件并设置相关参数
function c55144522.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动阶段，检查当前玩家是否可以从卡组抽2张卡
	if chk==0 then return Duel.IsPlayerCanDraw(tp,2) end
	-- 设置当前连锁的目标玩家为当前玩家
	Duel.SetTargetPlayer(tp)
	-- 设置当前连锁的目标参数为2（抽卡张数）
	Duel.SetTargetParam(2)
	-- 设置当前连锁的操作信息为：玩家tp抽2张卡
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,2)
end
-- 效果处理的执行函数，获取目标玩家和抽卡数量并执行抽卡
function c55144522.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中设定的目标玩家和目标参数（抽卡张数）
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 让目标玩家因效果抽指定张数的卡
	Duel.Draw(p,d,REASON_EFFECT)
end
