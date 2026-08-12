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
-- 效果处理时点设置，用于确定连锁处理的目标玩家和参数
function c20871001.rectg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 将当前连锁的目标玩家设置为发动玩家
	Duel.SetTargetPlayer(tp)
	-- 将当前连锁的目标参数设置为400
	Duel.SetTargetParam(400)
	-- 设置连锁操作信息为回复效果，目标玩家为发动玩家，回复值为400
	Duel.SetOperationInfo(0,CATEGORY_RECOVER,nil,0,tp,400)
end
-- 效果处理函数，用于执行回复基本分的操作
function c20871001.recop(e,tp,eg,ep,ev,re,r,rp)
	-- 从当前连锁信息中获取目标玩家和目标参数
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 使目标玩家回复指定数值的基本分，原因设为效果
	Duel.Recover(p,d,REASON_EFFECT)
end
