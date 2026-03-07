--精霊の鏡
-- 效果：
-- 玩家1人为对象的魔法的效果移给其他玩家。
function c35563539.initial_effect(c)
	-- 创建一张永续魔法卡效果，用于在连锁发动时触发
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_CHAINING)
	e1:SetCondition(c35563539.condition)
	e1:SetTarget(c35563539.target)
	e1:SetOperation(c35563539.activate)
	c:RegisterEffect(e1)
end
-- 效果原文内容：玩家1人为对象的魔法的效果移给其他玩家。
function c35563539.condition(e,tp,eg,ep,ev,re,r,rp)
	return re:IsHasType(EFFECT_TYPE_ACTIVATE) and re:IsActiveType(TYPE_SPELL) and re:IsHasProperty(EFFECT_FLAG_PLAYER_TARGET)
end
-- 判断连锁中被发动的魔法卡是否以玩家为对象
function c35563539.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		-- 获取当前连锁所触发的效果对象
		local te=Duel.GetChainInfo(ev,CHAININFO_TRIGGERING_EFFECT)
		local ftg=te:GetTarget()
		return ftg==nil or ftg(e,tp,eg,ep,ev,re,r,rp,chk)
	end
end
-- 将连锁中目标玩家更换为对方玩家
function c35563539.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的目标玩家
	local p=Duel.GetChainInfo(ev,CHAININFO_TARGET_PLAYER)
	-- 将连锁的目标玩家改为对方玩家
	Duel.ChangeTargetPlayer(ev,1-p)
end
