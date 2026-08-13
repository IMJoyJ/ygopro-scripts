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
-- 效果发动时的目标处理函数：判定发动条件允许，并记录回复对象为当前玩家、回复数值为800，同时设定效果处理时将进行回复800LP的操作信息。
function c47852924.tg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置当前连锁的对象玩家为发动者tp，即回复基本分的对象。
	Duel.SetTargetPlayer(tp)
	-- 设置当前连锁的对象参数为800，即回复基本分的数值。
	Duel.SetTargetParam(800)
	-- 设置效果处理的操作信息：本连锁包含回复基本分效果，回复对象玩家为tp，回复数值为800。
	Duel.SetOperationInfo(0,CATEGORY_RECOVER,nil,0,tp,800)
end
-- 效果处理时的操作函数：从连锁信息中取出之前记录的对象玩家和回复数值，并实际执行基本分回复。
function c47852924.op(e,tp,eg,ep,ev,re,r,rp)
	-- 从当前连锁信息中取得对象玩家p和对象参数d，即回复对象和回复数值。
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 使玩家p回复d点基本分，回复原因记为效果（REASON_EFFECT）。
	Duel.Recover(p,d,REASON_EFFECT)
end
