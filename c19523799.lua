--昼夜の大火事
-- 效果：
-- 给与对方基本分800分伤害。
function c19523799.initial_effect(c)
	-- 给与对方基本分800分伤害。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCategory(CATEGORY_DAMAGE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c19523799.damtg)
	e1:SetOperation(c19523799.damop)
	c:RegisterEffect(e1)
end
-- 效果发动时的目标处理：可发动时返回true，并将对方玩家设为对象玩家、伤害值设为800，同时登记效果操作信息。
function c19523799.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 将当前连锁的对象玩家设置为对方玩家（1-tp表示与发动者tp相反的玩家）。
	Duel.SetTargetPlayer(1-tp)
	-- 将当前连锁的对象参数设置为800，表示要造成的伤害数值。
	Duel.SetTargetParam(800)
	-- 登记操作信息：本次效果将以伤害类别给对方玩家造成800点伤害，用于连锁处理和时点检测。
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,800)
end
-- 效果处理时的操作：从连锁信息中取出目标玩家和伤害数值，并给对方造成效果伤害。
function c19523799.damop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中保存的目标玩家和目标参数，分别赋值给p（玩家）和d（伤害值）。
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 以效果原因（REASON_EFFECT）给目标玩家p造成d点伤害。
	Duel.Damage(p,d,REASON_EFFECT)
end
