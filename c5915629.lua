--強欲な贈り物
-- 效果：
-- 对方从卡组抽2张卡。
function c5915629.initial_effect(c)
	-- 对方从卡组抽2张卡。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c5915629.target)
	e1:SetOperation(c5915629.activate)
	c:RegisterEffect(e1)
end
-- 效果发动的目标确认与准备，设置对方为抽卡对象并指定抽2张卡
function c5915629.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查对方玩家是否可以从卡组抽2张卡
	if chk==0 then return Duel.IsPlayerCanDraw(1-tp,2) end
	-- 设置当前连锁的对象玩家为对方玩家
	Duel.SetTargetPlayer(1-tp)
	-- 设置当前连锁的对象参数为2
	Duel.SetTargetParam(2)
	-- 设置当前连锁的操作信息为：对方玩家抽2张卡
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,1-tp,2)
end
-- 效果处理，使目标玩家执行抽卡操作
function c5915629.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁设定的目标玩家和目标参数
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 让目标玩家因效果抽指定张数的卡
	Duel.Draw(p,d,REASON_EFFECT)
end
