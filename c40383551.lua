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
-- 定义效果的目标函数，在连锁检查通过后设置目标玩家为自己。
function c40383551.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 将当前连锁的目标玩家设置为发动此卡的玩家。
	Duel.SetTargetPlayer(tp)
end
-- 定义效果的操作函数，创建两个全场效果来禁止玩家发动魔法·陷阱卡效果和盖放魔法·陷阱卡。
function c40383551.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 从当前连锁信息中获取目标玩家。
	local p=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER)
	-- 不能作魔法·陷阱卡的效果使用以及发动
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EFFECT_CANNOT_ACTIVATE)
	e1:SetTargetRange(1,0)
	e1:SetValue(c40383551.aclimit)
	e1:SetReset(RESET_PHASE+PHASE_END,1)
	-- 将禁止发动魔法·陷阱卡效果的全场效果注册给目标玩家。
	Duel.RegisterEffect(e1,p)
	-- 盖放
	local e2=Effect.CreateEffect(e:GetHandler())
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CANNOT_SSET)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetTargetRange(1,0)
	-- 设置禁止盖放效果的目标条件为始终成立，即对所有情况生效。
	e2:SetTarget(aux.TRUE)
	e2:SetReset(RESET_PHASE+PHASE_END,1)
	-- 将禁止盖放魔法·陷阱卡的全场效果注册给目标玩家。
	Duel.RegisterEffect(e2,p)
end
-- 定义限制函数，检查效果是否为魔法卡或陷阱卡的效果。
function c40383551.aclimit(e,re,tp)
	return re:IsActiveType(TYPE_SPELL+TYPE_TRAP)
end
