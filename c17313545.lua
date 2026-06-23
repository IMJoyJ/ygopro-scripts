--ゴーレム
-- 效果：
-- 只要这张卡在场上表侧表示存在，场上表侧表示存在的光属性怪兽的效果无效化。这张卡战斗破坏光属性怪兽的场合，只有1次可以继续攻击。
function c17313545.initial_effect(c)
	-- 只要这张卡在场上表侧表示存在，场上表侧表示存在的光属性怪兽的效果无效化
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EFFECT_DISABLE)
	e1:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e1:SetTarget(c17313545.distg)
	c:RegisterEffect(e1)
	-- 这张卡战斗破坏光属性怪兽的场合，只有1次可以继续攻击
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(17313545,0))  --"连续攻击"
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_BATTLE_DESTROYING)
	e2:SetCondition(c17313545.atcon)
	e2:SetOperation(c17313545.atop)
	c:RegisterEffect(e2)
end
-- 目标为光属性效果怪兽时，该怪兽效果被无效化
function c17313545.distg(e,c)
	return c:IsAttribute(ATTRIBUTE_LIGHT) and c:IsType(TYPE_EFFECT)
end
-- 战斗破坏光属性怪兽且自身可以进行连续攻击时发动
function c17313545.atcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 满足战斗破坏条件且自身可以进行连续攻击
	return aux.bdcon(e,tp,eg,ep,ev,re,r,rp) and c:IsChainAttackable()
		and c:GetBattleTarget():IsAttribute(ATTRIBUTE_LIGHT)
end
-- 使攻击卡可以再进行1次攻击
function c17313545.atop(e,tp,eg,ep,ev,re,r,rp)
	-- 执行连续攻击效果
	Duel.ChainAttack()
end
