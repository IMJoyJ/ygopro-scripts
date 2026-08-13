--エレメント・デビル
-- 效果：
-- 这只怪兽在场上有特定的属性的怪兽存在的场合，得到以下的效果。
-- ●地属性：这张卡战斗破坏的效果怪兽的效果无效化。
-- ●风属性：这张卡战斗破坏对方怪兽的场合，只有1次可以再度攻击。
function c23118924.initial_effect(c)
	-- ●地属性：这张卡战斗破坏的效果怪兽的效果无效化。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_BATTLED)
	e1:SetCondition(c23118924.discon)
	e1:SetOperation(c23118924.disop)
	c:RegisterEffect(e1)
	-- ●风属性：这张卡战斗破坏对方怪兽的场合，只有1次可以再度攻击。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(23118924,0))  --"连续攻击"
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_BATTLE_DESTROYING)
	e2:SetCondition(c23118924.atcon)
	e2:SetOperation(c23118924.atop)
	c:RegisterEffect(e2)
end
-- 过滤函数：判断怪兽是否为表侧表示且拥有指定的属性，用于检索场上是否存在特定属性的表侧表示怪兽。
function c23118924.filter(c,att)
	return c:IsFaceup() and c:IsAttribute(att)
end
-- 地属性效果的发动的条件：这张卡进行过伤害计算、战斗对象被战斗破坏而这张卡未破坏，且自己场上存在表侧表示的地属性怪兽。
function c23118924.discon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local bc=c:GetBattleTarget()
	return bc and bc:IsStatus(STATUS_BATTLE_DESTROYED) and not c:IsStatus(STATUS_BATTLE_DESTROYED)
		-- 检测自己或对方场上是否存在至少1只表侧表示的地属性怪兽，以满足获得地属性效果所需的条件。
		and Duel.IsExistingMatchingCard(c23118924.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil,ATTRIBUTE_EARTH)
end
-- 地属性效果处理：对这张卡战斗破坏的那只怪兽赋予“效果无效”和“效果的效果无效”状态，使其效果无效化，且持续到该怪兽离场。
function c23118924.disop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local bc=c:GetBattleTarget()
	-- 这张卡战斗破坏的效果怪兽的效果无效化。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_DISABLE)
	e1:SetReset(RESET_EVENT+0x17a0000)
	bc:RegisterEffect(e1)
	-- 这张卡战斗破坏的效果怪兽的效果无效化。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_DISABLE_EFFECT)
	e2:SetReset(RESET_EVENT+0x17a0000)
	bc:RegisterEffect(e2)
end
-- 风属性效果的发动条件：这张卡与对方怪兽战斗并将其破坏、自身可以进行连续攻击，且场上存在表侧表示的风属性怪兽。
function c23118924.atcon(e,tp,eg,ep,ev,re,r,rp)
	-- 确认这张卡确实与对方怪兽进行战斗并破坏了对方怪兽（通过辅助函数判定），且自身满足连续攻击的发动条件（如攻击次数未超过限制）。
	return aux.bdocon(e,tp,eg,ep,ev,re,r,rp) and e:GetHandler():IsChainAttackable()
		-- 检测场上是否存在至少1只表侧表示的风属性怪兽，以满足获得风属性效果所需的条件。
		and Duel.IsExistingMatchingCard(c23118924.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil,ATTRIBUTE_WIND)
end
-- 风属性效果处理：使这张卡获得追加攻击的能力，在本次战斗阶段中可以进行第二次攻击。
function c23118924.atop(e,tp,eg,ep,ev,re,r,rp)
	-- 发动连续攻击，使这张卡可以再进行1次攻击。
	Duel.ChainAttack()
end
