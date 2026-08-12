--ヒエログリフの石版
-- 效果：
-- 支付1000基本分。在本次决斗中，自己的手卡制限张数为7张。
function c10248192.initial_effect(c)
	-- 支付1000基本分。在本次决斗中，自己的手卡制限张数为7张。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCost(c10248192.cost)
	e1:SetTarget(c10248192.target)
	e1:SetOperation(c10248192.activate)
	c:RegisterEffect(e1)
end
-- 代价：支付1000基本分
function c10248192.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家是否能支付1000基本分并返回结果
	if chk==0 then return Duel.CheckLPCost(tp,1000) end
	-- 扣除1000基本分
	Duel.PayLPCost(tp,1000)
end
-- 靶指向与发动条件：设置玩家为效果的影响对象
function c10248192.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置当前连锁的对象玩家为发动效果的玩家
	Duel.SetTargetPlayer(tp)
end
-- 效果处理：在本次决斗中，将目标玩家的手牌限制数量变更为7张
function c10248192.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中被设定为对象玩家的玩家
	local p=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER)
	-- 在本次决斗中，自己的手卡制限张数为7张。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_HAND_LIMIT)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetValue(7)
	-- 将影响玩家的手牌限制效果注册到全局环境中
	Duel.RegisterEffect(e1,p)
end
