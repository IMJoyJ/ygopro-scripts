--ナンバーズ・ウォール
-- 效果：
-- 自己场上有名字带有「No.」的怪兽存在的场合才能发动。只要这张卡在场上存在，双方场上的名字带有「No.」的怪兽不会被卡的效果破坏，不会被和名字带有「No.」的怪兽以外的战斗破坏。自己场上的名字带有「No.」的怪兽被破坏时，这张卡破坏。
function c847915.initial_effect(c)
	-- 自己场上有名字带有「No.」的怪兽存在的场合才能发动。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCondition(c847915.actcon)
	c:RegisterEffect(e1)
	-- 只要这张卡在场上存在，双方场上的名字带有「No.」的怪兽不会被和名字带有「No.」的怪兽以外的战斗破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e2:SetRange(LOCATION_SZONE)
	e2:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	-- 设置战斗破坏抗性的适用对象为名字带有「No.」的怪兽
	e2:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,0x48))
	e2:SetValue(c847915.indval)
	c:RegisterEffect(e2)
	-- 只要这张卡在场上存在，双方场上的名字带有「No.」的怪兽不会被卡的效果破坏
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e3:SetRange(LOCATION_SZONE)
	e3:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	-- 设置效果破坏抗性的适用对象为名字带有「No.」的怪兽
	e3:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,0x48))
	e3:SetValue(1)
	c:RegisterEffect(e3)
	-- 自己场上的名字带有「No.」的怪兽被破坏时，这张卡破坏。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e4:SetRange(LOCATION_SZONE)
	e4:SetCode(EVENT_DESTROYED)
	e4:SetCondition(c847915.descon)
	e4:SetOperation(c847915.desop)
	c:RegisterEffect(e4)
end
-- 过滤条件：场上表侧表示的名字带有「No.」的怪兽
function c847915.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x48)
end
-- 战斗破坏抗性的判定函数：若攻击怪兽不带有「No.」字段，则不会被其战斗破坏
function c847915.indval(e,c)
	return not c:IsSetCard(0x48)
end
-- 发动条件：自己场上存在表侧表示的名字带有「No.」的怪兽
function c847915.actcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否存在至少1张表侧表示的名字带有「No.」的怪兽
	return Duel.IsExistingMatchingCard(c847915.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
-- 过滤条件：原本由自己控制、原本在怪兽区表侧表示存在且名字带有「No.」的被破坏的怪兽
function c847915.dfilter(c,tp)
	return c:IsPreviousControler(tp) and c:IsPreviousLocation(LOCATION_MZONE) and c:IsPreviousPosition(POS_FACEUP) and c:IsPreviousSetCard(0x48)
end
-- 自毁效果的触发条件：被破坏的卡片中存在满足过滤条件的怪兽
function c847915.descon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c847915.dfilter,1,nil,tp)
end
-- 自毁效果的执行操作：破坏这张卡
function c847915.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 因效果破坏这张卡自身
	Duel.Destroy(e:GetHandler(),REASON_EFFECT)
end
