--黒魔導師クラン
-- 效果：
-- 自己的准备阶段时，给与对方基本分对方场上存在的怪兽数×300分数值的伤害。
function c46128076.initial_effect(c)
	-- 创建效果，设置为场地区域触发的诱发必发效果，用于在准备阶段发动
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
-- 判断是否为当前回合玩家触发效果
function c46128076.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 只有当当前玩家等于回合玩家时效果才能发动
	return tp==Duel.GetTurnPlayer()
end
-- 设置效果的目标处理函数，计算对方场上怪兽数量并设定伤害目标
function c46128076.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 获取己方场上怪兽数量用于计算伤害值
	local ct=Duel.GetFieldGroupCount(tp,0,LOCATION_MZONE)
	-- 设定连锁处理对象为对方玩家
	Duel.SetTargetPlayer(1-tp)
	-- 设置操作信息，指定将对对方造成伤害，伤害值为场上怪兽数×300
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,ct*300)
end
-- 设置效果的发动处理函数，执行实际的伤害效果
function c46128076.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取连锁中设定的目标玩家
	local p=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER)
	-- 再次获取己方场上怪兽数量用于计算伤害值
	local ct=Duel.GetFieldGroupCount(tp,0,LOCATION_MZONE)
	-- 对目标玩家造成伤害，伤害值为场上怪兽数×300
	Duel.Damage(p,ct*300,REASON_EFFECT)
end
