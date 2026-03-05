--復讐の女戦士ローズ
-- 效果：
-- ①：这张卡给与对方战斗伤害的场合发动。给与对方300伤害。
function c1557341.initial_effect(c)
	-- 效果原文内容：①：这张卡给与对方战斗伤害的场合发动。给与对方300伤害。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(1557341,0))  --"300伤害"
	e1:SetCategory(CATEGORY_DAMAGE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_BATTLE_DAMAGE)
	e1:SetCondition(c1557341.condition)
	e1:SetTarget(c1557341.target)
	e1:SetOperation(c1557341.operation)
	c:RegisterEffect(e1)
end
-- 规则层面作用：判断造成战斗伤害的玩家是否为对方（非自己）
function c1557341.condition(e,tp,eg,ep,ev,re,r,rp)
	return ep~=tp
end
-- 规则层面作用：设置连锁目标玩家为对方，目标参数为300点伤害，并注册伤害效果信息
function c1557341.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 规则层面作用：将连锁的目标玩家设置为对方
	Duel.SetTargetPlayer(1-tp)
	-- 规则层面作用：将连锁的目标参数设置为300
	Duel.SetTargetParam(300)
	-- 规则层面作用：设置当前连锁的操作信息为对对方造成300点伤害
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,300)
end
-- 规则层面作用：效果发动时，获取连锁中设定的目标玩家和伤害值并执行伤害效果
function c1557341.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 规则层面作用：从当前连锁中获取目标玩家和目标参数（伤害值）
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 规则层面作用：对目标玩家造成指定伤害值的战斗伤害
	Duel.Damage(p,d,REASON_EFFECT)
end
