--エンシェント・リーフ
-- 效果：
-- ①：自己基本分是9000以上的场合，支付2000基本分才能发动。自己从卡组抽2张。
function c11830996.initial_effect(c)
	-- ①：自己基本分是9000以上的场合，支付2000基本分才能发动。自己从卡组抽2张。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCondition(c11830996.condition)
	e1:SetCost(c11830996.cost)
	e1:SetTarget(c11830996.target)
	e1:SetOperation(c11830996.activate)
	c:RegisterEffect(e1)
end
-- 检查玩家是否满足基本分条件
function c11830996.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 判断玩家基本分是否大于等于9000
	return Duel.GetLP(tp)>=9000
end
-- 支付2000基本分的处理函数
function c11830996.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 让玩家支付2000基本分
	Duel.PayLPCost(tp,2000)
end
-- 设置效果目标的处理函数
function c11830996.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家是否可以抽2张卡
	if chk==0 then return Duel.IsPlayerCanDraw(tp,2) end
	-- 设置效果的目标玩家为当前玩家
	Duel.SetTargetPlayer(tp)
	-- 设置效果的目标参数为2
	Duel.SetTargetParam(2)
	-- 设置连锁操作信息为抽2张卡
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,2)
end
-- 效果发动时的处理函数
function c11830996.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取连锁中目标玩家和目标参数
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 让目标玩家抽指定数量的卡
	Duel.Draw(p,d,REASON_EFFECT)
end
