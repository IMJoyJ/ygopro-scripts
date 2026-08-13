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
-- 发动时无条件允许发动，并将发动者tp记录为效果的对象玩家。
function c40383551.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 将当前连锁的对象玩家设为发动者tp（即效果作用于自己）。
	Duel.SetTargetPlayer(tp)
end
-- 效果处理时，先从连锁取得对象玩家p，再给p适用两个持续到结束阶段的限制：不能发动魔法·陷阱卡的效果，不能盖放魔法·陷阱卡。
function c40383551.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 从当前连锁信息中取出之前设定的对象玩家p（即发动者），作为限制效果的适用对象。
	local p=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER)
	-- 自己不能作魔法·陷阱卡的效果使用
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EFFECT_CANNOT_ACTIVATE)
	e1:SetTargetRange(1,0)
	e1:SetValue(c40383551.aclimit)
	e1:SetReset(RESET_PHASE+PHASE_END,1)
	-- 将禁止发动魔法·陷阱卡效果的限制效果注册给对象玩家p，使其持续到结束阶段。
	Duel.RegisterEffect(e1,p)
	-- 以及发动·盖放。
	local e2=Effect.CreateEffect(e:GetHandler())
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CANNOT_SSET)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetTargetRange(1,0)
	-- 设置该效果的适用卡条件为恒真，即该玩家不能盖放任意魔法·陷阱卡。
	e2:SetTarget(aux.TRUE)
	e2:SetReset(RESET_PHASE+PHASE_END,1)
	-- 将不能盖放魔法·陷阱卡的限制效果注册给对象玩家p，持续到结束阶段。
	Duel.RegisterEffect(e2,p)
end
-- 限制效果的判定函数：若试图发动的效果属于魔法或陷阱卡的效果，则返回true，使该发动被禁止。
function c40383551.aclimit(e,re,tp)
	return re:IsActiveType(TYPE_SPELL+TYPE_TRAP)
end
