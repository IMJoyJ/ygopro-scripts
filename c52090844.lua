--ボーガニアン
-- 效果：
-- ①：自己准备阶段发动。给与对方600伤害。
function c52090844.initial_effect(c)
	-- ①：自己准备阶段发动。给与对方600伤害。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(52090844,0))  --"伤害"
	e1:SetCategory(CATEGORY_DAMAGE)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCondition(c52090844.condition)
	e1:SetTarget(c52090844.target)
	e1:SetOperation(c52090844.operation)
	c:RegisterEffect(e1)
end
-- 效果的发动条件：仅在己方回合的准备阶段满足条件，即效果控制者是当前回合玩家。
function c52090844.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前回合玩家是否等于效果控制者，是则条件成立，保证只在己方准备阶段发动。
	return tp==Duel.GetTurnPlayer()
end
-- 效果发动时的目标处理：此效果不取对象，直接设定对方玩家为伤害对象并写入伤害数值，同时登记操作信息。
function c52090844.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 将连锁的对象玩家设为对方玩家（1-tp），即伤害的承受者。
	Duel.SetTargetPlayer(1-tp)
	-- 将连锁的对象参数设为600，表示伤害数值。
	Duel.SetTargetParam(600)
	-- 登记操作信息，声明本连锁包含伤害效果，对象为对方玩家，数值为600，供其他卡效果检测。
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,600)
end
-- 效果处理阶段：从连锁信息中取得目标玩家和伤害数值，执行伤害操作。
function c52090844.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 从当前连锁信息中取出之前设置的对象玩家（p）和伤害参数（d）。
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 以效果原因（REASON_EFFECT）给予玩家p造成d点伤害，即给对方600伤害。
	Duel.Damage(p,d,REASON_EFFECT)
end
