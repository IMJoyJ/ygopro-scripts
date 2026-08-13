--ゴブリンの小役人
-- 效果：
-- 对方的基本分3000以下的场合才可以发动。每次对方的准备阶段对方基本分受到500分的伤害。
function c1918087.initial_effect(c)
	-- 对方的基本分3000以下的场合才可以发动。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMING_DRAW_PHASE)
	e1:SetCondition(c1918087.actcon)
	c:RegisterEffect(e1)
	-- 每次对方的准备阶段对方基本分受到500分的伤害。
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
-- 效果发动条件：仅当对方基本分在3000以下时才允许发动此卡。
function c1918087.actcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断对方玩家当前基本分是否为3000以下（1-tp为对方玩家）。
	return Duel.GetLP(1-tp)<=3000
end
-- 触发条件：仅在对手的回合（对方的准备阶段）时才满足，即当前回合玩家不是这张卡的控制者。
function c1918087.damcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前回合玩家是否不是效果控制者，即是否处于对方回合。
	return tp~=Duel.GetTurnPlayer()
end
-- 效果发动时的目标处理：无选择要求；将对象玩家设为对方，伤害参数设为500，并登记给与500点伤害的操作信息。
function c1918087.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 将当前连锁的对象玩家设置为对方玩家（1-tp），表示伤害的对象是对方。
	Duel.SetTargetPlayer(1-tp)
	-- 将当前连锁的对象参数设置为500，即伤害数值。
	Duel.SetTargetParam(500)
	-- 登记操作信息：效果分类为伤害，对象玩家为对方，预计伤害数值为500（用于连锁判定和时点响应）。
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,500)
end
-- 效果处理：从连锁信息中取得对象玩家和伤害数值，并对该玩家造成等量效果伤害。
function c1918087.damop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中记录的对象玩家和对象参数（伤害数值），分别存入p和d。
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 以效果原因对玩家p造成d点伤害。
	Duel.Damage(p,d,REASON_EFFECT)
end
