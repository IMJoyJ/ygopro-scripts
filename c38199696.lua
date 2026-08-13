--レッド・ポーション
-- 效果：
-- 自己的基本分回复500。
function c38199696.initial_effect(c)
	-- 自己的基本分回复500。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCategory(CATEGORY_RECOVER)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c38199696.rectg)
	e1:SetOperation(c38199696.recop)
	c:RegisterEffect(e1)
end
-- 效果发动时的目标设定函数：在发动时检查条件（无特殊要求），并将发动者设为回复对象、回复数值设为500，同时将回复效果的操作信息登记到连锁中。
function c38199696.rectg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 将当前连锁的对象玩家设置为发动玩家tp，即把回复对象指定为效果发动者。
	Duel.SetTargetPlayer(tp)
	-- 将当前连锁的对象参数设置为500，表示要回复的基本分数值。
	Duel.SetTargetParam(500)
	-- 登记本次操作信息：类别为回复效果（CATEGORY_RECOVER），目标玩家为tp，回复数值为500，用于后续时点与连锁的检测。
	Duel.SetOperationInfo(0,CATEGORY_RECOVER,nil,0,tp,500)
end
-- 效果处理时的操作函数：从当前连锁信息中取出之前设置的对象玩家和回复数值，然后执行基本分回复。
function c38199696.recop(e,tp,eg,ep,ev,re,r,rp)
	-- 从当前连锁信息中获取对象玩家和对象参数，分别赋给p和d，以便下一步进行回复处理。
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 以效果原因（REASON_EFFECT）让玩家p回复d点基本分。
	Duel.Recover(p,d,REASON_EFFECT)
end
