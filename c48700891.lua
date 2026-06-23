--記憶破壊者
-- 效果：
-- 这张卡对对方玩家直接攻击造成伤害的场合，给与对方基本分对方额外卡组的卡数×100分数值的伤害。
function c48700891.initial_effect(c)
	-- 创建效果，设置为单体诱发必发伤害效果，对象为玩家
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(48700891,0))  --"伤害"
	e1:SetCategory(CATEGORY_DAMAGE)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EVENT_BATTLE_DAMAGE)
	e1:SetCondition(c48700891.condition)
	e1:SetTarget(c48700891.target)
	e1:SetOperation(c48700891.operation)
	c:RegisterEffect(e1)
end
-- 效果条件函数
function c48700891.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 判断攻击方不是自己且没有攻击目标怪兽
	return ep~=tp and Duel.GetAttackTarget()==nil
end
-- 效果处理函数
function c48700891.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 获取对方额外卡组的卡数
	local ct=Duel.GetFieldGroupCount(tp,0,LOCATION_EXTRA)
	-- 设置连锁对象为对方玩家
	Duel.SetTargetPlayer(1-tp)
	-- 设置连锁对象参数为对方额外卡组卡数乘以100
	Duel.SetTargetParam(ct*100)
	-- 设置操作信息为对对方造成伤害
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,ct*100)
end
-- 效果发动时的处理函数
function c48700891.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取对方额外卡组的卡数
	local ct=Duel.GetFieldGroupCount(tp,0,LOCATION_EXTRA)
	-- 获取连锁的目标玩家
	local p=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER)
	-- 对目标玩家造成指定数值的伤害
	Duel.Damage(p,ct*100,REASON_EFFECT)
end
