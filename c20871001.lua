--ブルー・ポーション
-- 效果：
-- ①：自己回复400基本分。
function c20871001.initial_effect(c)
	-- ①：自己回复400基本分。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCategory(CATEGORY_RECOVER)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c20871001.rectg)
	e1:SetOperation(c20871001.recop)
	c:RegisterEffect(e1)
end
-- 效果发动的目标设定函数：在发动时确认可以发动，并将对象玩家设为自己，回复数值设为400，同时登记本次回复操作的信息。
function c20871001.rectg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 将当前连锁的对象玩家设置为效果发动者自己（tp），表示回复LP的对象是自己。
	Duel.SetTargetPlayer(tp)
	-- 将当前连锁的对象参数设置为400，表示回复的数值为400。
	Duel.SetTargetParam(400)
	-- 设置操作信息：本次效果属于回复基本分效果，预计回复玩家tp的400LP（不涉及卡片对象）。
	Duel.SetOperationInfo(0,CATEGORY_RECOVER,nil,0,tp,400)
end
-- 效果处理时的操作函数：从连锁信息中取出之前设定的目标玩家和回复数值，并实际执行回复LP。
function c20871001.recop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中记录的目标玩家和参数值，分别赋给局部变量p和d。
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 让玩家p回复d点LP，回复原因记为效果（REASON_EFFECT）。
	Duel.Recover(p,d,REASON_EFFECT)
end
