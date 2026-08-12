--吸血コアラ
-- 效果：
-- 这张卡和怪兽的战斗给与对方基本分战斗伤害时，自己基本分回复给与的战斗伤害的数值。
function c1371589.initial_effect(c)
	-- 诱发必发效果，对应一速的【……发动】
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(1371589,0))  --"回复"
	e1:SetCategory(CATEGORY_RECOVER)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EVENT_BATTLE_DAMAGE)
	e1:SetCondition(c1371589.condition)
	e1:SetTarget(c1371589.target)
	e1:SetOperation(c1371589.operation)
	c:RegisterEffect(e1)
end
-- 效果条件判断函数
function c1371589.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 判断本次战斗伤害是否由对方造成且攻击对象存在
	return ep~=tp and Duel.GetAttackTarget()~=nil
end
-- 效果目标设定函数
function c1371589.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 将当前处理连锁的目标玩家设置为效果持有者
	Duel.SetTargetPlayer(tp)
	-- 将当前处理连锁的目标参数设置为本次战斗伤害值
	Duel.SetTargetParam(ev)
	-- 设置本次连锁的操作信息为回复效果，目标玩家为效果持有者，回复数值为战斗伤害值
	Duel.SetOperationInfo(0,CATEGORY_RECOVER,0,0,tp,ev)
end
-- 效果处理函数
function c1371589.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的目标玩家和目标参数（即战斗伤害值）
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 以效果原因使目标玩家回复目标参数数值的LP
	Duel.Recover(p,d,REASON_EFFECT)
end
