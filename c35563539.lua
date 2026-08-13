--精霊の鏡
-- 效果：
-- 玩家1人为对象的魔法的效果移给其他玩家。
function c35563539.initial_effect(c)
	-- 玩家1人为对象的魔法的效果移给其他玩家。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_CHAINING)
	e1:SetCondition(c35563539.condition)
	e1:SetTarget(c35563539.target)
	e1:SetOperation(c35563539.activate)
	c:RegisterEffect(e1)
end
-- 判断被连锁的效果是否为魔法卡的发动，并且该效果带有以玩家为对象的标志。
function c35563539.condition(e,tp,eg,ep,ev,re,r,rp)
	return re:IsHasType(EFFECT_TYPE_ACTIVATE) and re:IsActiveType(TYPE_SPELL) and re:IsHasProperty(EFFECT_FLAG_PLAYER_TARGET)
end
-- 在发动时进行合法性判定：检查被连锁的魔法效果原本的target条件是否允许以当前玩家为对象，若原效果没有target条件则直接允许。
function c35563539.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		-- 获取当前连锁中正在被连锁的效果（即作为对象的魔法效果）。
		local te=Duel.GetChainInfo(ev,CHAININFO_TRIGGERING_EFFECT)
		local ftg=te:GetTarget()
		return ftg==nil or ftg(e,tp,eg,ep,ev,re,r,rp,chk)
	end
end
-- 效果处理阶段：取得原连锁的对象玩家，并将其变更为对方玩家，从而将效果转移给其他玩家。
function c35563539.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中该魔法效果当前指向的对象玩家。
	local p=Duel.GetChainInfo(ev,CHAININFO_TARGET_PLAYER)
	-- 将连锁的对象玩家改为对方玩家（1-p），实现“移给其他玩家”。
	Duel.ChangeTargetPlayer(ev,1-p)
end
