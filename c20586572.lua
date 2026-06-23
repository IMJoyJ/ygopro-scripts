--ボマー・ドラゴン
-- 效果：
-- ①：这张卡的攻击发生的双方的战斗伤害变成0。
-- ②：这张卡被战斗破坏送去墓地的场合发动。把让这张卡破坏的怪兽破坏。
function c20586572.initial_effect(c)
	-- ②：这张卡被战斗破坏送去墓地的场合发动。把让这张卡破坏的怪兽破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(20586572,0))  --"破坏"
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_BATTLE_DESTROYED)
	e1:SetCondition(c20586572.condition)
	e1:SetTarget(c20586572.target)
	e1:SetOperation(c20586572.operation)
	c:RegisterEffect(e1)
	-- ①：这张卡的攻击发生的双方的战斗伤害变成0。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_NO_BATTLE_DAMAGE)
	e2:SetCondition(c20586572.damcon)
	e2:SetValue(1)
	c:RegisterEffect(e2)
	-- ①：这张卡的攻击发生的双方的战斗伤害变成0。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_AVOID_BATTLE_DAMAGE)
	e3:SetCondition(c20586572.damcon)
	e3:SetValue(1)
	c:RegisterEffect(e3)
end
-- 判断触发效果是否满足条件：卡片在墓地且因战斗破坏，且导致其破坏的怪兽与本次战斗相关。
function c20586572.condition(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsLocation(LOCATION_GRAVE) and e:GetHandler():IsReason(REASON_BATTLE)
		and e:GetHandler():GetReasonCard():IsRelateToBattle()
end
-- 设置效果的目标：将导致该卡被破坏的怪兽设为破坏对象。
function c20586572.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local rc=e:GetHandler():GetReasonCard()
	rc:CreateEffectRelation(e)
	-- 设置连锁操作信息：确定本次效果会破坏目标怪兽。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,rc,1,0,0)
end
-- 执行效果操作：若目标怪兽仍然有效，则将其破坏。
function c20586572.operation(e,tp,eg,ep,ev,re,r,rp)
	local rc=e:GetHandler():GetReasonCard()
	if rc:IsRelateToEffect(e) then
		-- 执行破坏操作：将目标怪兽因效果破坏。
		Duel.Destroy(rc,REASON_EFFECT)
	end
end
-- 判断是否为攻击怪兽：当前攻击怪兽是否为该卡。
function c20586572.damcon(e)
	-- 判断当前攻击怪兽是否为该卡。
	return Duel.GetAttacker()==e:GetHandler()
end
