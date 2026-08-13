--ゴーレム
-- 效果：
-- 只要这张卡在场上表侧表示存在，场上表侧表示存在的光属性怪兽的效果无效化。这张卡战斗破坏光属性怪兽的场合，只有1次可以继续攻击。
function c17313545.initial_effect(c)
	-- 只要这张卡在场上表侧表示存在，场上表侧表示存在的光属性怪兽的效果无效化。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EFFECT_DISABLE)
	e1:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e1:SetTarget(c17313545.distg)
	c:RegisterEffect(e1)
	-- 这张卡战斗破坏光属性怪兽的场合，只有1次可以继续攻击。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(17313545,0))  --"连续攻击"
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_BATTLE_DESTROYING)
	e2:SetCondition(c17313545.atcon)
	e2:SetOperation(c17313545.atop)
	c:RegisterEffect(e2)
end
-- 判定对象怪兽是否为场上表侧表示存在的光属性效果怪兽，作为无效化效果的作用对象。
function c17313545.distg(e,c)
	return c:IsAttribute(ATTRIBUTE_LIGHT) and c:IsType(TYPE_EFFECT)
end
-- 连续攻击效果的发动条件：本卡参与战斗并战斗破坏怪兽、本卡仍可进行连续攻击，且被战斗破坏的怪兽是光属性。
function c17313545.atcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 确认本卡与该战斗破坏事件相关，且本卡尚未失去连续攻击的资格。
	return aux.bdcon(e,tp,eg,ep,ev,re,r,rp) and c:IsChainAttackable()
		and c:GetBattleTarget():IsAttribute(ATTRIBUTE_LIGHT)
end
-- 连续攻击效果的发动处理：使本卡获得再攻击的权限。
function c17313545.atop(e,tp,eg,ep,ev,re,r,rp)
	-- 执行连续攻击：使本卡可以再进行1次攻击。
	Duel.ChainAttack()
end
