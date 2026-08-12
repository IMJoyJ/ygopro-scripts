--強欲な瓶
-- 效果：
-- ①：自己从卡组抽1张。
function c83968380.initial_effect(c)
	-- ①：自己从卡组抽1张。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c83968380.target)
	e1:SetOperation(c83968380.activate)
	c:RegisterEffect(e1)
end
-- 效果发动时的目标选择与检查函数
function c83968380.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动准备阶段，检查自己是否满足抽1张卡的条件
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1) end
	-- 将当前连锁的对象玩家设置为自己
	Duel.SetTargetPlayer(tp)
	-- 将当前连锁的对象参数设置为1（即抽1张卡）
	Duel.SetTargetParam(1)
	-- 设置效果处理信息为：玩家自己从卡组抽1张卡
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
-- 效果发动后的实际处理函数
function c83968380.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中设定的对象玩家及抽卡张数
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 执行抽卡操作，让目标玩家因效果抽指定张数的卡
	Duel.Draw(p,d,REASON_EFFECT)
end
