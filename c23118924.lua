--エレメント・デビル
-- 效果：
-- 这只怪兽在场上有特定的属性的怪兽存在的场合，得到以下的效果。
-- ●地属性：这张卡战斗破坏的效果怪兽的效果无效化。
-- ●风属性：这张卡战斗破坏对方怪兽的场合，只有1次可以再度攻击。
function c23118924.initial_effect(c)
	-- 地属性效果：当此卡战斗破坏对方怪兽时，若我方场上存在地属性怪兽，则使被战斗破坏的怪兽效果无效化
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_BATTLED)
	e1:SetCondition(c23118924.discon)
	e1:SetOperation(c23118924.disop)
	c:RegisterEffect(e1)
	-- 风属性效果：当此卡战斗破坏对方怪兽时，若我方场上存在风属性怪兽，则此卡可以再进行1次攻击
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(23118924,0))  --"连续攻击"
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_BATTLE_DESTROYING)
	e2:SetCondition(c23118924.atcon)
	e2:SetOperation(c23118924.atop)
	c:RegisterEffect(e2)
end
-- 过滤函数：检查指定位置是否存在表侧表示且属性为指定值的怪兽
function c23118924.filter(c,att)
	return c:IsFaceup() and c:IsAttribute(att)
end
-- 地属性效果的发动条件：此卡与对方怪兽战斗，且对方怪兽已被战斗破坏，同时此卡未被战斗破坏，且我方场上存在地属性怪兽
function c23118924.discon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local bc=c:GetBattleTarget()
	return bc and bc:IsStatus(STATUS_BATTLE_DESTROYED) and not c:IsStatus(STATUS_BATTLE_DESTROYED)
		-- 检查我方场上是否存在地属性怪兽
		and Duel.IsExistingMatchingCard(c23118924.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil,ATTRIBUTE_EARTH)
end
-- 地属性效果的处理：使被战斗破坏的对方怪兽效果无效
function c23118924.disop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local bc=c:GetBattleTarget()
	-- 使对方怪兽效果无效
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_DISABLE)
	e1:SetReset(RESET_EVENT+0x17a0000)
	bc:RegisterEffect(e1)
	-- 使对方怪兽效果无效化
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_DISABLE_EFFECT)
	e2:SetReset(RESET_EVENT+0x17a0000)
	bc:RegisterEffect(e2)
end
-- 风属性效果的发动条件：此卡与对方怪兽战斗并破坏对方怪兽，且此卡可以连续攻击，同时我方场上存在风属性怪兽
function c23118924.atcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查此卡是否可以连续攻击
	return aux.bdocon(e,tp,eg,ep,ev,re,r,rp) and e:GetHandler():IsChainAttackable()
		-- 检查我方场上是否存在风属性怪兽
		and Duel.IsExistingMatchingCard(c23118924.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil,ATTRIBUTE_WIND)
end
-- 风属性效果的处理：使此卡可以再进行1次攻击
function c23118924.atop(e,tp,eg,ep,ev,re,r,rp)
	-- 使此卡可以再进行1次攻击
	Duel.ChainAttack()
end
