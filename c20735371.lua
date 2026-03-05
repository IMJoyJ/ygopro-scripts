--バイバイダメージ
-- 效果：
-- 这个卡名的效果1回合只能适用1次。
-- ①：自己怪兽被攻击的伤害计算时才能发动。那只自己怪兽不会被那次战斗破坏。那次战斗让自己受到战斗伤害时，对方受到那个数值2倍的效果伤害。
function c20735371.initial_effect(c)
	-- 效果原文：这个卡名的效果1回合只能适用1次。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_PRE_DAMAGE_CALCULATE)
	e1:SetCondition(c20735371.condition)
	e1:SetTarget(c20735371.target)
	e1:SetOperation(c20735371.activate)
	c:RegisterEffect(e1)
end
-- 效果原文：①：自己怪兽被攻击的伤害计算时才能发动。
function c20735371.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检索本次战斗的攻击怪兽
	local a=Duel.GetAttacker()
	local d=a:GetBattleTarget()
	e:SetLabelObject(d)
	return a:IsControler(1-tp) and d and d:IsControler(tp)
end
-- 效果原文：那只自己怪兽不会被那次战斗破坏。
function c20735371.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否已发动过此效果
	if chk==0 then return Duel.GetFlagEffect(tp,20735371)==0 end
end
-- 效果原文：那次战斗让自己受到战斗伤害时，对方受到那个数值2倍的效果伤害。
function c20735371.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 检查是否已发动过此效果
	if Duel.GetFlagEffect(tp,20735371)~=0 then return end
	local c=e:GetHandler()
	local tc=e:GetLabelObject()
	if not tc:IsRelateToBattle() then return end
	-- 效果原文：那只自己怪兽不会被那次战斗破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e1:SetValue(1)
	e1:SetReset(RESET_PHASE+PHASE_DAMAGE)
	tc:RegisterEffect(e1)
	-- 效果原文：那次战斗让自己受到战斗伤害时，对方受到那个数值2倍的效果伤害。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_DAMAGE)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_BATTLE_DAMAGE)
	e2:SetCondition(c20735371.damcon)
	e2:SetOperation(c20735371.damop)
	e2:SetReset(RESET_PHASE+PHASE_DAMAGE)
	-- 将效果e2注册给玩家tp
	Duel.RegisterEffect(e2,tp)
	-- 为玩家tp注册标识效果，防止此效果重复发动
	Duel.RegisterFlagEffect(tp,20735371,RESET_PHASE+PHASE_END,0,1)
end
-- 判断造成战斗伤害的玩家是否为效果持有者
function c20735371.damcon(e,tp,eg,ep,ev,re,r,rp)
	return ep==tp
end
-- 使对方受到相当于战斗伤害2倍的伤害
function c20735371.damop(e,tp,eg,ep,ev,re,r,rp)
	-- 给对方造成相当于战斗伤害2倍的伤害
	Duel.Damage(1-tp,ev*2,REASON_EFFECT)
end
