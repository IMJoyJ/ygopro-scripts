--雷鳴
-- 效果：
-- 对方受到300分的伤害。
function c56260110.initial_effect(c)
	-- 对方受到300分的伤害。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCategory(CATEGORY_DAMAGE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c56260110.damtg)
	e1:SetOperation(c56260110.damop)
	c:RegisterEffect(e1)
end
-- 设置效果发动的目标与操作信息（伤害对象为对方，伤害值为300）
function c56260110.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 将当前连锁的对象玩家设置为对方
	Duel.SetTargetPlayer(1-tp)
	-- 将当前连锁的对象参数（伤害值）设置为300
	Duel.SetTargetParam(300)
	-- 设置当前连锁的操作信息为：对对方造成300点伤害
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,300)
end
-- 执行效果处理，获取目标玩家和伤害值并给予伤害
function c56260110.damop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中设定的对象玩家和对象参数（伤害值）
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 因效果对目标玩家造成对应的伤害
	Duel.Damage(p,d,REASON_EFFECT)
end
