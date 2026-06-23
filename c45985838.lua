--プロミネンス・ドラゴン
-- 效果：
-- 若自己场上有除这张卡以外的炎族怪兽存在，则这张卡不能被攻击。在自己的每回合的结束阶段，给与对方基本分500分的伤害。
function c45985838.initial_effect(c)
	-- 若自己场上有除这张卡以外的炎族怪兽存在，则这张卡不能被攻击。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_CANNOT_BE_BATTLE_TARGET)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(c45985838.atklm)
	-- 设置效果值为aux.imval1，用于判断是否免疫攻击目标效果。
	e1:SetValue(aux.imval1)
	c:RegisterEffect(e1)
	-- 在自己的每回合的结束阶段，给与对方基本分500分的伤害。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(45985838,0))  --"给予对方500伤害"
	e2:SetCategory(CATEGORY_DAMAGE)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetCode(EVENT_PHASE+PHASE_END)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetCondition(c45985838.condition)
	e2:SetTarget(c45985838.target)
	e2:SetOperation(c45985838.operation)
	c:RegisterEffect(e2)
end
-- 过滤函数，用于判断场上是否存在表侧表示的炎族怪兽。
function c45985838.filter(c)
	return c:IsFaceup() and c:IsRace(RACE_PYRO)
end
-- 条件函数，判断当前卡是否满足不能被攻击的条件。
function c45985838.atklm(e)
	local c=e:GetHandler()
	-- 检查以当前玩家为视角，在己方主要怪兽区是否存在至少1张满足filter条件的怪兽。
	return Duel.IsExistingMatchingCard(c45985838.filter,c:GetControler(),LOCATION_MZONE,0,1,c)
end
-- 触发条件函数，判断是否为当前回合玩家的结束阶段。
function c45985838.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前处理效果的玩家是否为当前回合玩家。
	return tp==Duel.GetTurnPlayer()
end
-- 设置连锁目标玩家为对方玩家，目标参数为500，准备造成伤害。
function c45985838.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置连锁的目标玩家为对方玩家（1-tp表示对方玩家）。
	Duel.SetTargetPlayer(1-tp)
	-- 设置连锁的目标参数为500，表示伤害值。
	Duel.SetTargetParam(500)
	-- 设置连锁的操作信息为造成500点伤害，目标玩家为对方。
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,500)
end
-- 伤害效果的处理函数，获取目标玩家和伤害值并执行伤害效果。
function c45985838.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 从当前连锁中获取目标玩家和目标参数（伤害值）。
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 以效果原因对目标玩家造成指定伤害值。
	Duel.Damage(p,d,REASON_EFFECT)
end
