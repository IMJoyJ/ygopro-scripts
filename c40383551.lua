--大寒気
-- 效果：
-- 这个回合，自己不能作魔法·陷阱卡的效果使用以及发动·盖放。
function c40383551.initial_effect(c)
	-- 这个回合，自己不能作魔法·陷阱卡的效果使用以及发动·盖放。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c40383551.target)
	e1:SetOperation(c40383551.operation)
	c:RegisterEffect(e1)
end
-- 效果作用
function c40383551.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 将当前处理的连锁的目标玩家设置为使用此卡的玩家
	Duel.SetTargetPlayer(tp)
end
-- 效果作用
function c40383551.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的目标玩家
	local p=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER)
	-- 这个回合，自己不能作魔法·陷阱卡的效果使用以及发动·盖放。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EFFECT_CANNOT_ACTIVATE)
	e1:SetTargetRange(1,0)
	e1:SetValue(c40383551.aclimit)
	e1:SetReset(RESET_PHASE+PHASE_END,1)
	-- 将效果e1注册给目标玩家p，使该玩家不能发动魔法·陷阱卡
	Duel.RegisterEffect(e1,p)
	-- 这个回合，自己不能作魔法·陷阱卡的效果使用以及发动·盖放。
	local e2=Effect.CreateEffect(e:GetHandler())
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CANNOT_SSET)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetTargetRange(1,0)
	-- 设置效果e2的目标为所有卡片（即对所有魔法·陷阱卡生效）
	e2:SetTarget(aux.TRUE)
	e2:SetReset(RESET_PHASE+PHASE_END,1)
	-- 将效果e2注册给目标玩家p，使该玩家不能覆盖魔法·陷阱卡
	Duel.RegisterEffect(e2,p)
end
-- 该效果用于判断是否为魔法或陷阱卡的效果
function c40383551.aclimit(e,re,tp)
	return re:IsActiveType(TYPE_SPELL+TYPE_TRAP)
end
