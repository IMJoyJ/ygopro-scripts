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
-- 效果发动条件：该卡为攻击对象且为里侧表示且在主要怪兽区
function c31305911.condition(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 该卡为攻击对象且为里侧表示且在主要怪兽区
	return c==Duel.GetAttackTarget() and bit.band(c:GetBattlePosition(),POS_FACEDOWN)~=0 and c:IsLocation(LOCATION_MZONE)
end
-- 效果处理目标：设定伤害对象为对方玩家，伤害值为1000
function c31305911.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设定连锁处理的目标玩家为对方玩家
	Duel.SetTargetPlayer(1-tp)
	-- 设定连锁处理的目标参数为1000
	Duel.SetTargetParam(1000)
	-- 设置连锁操作信息为造成1000伤害
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,0,0,1-tp,1000)
end
-- 效果处理运算：对目标玩家造成1000伤害
function c31305911.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取连锁处理的目标玩家和伤害值
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 对目标玩家造成指定伤害值
	Duel.Damage(p,d,REASON_EFFECT)
end
