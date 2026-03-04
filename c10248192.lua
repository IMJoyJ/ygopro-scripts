--ヒエログリフの石版
-- 效果：
-- 支付1000基本分。在本次决斗中，自己的手卡制限张数为7张。
function c10248192.initial_effect(c)
	-- 卡片效果初始化，创建一个永续效果，用于处理发动时的条件和操作
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCost(c10248192.cost)
	e1:SetTarget(c10248192.target)
	e1:SetOperation(c10248192.activate)
	c:RegisterEffect(e1)
end
-- 支付1000基本分
function c10248192.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家是否能支付1000基本分
	if chk==0 then return Duel.CheckLPCost(tp,1000) end
	-- 让玩家支付1000基本分
	Duel.PayLPCost(tp,1000)
end
-- 设置效果的目标玩家
function c10248192.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 将当前处理的连锁对象设置为玩家
	Duel.SetTargetPlayer(tp)
end
-- 效果发动时的处理函数
function c10248192.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的目标玩家
	local p=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER)
	-- 在本次决斗中，自己的手卡制限张数为7张
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_HAND_LIMIT)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetValue(7)
	-- 将效果注册给目标玩家，使该玩家手牌上限变为7张
	Duel.RegisterEffect(e1,p)
end
