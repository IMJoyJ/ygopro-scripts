--エレメント・マジシャン
-- 效果：
-- 这只怪兽在场上有特定属性的怪兽存在的场合，得到以下的效果。
-- ●水属性：这张卡的控制权不能变更。
-- ●风属性：这张卡战斗破坏对方怪兽的场合，只有1次可以再度攻击。
function c65260293.initial_effect(c)
	-- 这只怪兽在场上有特定属性的怪兽存在的场合，得到以下的效果。●水属性：这张卡的控制权不能变更。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EFFECT_CANNOT_CHANGE_CONTROL)
	e1:SetCondition(c65260293.ctlcon)
	c:RegisterEffect(e1)
	-- 这只怪兽在场上有特定属性的怪兽存在的场合，得到以下的效果。●风属性：这张卡战斗破坏对方怪兽的场合，只有1次可以再度攻击。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(65260293,0))  --"连续攻击"
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_BATTLE_DESTROYING)
	e2:SetCondition(c65260293.atcon)
	e2:SetOperation(c65260293.atop)
	c:RegisterEffect(e2)
end
-- 过滤函数：检查卡片是否为表侧表示且属于指定属性
function c65260293.filter(c,att)
	return c:IsFaceup() and c:IsAttribute(att)
end
-- 控制权不能变更效果的启用条件：场上存在水属性怪兽
function c65260293.ctlcon(e)
	-- 检查双方场上是否存在至少1张表侧表示的水属性怪兽
	return Duel.IsExistingMatchingCard(c65260293.filter,0,LOCATION_MZONE,LOCATION_MZONE,1,nil,ATTRIBUTE_WATER)
end
-- 再度攻击效果的发动条件：自身战斗破坏对方怪兽、可以进行连续攻击，且场上存在风属性怪兽
function c65260293.atcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自身是否战斗破坏了对方怪兽，且自身当前是否可以进行连续攻击
	return aux.bdocon(e,tp,eg,ep,ev,re,r,rp) and e:GetHandler():IsChainAttackable()
		-- 检查双方场上是否存在至少1张表侧表示的风属性怪兽
		and Duel.IsExistingMatchingCard(c65260293.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil,ATTRIBUTE_WIND)
end
-- 再度攻击效果的处理：使自身可以再进行1次攻击
function c65260293.atop(e,tp,eg,ep,ev,re,r,rp)
	-- 使当前攻击的怪兽可以再进行1次攻击
	Duel.ChainAttack()
end
