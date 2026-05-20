--ワンショット・ロケット
-- 效果：
-- 这张卡攻击的场合，这张卡不会被战斗破坏。那次伤害计算后，给与对方基本分攻击对象怪兽的攻击力一半数值的伤害。
function c6142213.initial_effect(c)
	-- 那次伤害计算后，给与对方基本分攻击对象怪兽的攻击力一半数值的伤害。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(6142213,0))  --"伤害"
	e1:SetCategory(CATEGORY_DAMAGE)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_BATTLED)
	e1:SetCondition(c6142213.condition)
	e1:SetTarget(c6142213.target)
	e1:SetOperation(c6142213.operation)
	c:RegisterEffect(e1)
	-- 这张卡攻击的场合，这张卡不会被战斗破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e2:SetCondition(c6142213.indcon)
	e2:SetValue(1)
	c:RegisterEffect(e2)
end
-- 伤害计算后效果的发动条件函数
function c6142213.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 判断自身是否为攻击怪兽，且存在攻击对象
	return e:GetHandler()==Duel.GetAttacker() and Duel.GetAttackTarget()
end
-- 伤害计算后效果的发动准备与目标设置函数
function c6142213.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 计算攻击对象怪兽攻击力一半的数值（向下取整）
	local dam=math.floor(Duel.GetAttackTarget():GetAttack()/2)
	-- 设置效果的对象玩家为对方玩家
	Duel.SetTargetPlayer(1-tp)
	-- 设置效果的对象参数为计算出的伤害数值
	Duel.SetTargetParam(dam)
	-- 设置连锁的操作信息，表示该效果会给与对方玩家指定数值的伤害
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,0,0,1-tp,dam)
end
-- 伤害计算后效果的执行函数
function c6142213.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中设定的对象玩家
	local p=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER)
	-- 以效果原因给与对方玩家攻击对象怪兽攻击力一半数值的伤害
	Duel.Damage(p,math.floor(Duel.GetAttackTarget():GetAttack()/2),REASON_EFFECT)
end
-- 不会被战斗破坏效果的适用条件函数
function c6142213.indcon(e)
	-- 判断自身是否为攻击怪兽
	return e:GetHandler()==Duel.GetAttacker()
end
