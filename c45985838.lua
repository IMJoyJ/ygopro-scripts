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
	-- 设置“不能成为攻击对象”的效果判定值（此处为不免疫该效果的卡不能选它为攻击对象），用于阻挡攻击时判断是否满足不可攻击条件。
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
-- 过滤函数：筛选场上表侧表示且种族为炎族的怪兽，用于判断是否存在“除这张卡以外的炎族怪兽”。
function c45985838.filter(c)
	return c:IsFaceup() and c:IsRace(RACE_PYRO)
end
-- 攻击限制条件：查看本卡控制者场上是否有除自身以外的表侧表示炎族怪兽，有则本卡不能被选为攻击对象。
function c45985838.atklm(e)
	local c=e:GetHandler()
	-- 检查控制者场上是否存在至少1张除本卡外的表侧表示炎族怪兽；若存在，则“有炎族怪兽保护”的条件成立。
	return Duel.IsExistingMatchingCard(c45985838.filter,c:GetControler(),LOCATION_MZONE,0,1,c)
end
-- 结束阶段伤害效果的发动条件：仅当效果控制者处于自己的回合（tp等于当前回合玩家）时才允许发动。
function c45985838.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 返回判断结果：当前回合玩家是否为效果控制者（tp），用于限定只在己方回合的结束阶段触发。
	return tp==Duel.GetTurnPlayer()
end
-- 目标处理：不取对象，将对方玩家作为伤害对象、数值500，并登记伤害操作信息，确保处理时能正确执行伤害。
function c45985838.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 将本次连锁的对象玩家设为对方玩家（1-tp），即伤害承受者。
	Duel.SetTargetPlayer(1-tp)
	-- 将本次连锁的对象参数设为500，表示要造成的伤害值。
	Duel.SetTargetParam(500)
	-- 向连锁系统登记操作信息：伤害效果，目标为对方玩家（1-tp），数值500，供效果处理及连锁相关判定使用。
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,500)
end
-- 效果处理：读取连锁中记录的玩家和伤害值，并对该玩家执行效果伤害。
function c45985838.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 从当前连锁信息中取出目标玩家p和伤害参数d，供后续伤害处理使用。
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 对玩家p造成d点效果伤害（伤害原因为效果）。
	Duel.Damage(p,d,REASON_EFFECT)
end
