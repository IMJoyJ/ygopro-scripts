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
-- 判断是否为当前回合玩家触发效果
function c52090844.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前玩家是否为回合玩家
	return tp==Duel.GetTurnPlayer()
end
-- 设置伤害效果的目标玩家和伤害值
function c52090844.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置连锁处理对象为对方玩家
	Duel.SetTargetPlayer(1-tp)
	-- 设置连锁处理参数为600点伤害
	Duel.SetTargetParam(600)
	-- 设置连锁操作信息为对对方造成600点伤害
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,600)
end
-- 执行伤害效果，对指定玩家造成伤害
function c52090844.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取连锁中设定的目标玩家和伤害值
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 对目标玩家造成指定点数的伤害
	Duel.Damage(p,d,REASON_EFFECT)
end
