--ゴブリンの小役人
-- 效果：
-- 对方的基本分3000以下的场合才可以发动。每次对方的准备阶段对方基本分受到500分的伤害。
function c1918087.initial_effect(c)
	-- 效果原文内容：对方的基本分3000以下的场合才可以发动。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMING_DRAW_PHASE)
	e1:SetCondition(c1918087.actcon)
	c:RegisterEffect(e1)
	-- 效果原文内容：每次对方的准备阶段对方基本分受到500分的伤害。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(1918087,0))  --"给与对方500伤害"
	e2:SetCategory(CATEGORY_DAMAGE)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1)
	e2:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e2:SetCondition(c1918087.damcon)
	e2:SetTarget(c1918087.damtg)
	e2:SetOperation(c1918087.damop)
	c:RegisterEffect(e2)
end
-- 规则层面作用：判断发动条件，当对方基本分不超过3000时可以发动
function c1918087.actcon(e,tp,eg,ep,ev,re,r,rp)
	-- 规则层面作用：检查对方基本分是否小于等于3000
	return Duel.GetLP(1-tp)<=3000
end
-- 规则层面作用：判断伤害触发条件，确保不是在自己的准备阶段触发
function c1918087.damcon(e,tp,eg,ep,ev,re,r,rp)
	-- 规则层面作用：确保当前不是回合玩家触发该效果
	return tp~=Duel.GetTurnPlayer()
end
-- 规则层面作用：设置伤害效果的目标和参数信息
function c1918087.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 规则层面作用：设置连锁处理的目标玩家为对方
	Duel.SetTargetPlayer(1-tp)
	-- 规则层面作用：设置连锁处理的目标参数为500点伤害
	Duel.SetTargetParam(500)
	-- 规则层面作用：设置连锁操作信息为对对方造成500点伤害
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,500)
end
-- 规则层面作用：执行伤害效果，对指定玩家造成指定伤害
function c1918087.damop(e,tp,eg,ep,ev,re,r,rp)
	-- 规则层面作用：从连锁信息中获取目标玩家和伤害值
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 规则层面作用：以效果原因对目标玩家造成指定伤害值
	Duel.Damage(p,d,REASON_EFFECT)
end
