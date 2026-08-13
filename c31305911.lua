--マシュマロン
-- 效果：
-- ①：这张卡不会被战斗破坏。
-- ②：里侧表示的这张卡被攻击的伤害计算后发动。给与攻击的玩家1000伤害。
function c31305911.initial_effect(c)
	-- ②：里侧表示的这张卡被攻击的伤害计算后发动。给与攻击的玩家1000伤害。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(31305911,0))  --"1000伤害"
	e1:SetCategory(CATEGORY_DAMAGE)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_BATTLED)
	e1:SetCondition(c31305911.condition)
	e1:SetTarget(c31305911.target)
	e1:SetOperation(c31305911.operation)
	c:RegisterEffect(e1)
	-- ①：这张卡不会被战斗破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e2:SetValue(1)
	c:RegisterEffect(e2)
end
-- 诱发效果的发动条件判断：确认本卡是被攻击的那只里侧表示怪兽，并且伤害计算后仍位于主要怪兽区，满足条件才可发动。
function c31305911.condition(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 检查当前卡片是否为攻击对象，其在此次战斗前的表示形式是否为里侧表示，且卡片位于主要怪兽区。
	return c==Duel.GetAttackTarget() and bit.band(c:GetBattlePosition(),POS_FACEDOWN)~=0 and c:IsLocation(LOCATION_MZONE)
end
-- 效果发动时的目标设定：将伤害对象设定为对方玩家，伤害数值设为1000，并向系统登记本次伤害操作信息。
function c31305911.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 将连锁的对象玩家设置为对方玩家（1-tp）。
	Duel.SetTargetPlayer(1-tp)
	-- 将连锁的对象参数设置为1000，即伤害数值。
	Duel.SetTargetParam(1000)
	-- 登记当前连锁的操作信息：效果分类为伤害效果，对对方玩家造成1000点伤害。
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,0,0,1-tp,1000)
end
-- 效果处理时的实际执行：从连锁信息中取出之前设定的对象玩家和伤害值，并造成对应效果伤害。
function c31305911.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 从当前连锁信息中获取效果的对象玩家和伤害参数值。
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 以效果原因给予对象玩家1000点伤害。
	Duel.Damage(p,d,REASON_EFFECT)
end
