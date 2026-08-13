--黒魔導師クラン
-- 效果：
-- 自己的准备阶段时，给与对方基本分对方场上存在的怪兽数×300分数值的伤害。
function c46128076.initial_effect(c)
	-- 自己的准备阶段时，给与对方基本分对方场上存在的怪兽数×300分数值的伤害。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(46128076,0))  --"伤害"
	e1:SetCategory(CATEGORY_DAMAGE)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCondition(c46128076.condition)
	e1:SetTarget(c46128076.target)
	e1:SetOperation(c46128076.operation)
	c:RegisterEffect(e1)
end
-- 效果发动条件判定函数：仅在效果持有者自己的回合（即自己的准备阶段）时才允许发动。
function c46128076.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 判定当前回合玩家是否为效果发动者自己，确保满足“自己的准备阶段”这一条件。
	return tp==Duel.GetTurnPlayer()
end
-- 效果发动时的目标设定与合法性检查：效果必定可发动，计算对方场上怪兽数量，将伤害对象设置为对方玩家，并写入预期的伤害操作信息。
function c46128076.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 统计对方场上主要怪兽区域的怪兽数量，作为后续伤害数值的计算基准。
	local ct=Duel.GetFieldGroupCount(tp,0,LOCATION_MZONE)
	-- 将当前连锁处理的对象玩家设置为对方玩家（1-tp），使后续伤害效果指向对方。
	Duel.SetTargetPlayer(1-tp)
	-- 设置操作信息：声明本效果属于伤害效果，目标玩家为对方，预计造成的伤害值为对方场上怪兽数×300。
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,ct*300)
end
-- 效果处理函数：从连锁信息中取出目标玩家，按处理时对方场上实际存在的怪兽数计算伤害并给予伤害。
function c46128076.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 从当前连锁信息中取得此前记录的对象玩家，即承受这次伤害的对方玩家。
	local p=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER)
	-- 效果处理时再次统计对方场上存在的怪兽数量，以最新的怪兽数作为伤害计算依据。
	local ct=Duel.GetFieldGroupCount(tp,0,LOCATION_MZONE)
	-- 以卡牌效果为原因，对目标玩家造成对方场上怪兽数×300点的伤害。
	Duel.Damage(p,ct*300,REASON_EFFECT)
end
