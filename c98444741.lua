--積み上げる幸福
-- 效果：
-- 连锁4以后才能发动。从自己卡组抽2张卡。同1组连锁上有复数次同名卡的效果发动的场合，这张卡不能发动。
function c98444741.initial_effect(c)
	-- 连锁4以后才能发动。从自己卡组抽2张卡。同1组连锁上有复数次同名卡的效果发动的场合，这张卡不能发动。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCondition(c98444741.condition)
	e1:SetTarget(c98444741.target)
	e1:SetOperation(c98444741.activate)
	c:RegisterEffect(e1)
end
-- 定义效果的发动条件
function c98444741.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 判定当前连锁数大于2（即此卡发动时为连锁4以上）且当前连锁中没有同名卡的效果发动
	return Duel.GetCurrentChain()>2 and Duel.CheckChainUniqueness()
end
-- 定义效果的发动准备（检查可行性并设置目标与操作信息）
function c98444741.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动阶段，检查自己是否可以从卡组抽2张卡
	if chk==0 then return Duel.IsPlayerCanDraw(tp,2) end
	-- 设置当前效果的对象玩家为自己
	Duel.SetTargetPlayer(tp)
	-- 设置当前效果的对象参数（抽卡数量）为2
	Duel.SetTargetParam(2)
	-- 设置当前连锁的操作信息为“玩家抽2张卡”
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,2)
end
-- 定义效果的处理逻辑
function c98444741.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁设定的对象玩家和参数（抽卡数量）
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 让目标玩家因效果抽指定数量的卡
	Duel.Draw(p,d,REASON_EFFECT)
end
