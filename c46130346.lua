--ファイヤー・ボール
-- 效果：
-- ①：给与对方500伤害。
function c46130346.initial_effect(c)
	-- ①：给与对方500伤害。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCategory(CATEGORY_DAMAGE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c46130346.damtg)
	e1:SetOperation(c46130346.damop)
	c:RegisterEffect(e1)
end
-- 该效果发动时的目标处理：检查发动条件（无额外限制），将对方玩家设为对象，设定伤害数值为500，并注册效果处理时造成伤害的操作信息。
function c46130346.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 将当前连锁的对象玩家设置为对方的玩家（1-tp）。
	Duel.SetTargetPlayer(1-tp)
	-- 将当前连锁的对象参数设置为500，即伤害数值。
	Duel.SetTargetParam(500)
	-- 设置操作信息：本连锁将以效果伤害方式向对方玩家造成500点伤害（目标玩家1-tp，伤害值500），用于后续的发动检测与连锁判定。
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,500)
end
-- 效果处理时的操作：从连锁信息中取得对象玩家和伤害值，并给对方造成对应的效果伤害。
function c46130346.damop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中记录的对象玩家和对象参数（即伤害值）。
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 以效果为原因，向对象玩家p造成d点伤害。
	Duel.Damage(p,d,REASON_EFFECT)
end
