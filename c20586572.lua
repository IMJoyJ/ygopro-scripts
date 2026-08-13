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
	-- ①：这张卡的攻击发生的双方的战斗伤害变成0。（此处为其中“对方受到的战斗伤害变为0”的部分）
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_NO_BATTLE_DAMAGE)
	e2:SetCondition(c20586572.damcon)
	e2:SetValue(1)
	c:RegisterEffect(e2)
	-- ①：这张卡的攻击发生的双方的战斗伤害变成0。（此处为其中“自己受到的战斗伤害变为0”的部分）
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_AVOID_BATTLE_DAMAGE)
	e3:SetCondition(c20586572.damcon)
	e3:SetValue(1)
	c:RegisterEffect(e3)
end
-- ②的发动条件判定：这张卡被战斗破坏后确实处于墓地，破坏原因是战斗，且把这张卡破坏的怪兽仍与本次战斗关联，满足“被战斗破坏送去墓地”的时点。
function c20586572.condition(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsLocation(LOCATION_GRAVE) and e:GetHandler():IsReason(REASON_BATTLE)
		and e:GetHandler():GetReasonCard():IsRelateToBattle()
end
-- ②的发动时目标处理：在效果发动时（chk==0）直接允许发动；随后取得导致这张卡战斗破坏的怪兽，将其与本效果建立关联，并设置接下来要破坏该怪兽的操作信息。
function c20586572.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local rc=e:GetHandler():GetReasonCard()
	rc:CreateEffectRelation(e)
	-- 设置操作信息：声明当前连锁将破坏rc这张卡，破坏数量为1，破坏类型为效果破坏；该信息用于星尘龙等卡对破坏效果进行对应。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,rc,1,0,0)
end
-- ②的效果处理：取得导致这张卡战斗破坏的怪兽，若该怪兽仍与效果e保持有效关联（没有因离场等原因解除联系），则将其破坏。
function c20586572.operation(e,tp,eg,ep,ev,re,r,rp)
	local rc=e:GetHandler():GetReasonCard()
	if rc:IsRelateToEffect(e) then
		-- 以效果破坏的方式将rc怪兽破坏（送去墓地）。
		Duel.Destroy(rc,REASON_EFFECT)
	end
end
-- ①的共通条件：伤害变为0的效果仅在当前战斗的攻击者是这张卡本身时适用，即只有这张卡发动的攻击才把双方战斗伤害变为0。
function c20586572.damcon(e)
	-- 判断当前战斗的攻击怪兽是否为这张效果持有者自身，若是则条件成立。
	return Duel.GetAttacker()==e:GetHandler()
end
