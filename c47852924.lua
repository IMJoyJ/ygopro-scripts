--天使の生き血
-- 效果：
-- 自己回复800点的基本分。
function c47852924.initial_effect(c)
	-- 自己回复800点的基本分。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCategory(CATEGORY_RECOVER)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c47852924.tg)
	e1:SetOperation(c47852924.op)
	c:RegisterEffect(e1)
end
-- 设置效果目标玩家为自己，目标参数为800，操作信息设置为回复效果。
function c47852924.tg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 将当前连锁的目标玩家设置为发动玩家。
	Duel.SetTargetPlayer(tp)
	-- 将当前连锁的目标参数设置为800。
	Duel.SetTargetParam(800)
	-- 设置当前处理的连锁的操作信息为回复效果，目标玩家为发动玩家，回复值为800。
	Duel.SetOperationInfo(0,CATEGORY_RECOVER,nil,0,tp,800)
end
-- 效果处理函数，获取连锁的目标玩家和参数并执行回复效果。
function c47852924.op(e,tp,eg,ep,ev,re,r,rp)
	-- 从当前连锁中获取目标玩家和目标参数。
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 以效果原因使目标玩家回复对应参数的LP。
	Duel.Recover(p,d,REASON_EFFECT)
end
