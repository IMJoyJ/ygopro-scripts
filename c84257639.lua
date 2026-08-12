--治療の神 ディアン・ケト
-- 效果：
-- ①：自己回复1000基本分。
function c84257639.initial_effect(c)
	-- ①：自己回复1000基本分。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCategory(CATEGORY_RECOVER)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c84257639.tg)
	e1:SetOperation(c84257639.op)
	c:RegisterEffect(e1)
end
-- 定义效果发动的Target（目标设置）函数
function c84257639.tg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置当前连锁的对象玩家为自己
	Duel.SetTargetPlayer(tp)
	-- 设置当前连锁的对象参数为1000
	Duel.SetTargetParam(1000)
	-- 设置当前连锁的操作信息为：使自己回复1000基本分
	Duel.SetOperationInfo(0,CATEGORY_RECOVER,nil,0,tp,1000)
end
-- 定义效果处理的Operation（效果执行）函数
function c84257639.op(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中设定的对象玩家和参数（回复数值）
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 使目标玩家回复对应的基本分
	Duel.Recover(p,d,REASON_EFFECT)
end
