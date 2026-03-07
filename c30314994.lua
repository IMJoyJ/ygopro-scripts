--エレメント・ドラゴン
-- 效果：
-- ①：场上的怪兽属性让这张卡得到以下效果。
-- ●炎属性：这张卡的攻击力上升500。
-- ●风属性：这张卡战斗破坏对方怪兽时才能发动。这张卡只再1次可以继续攻击。
function c30314994.initial_effect(c)
	-- 效果原文内容：●炎属性：这张卡的攻击力上升500。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetValue(500)
	e1:SetCondition(c30314994.atkcon)
	c:RegisterEffect(e1)
	-- 效果原文内容：●风属性：这张卡战斗破坏对方怪兽时才能发动。这张卡只再1次可以继续攻击。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(30314994,0))  --"连续攻击"
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_BATTLE_DESTROYING)
	e2:SetCondition(c30314994.atcon)
	e2:SetOperation(c30314994.atop)
	c:RegisterEffect(e2)
end
-- 函数作用：检查指定属性的怪兽是否存在于场上
function c30314994.filter(c,att)
	return c:IsFaceup() and c:IsAttribute(att)
end
-- 效果作用：当场上有炎属性怪兽存在时，使此卡攻击力上升500
function c30314994.atkcon(e)
	-- 检查场上是否存在至少1只炎属性的表侧表示怪兽
	return Duel.IsExistingMatchingCard(c30314994.filter,0,LOCATION_MZONE,LOCATION_MZONE,1,nil,ATTRIBUTE_FIRE)
end
-- 效果作用：当此卡战斗破坏对方怪兽且场上有风属性怪兽存在时，可发动连续攻击
function c30314994.atcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检测此卡是否因战斗破坏对方怪兽而触发效果
	return aux.bdocon(e,tp,eg,ep,ev,re,r,rp) and e:GetHandler():IsChainAttackable()
		-- 检查场上是否存在至少1只风属性的表侧表示怪兽
		and Duel.IsExistingMatchingCard(c30314994.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil,ATTRIBUTE_WIND)
end
-- 效果作用：执行连续攻击
function c30314994.atop(e,tp,eg,ep,ev,re,r,rp)
	-- 使当前攻击怪兽可以再进行1次攻击
	Duel.ChainAttack()
end
